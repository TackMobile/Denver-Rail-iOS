//
//  ScheduleViewController.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import "ScheduleViewController.h"
#import "TimetableSearchUtility.h"
#import "ScheduledStop.h"
#import <QuartzCore/QuartzCore.h>
#import "Math.h"
#import "AppDelegate.h"

// Internal methods
@interface ScheduleViewController()
- (void)updateCellsWithStation:(Station *)_station date:(NSDate *)_date direction:(BOOL)_isNorth;
- (void)performAnimation:(NSArray *)args;
@end

@implementation ScheduleViewController
@synthesize locationManager, isNorthAuto, isNorthManual, currentStops, isAutoMode, firstLoc;
@synthesize currentManualDate, currentManualStation;
@synthesize audioPlayer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        locationManager = [LocationManager instance];
        
        // Always starts in auto mode, northbound
        isAutoMode = YES;
        isNorthAuto = YES;
        
        // If first location needs to be set
        firstLoc = YES;
        
        NSString *soundPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"flips3.aac"];

        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        [self.audioPlayer prepareToPlay];
    }
    return self;
}

// View loaded 
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionUpdated)
                                                 name:@"locationUpdated" object:nil];
}

// Stay in same mode
- (void)updateCellsWithDirection:(BOOL)_isNorth {
    
    // Auto mode
    if (isAutoMode) {
        [self updateCellsAutoModeIsNorth:_isNorth];
        
    // Manual mode
    } else {
        [self updateCellsManualModeWithStation:self.currentManualStation date:self.currentManualDate direction:_isNorth];
    }
}

// Position updated message to send
- (void)positionUpdated {
    
    // Set the initial manual station to the current location if it hasn't been set before
    if (!self.currentManualStation)
        self.currentManualStation = locationManager.closestStation;
}

// This should be called when the station, mode, or direction changes, and every 10 seconds when in auto mode
- (void)updateCellsAutoMode {
    isAutoMode = YES;
    [self updateCellsAutoModeIsNorth:isNorthAuto];
}

// Sends the call to update cells in auto mode depending on direction
- (void)updateCellsAutoModeIsNorth:(BOOL)_isNorth {
    
    isAutoMode = YES;
    isNorthAuto = _isNorth;
    Station *closestStation = locationManager.closestStation;

    /* Some stations do not have a north bound train. So if it starts by default with north
       then people who get auto mode to that train should not show north routes. Same goes for
       south trains.
     */
    if (closestStation.northOnly) {
        _isNorth = YES;
    } else if (closestStation.southOnly){
        _isNorth = NO;
    }
    
    [self updateCellsWithStation:closestStation date:[NSDate date] direction:_isNorth];
}

// Sends the call to update cells in manual mode to a specific station 
- (void)updateCellsManualMode {
    isAutoMode = NO;
    
    if (!self.currentManualDate)
        self.currentManualDate = [NSDate date]; 
    if (!self.currentManualStation)
        self.currentManualStation = [locationManager.stations objectAtIndex:0];
    
    if (self.currentManualStation)
        [self updateCellsManualModeWithStation:self.currentManualStation date:self.currentManualDate];
}

// Sends a call to update the cells in manual mode to a specific station 
- (void)updateCellsManualModeWithStation:(Station *)_station date:(NSDate *)_date {
    [self updateCellsManualModeWithStation:_station date:_date direction:isNorthManual];
}

// Sends the call to update the cells in manual mode with a specific station and direction
- (void)updateCellsManualModeWithStation:(Station *)_station date:(NSDate *)_date direction:(BOOL)_isNorth {
    isAutoMode = NO;
    self.currentManualStation = _station;
    self.currentManualDate = _date;
    isNorthManual = _isNorth;
    [self updateCellsWithStation:_station date:_date direction:_isNorth];
}

