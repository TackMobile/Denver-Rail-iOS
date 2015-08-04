//
//  ScheduleTableViewController.m
//  denverrail
//
//  Created by Kelvin Kosbab on 8/3/15.
//  Copyright (c) 2015 Tack Mobile. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "TimetableSearchUtility.h"
#import "ScheduledStop.h"
#import <QuartzCore/QuartzCore.h>
#import "Math.h"
#import "AppDelegate.h"
#import "AutoTableViewCell.h"
#import "ManualTableViewCell.h"

@interface ScheduleTableViewController ()
- (void)updateCellsWithStation:(Station *)_station date:(NSDate *)_date direction:(BOOL)_isNorth;
- (void)performAnimation:(NSArray *)args;
@end

@implementation ScheduleTableViewController
@synthesize locationManager, isNorthAuto, isNorthManual, currentStops, isAutoMode, firstLoc;
@synthesize currentManualDate, currentManualStation;
@synthesize audioPlayer;
@synthesize scheduleItems;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  scheduleItems = [NSMutableArray array];
  
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
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionUpdated)
                                               name:@"locationUpdated" object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellsWithNorthDirection)
                                               name:@"updateCellsWithDirectionNorth" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellsWithSouthDirection)
                                               name:@"updateCellsWithDirectionSouth" object:nil];
}

- (void)updateCellsWithNorthDirection {
  [self updateCellsWithDirection:YES];
}

- (void)updateCellsWithSouthDirection {
  [self updateCellsWithDirection:NO];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
  
  int rowIndex = 0;
  for (ScheduledStop *currentStop in stops) {
    [scheduleItems addObject:currentStop];
    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndex:rowIndex];
    [self.tableView insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationMiddle];
    rowIndex++;
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [scheduleItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (isAutoMode)
    return 34;
  else
    return 32.5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:isAutoMode ? @"AutoTableViewCell" : @"ManualTableViewCell" forIndexPath:indexPath];
  NSObject *object = [scheduleItems objectAtIndex:indexPath.row];
  ScheduledStop *item = (ScheduledStop *)object;
  
  // Specific line letter for the graphic
  NSString *line = nil;
  switch (item.line) {
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
  
  NSString *lineGraphicName = [NSString stringWithFormat:@"%@-line-%@", line, item.isNorth ? @"circle": @"square"];
  NSTimeInterval interval = [item.date timeIntervalSinceDate:[NSDate date]];
  
  if (isAutoMode) {
    AutoTableViewCell *autoCell = (AutoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AutoTableViewCell" forIndexPath:indexPath];
    autoCell.lineGraphic.image = [UIImage imageNamed:lineGraphicName];
    
    if (interval/60 < 1.0) {
      autoCell.relativeTimeLabel.text = [NSString stringWithFormat:@"< 1 Minute"];
    } else {
      autoCell.relativeTimeLabel.text = [NSString stringWithFormat:@"in %i Minutes%@", (int)round(interval / 60), item.isHighlighted ? @"*" : @""];
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Mountain"]];
    [dateFormatter setDateFormat:@"h:mm aa"];
    autoCell.absoluteTimeLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:item.date]];
    
    return autoCell;
  }
  ManualTableViewCell *manualCell = (ManualTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ManualTableViewCell" forIndexPath:indexPath];
  manualCell.lineGraphic.image = [UIImage imageNamed:lineGraphicName];
  
  NSDateFormatter *dateFormatter = [NSDateFormatter new];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Mountain"]];
  [dateFormatter setDateFormat:@"h:mm aa"];
  manualCell.absoluteTimeLabel.text = [NSString stringWithFormat:@"%@%@", [dateFormatter stringFromDate:item.date], item.isHighlighted ? @"*" : @""];
  
  return manualCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSObject *object = [scheduleItems objectAtIndex:indexPath.row];
  ScheduledStop *item = (ScheduledStop *)object;
  if (item.isHighlighted) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NOTICE"
                                                    message:@"This route does not continue all the way to the end of the line."
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil, nil];
    [alert show];
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