// Updates the cells with a specific station and direction
- (void)updateCellsWithStation:(Station *)_station date:(NSDate *)_date direction:(BOOL)_isNorth {
    
    NSArray *stops;
    
    /*
    // Database uses 0 for north and 1 for south directions. For east and west stations it is 0 for east and 1 for west. 
    // In the app we want the west button on the left and east on the right, so we reverse the direction bool for those 
    // stations. 
    */
    if (_station.eastWest) {
        stops = [TimetableSearchUtility getTimetableWithDate:_date andStation:_station directionIsNorth:!_isNorth];
    } else {
        stops = [TimetableSearchUtility getTimetableWithDate:_date andStation:_station directionIsNorth:_isNorth];
    }
    
    [self playFlipsSound];
    
    float rowHeight = 32.5;
    if (isAutoMode)
        rowHeight = 34;
    
    int rowIndex = 0;
    int rowY = 0;
    
    int cutOffRow;
    if ([[UIScreen mainScreen] applicationFrame].size.height > 480) cutOffRow = 10;
    else cutOffRow = 8;
    
    NSMutableArray *newCells = [NSMutableArray new];
    
    // Draw a cell for each stop
    for (ScheduledStop *currentStop in stops) {
        
        // Increase the height of the last 3 rows by 1px in order to not have to change the size of the n/s buttons
        if (rowIndex == cutOffRow - 3 && !isAutoMode)
            rowHeight += 1.50;
        
        // For each cell, position and populate line/letter, relative time, and absolute time
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, rowY, 272, rowHeight)];
        
        UIImageView *cellBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-background"]];
        cellBg.contentMode = UIViewContentModeScaleToFill;
        cellBg.frame = CGRectMake(0, 0, 272, rowHeight);
        [cellView addSubview:cellBg];
        cellBg.tag = 1;
        
        // Specific line letter for the graphic 
        NSString *line = nil;
        switch (currentStop.line) {
            case kCLine:
                line = @"c";
                break;
            case kDLine:
                line = @"d";
                break;
            case kELine:
                line = @"e";
                break;
            case kFLine:
                line = @"f";
                break;
            case kHLine:
                line = @"h";
                break;
            case kWLine:
                line = @"w";
                break;
        }
        
        NSString *lineGraphicName = [NSString stringWithFormat:@"%@-line-%@", line, _isNorth ? @"circle": @"square"];
        UIImageView *lineGraphic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:lineGraphicName]];
        
        // Center the lineGraphic
        float lineY = (rowHeight - lineGraphic.frame.size.height) / 2;
        lineGraphic.frame = CGRectMake(5, lineY, lineGraphic.frame.size.width, lineGraphic.frame.size.height);
        [cellBg addSubview:lineGraphic];
        
        NSTimeInterval interval = [currentStop.date timeIntervalSinceDate:[NSDate date]];
     
        // If in auto mode display differently
        if (isAutoMode) {
            UILabel *relativeTimeLabel = [UILabel new];
            relativeTimeLabel.frame = CGRectMake(34, 5, 150, 24);
            relativeTimeLabel.backgroundColor = [UIColor clearColor];
            relativeTimeLabel.font = [UIFont boldSystemFontOfSize:16];
            
            if (interval/60 < 1.0) {
                relativeTimeLabel.text = [NSString stringWithFormat:@"< 1 Minute"];
            } else {
                relativeTimeLabel.text = [NSString stringWithFormat:@"in %i Minutes%@", (int)round(interval / 60), currentStop.isHighlighted ? @"*" : @""];
            }
            
            [cellBg addSubview:relativeTimeLabel];
            
            UILabel *absoluteTimeLabel = [UILabel new];
            absoluteTimeLabel.frame = CGRectMake(205, 7, 80, 20);
            absoluteTimeLabel.backgroundColor = [UIColor clearColor];
            absoluteTimeLabel.textColor = [UIColor grayColor];
            absoluteTimeLabel.font = [UIFont systemFontOfSize:14];
          
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Mountain"]];
            [dateFormatter setDateFormat:@"h:mm aa"];
          
            absoluteTimeLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:currentStop.date]];
          
            [cellBg addSubview:absoluteTimeLabel];
            
        // If in manual mode display differently
        } else {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Mountain"]];
            [dateFormatter setDateFormat:@"h:mm aa"];
            
            UILabel *absoluteTimeLabel = [UILabel new];
            absoluteTimeLabel.frame = CGRectMake(34, 5, 150, 24);
            absoluteTimeLabel.backgroundColor = [UIColor clearColor];
            absoluteTimeLabel.font = [UIFont boldSystemFontOfSize:16];
          
            absoluteTimeLabel.text = [NSString stringWithFormat:@"%@%@", [dateFormatter stringFromDate:currentStop.date], currentStop.isHighlighted ? @"*" : @""];
            [cellBg addSubview:absoluteTimeLabel];
        }

        // Tap gesture recognizer for cells
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [cellView setUserInteractionEnabled:YES];
        [cellView addGestureRecognizer:tap];
        
        [newCells addObject:cellView];
        
        rowY += rowHeight;
        rowIndex++;
    }
    
    // If there are currently any cells already showing swap out the old time subview for the new one
    if ([self.view.subviews count] > 0) {
        
        float rowHeight = 32.5;
        if (isAutoMode)
            rowHeight = 34;
        
        int rowIndex = 0;
        int rowY = 0;

        // Iterate over every cell. swap out the old subview with the new subview
        // for each new cell, find the new bgcell
        for(UIView *newRowView in newCells) {
            
            // Increase the height of the last 3 rows by 1px in order to not have
            // to change the size of the n/s buttons
            if (rowIndex == cutOffRow - 3 && !isAutoMode)
                rowHeight += 1.50;
            
            UIView *existingRowView = [self.view.subviews objectAtIndex:rowIndex];
             
            existingRowView.frame = CGRectMake(0, rowY, 272, rowHeight);

            // Get the backgound cell
            UIView *bgViewNew = nil;
            for(UIView *currentBgViewNew in newRowView.subviews) {
                if (currentBgViewNew.tag == 1) {
                    bgViewNew = currentBgViewNew;
                    break;
                }
            }
            
            NSArray *args = [NSArray arrayWithObjects:existingRowView, bgViewNew, nil];
            
            int randomNumber = arc4random() % 100;
            [self performSelector:@selector(performAnimation:) withObject:args
                       afterDelay:(.015 + (randomNumber * .0005))*rowIndex];
            
            rowY += rowHeight;
            rowIndex++;
        }
    } else {
        for(UIView *view in newCells) {
            [self.view addSubview:view]; 
        }
    }
}

- (void)cellTapped:(UIGestureRecognizer*)recognizer {
  // Only respond if we're in the ended state (similar to touchupinside)
  if( [recognizer state] == UIGestureRecognizerStateEnded ) {
    // The View that was tapped
    UIView* cellView = (UIView*)[recognizer view];
    for (UIView *i in cellView.subviews) {
      if (i.tag == 1) {
        for (UIView *j in i.subviews) {
          if([j isKindOfClass:[UILabel class]]){
            UILabel *newLbl = (UILabel *)j;
            if([newLbl.text containsString:@"*"]) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NOTICE"
                                                              message:@"This route does not continue all the way to the end of the line."
                                                             delegate:nil
                                                    cancelButtonTitle:@"Close"
                                                    otherButtonTitles:nil, nil];
              [alert show];
            }
          }
        }
        break;
      }
    }
  }
}

// Perform the cell flipping animation
- (void)performAnimation:(NSArray *)args {
    
    UIView *existingRowView = [args objectAtIndex:0];
    UIView *bgViewNew = [args objectAtIndex:1];
    
    int randomNumber = arc4random() % 100;
    
    // Remove the old bgcell and add the new one
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView transitionWithView:existingRowView 
                      duration:.15 + (randomNumber * .003)
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                        
                        UIView *bgViewOld = nil;
                        for(UIView *oldBgView in existingRowView.subviews) {
                            if (oldBgView.tag == 1) {
                                bgViewOld = oldBgView;
                                break;
                            }
                        }
                        
                        [bgViewOld removeFromSuperview];
                        [existingRowView addSubview:bgViewNew];
                    } 
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

// Clears all of the cells
- (void)clearCells {
    for(UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
}
#warning play the flip sound 
// Play the flipping sound
- (void)playFlipsSound {
    BOOL playSounds = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).playSounds;
    
    if (playSounds) [self.audioPlayer play];    
}

// Keep portrait oreintation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
