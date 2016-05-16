//
//  BaseViewController.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import "BaseViewController.h"
#import "TimetableSearchUtility.h"
#import "LocalizedStrings.h"
#import "ScheduleViewController.h"
#import "LocationManager.h"
#import "Constants.h"
#import "SearchViewController.h"

@interface BaseViewController() <UIPickerViewDelegate, UIPickerViewDataSource, SearchStationDelegate>

@property (strong, nonatomic) IBOutlet UIView *buttonDivider;
@property (strong, nonatomic) IBOutlet UIImageView *whiteBackground;

@property (strong, nonatomic) IBOutlet UIImageView *bottomCapImageView;
@property (strong, nonatomic) IBOutlet UIImageView *shadowAboveButtons;
/**
 Store all content in this subview that will adjust if statusbar is there or not
 */
@property (weak, nonatomic) IBOutlet UIView *contentSubView;

@property (weak) IBOutlet UIImageView *backgroundTop;
@property (weak) IBOutlet UIImageView *arrow;
@property (weak) IBOutlet UIImageView *middleSection;
@property (weak) IBOutlet UIView *stationNameView;
@property (weak) UIView *stationNameLabelToAnimate;
@property (weak) IBOutlet UIView *topSection;
@property (weak) IBOutlet UIButton *autoButton;
@property (weak) IBOutlet UIButton *mapButton;
@property (weak) IBOutlet UIButton *nbButton;
@property (weak) IBOutlet UIButton *sbButton;
@property (weak) IBOutlet UIView *topLevelSlider;
@property (weak) IBOutlet UIPickerView *datePicker;
// Schedule view class for displaying times
@property (strong) ScheduleViewController *scheduleViewController;
// Singleton location manager for getting automatic location
@property (weak) LocationManager *locationManager;
@property (strong) Station *currentStation;
@property (strong) Station *lastUsedManualStation;
@property (strong) NSTimer *currentTimer;
@property (strong) IBOutlet UIView *pickerView;
@property (weak) IBOutlet UILabel *dayOfWeekLabel;
@property (weak) IBOutlet UILabel *timeLabel;
@property (weak) IBOutlet UILabel *distanceLabel;
@property (weak) IBOutlet UIWebView *pdfWebView;
// Search view for when searching for a station
@property (strong) SearchViewController *searchViewController;
@property (nonatomic) BOOL isMapMode;
@property (nonatomic) BOOL isSearchMode;
@property (nonatomic) BOOL isAutoMode;
@property (nonatomic) BOOL isNorth;

@end

@implementation BaseViewController

// When the controller is first called
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.frame = [UIScreen mainScreen].bounds;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDenied) name:DRNotificationName.locationDenied object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationApproved) name:DRNotificationName.locationApproved object:nil];
	
    // Default modes
    self.isAutoMode = YES;
    self.isMapMode = NO;
    
    // Add the schedule view to the view
    self.scheduleViewController = [[ScheduleViewController alloc] initWithNibName:nil bundle:nil];
    self.scheduleViewController.view.frame = CGRectMake(24, 52, self.scheduleViewController.view.frame.size.width, [[UIScreen mainScreen] applicationFrame].size.height - 122);
    [self.topLevelSlider insertSubview:self.scheduleViewController.view belowSubview:self.middleSection];
    
    // Setup and load the search view controller
    self.searchViewController = [[SearchViewController alloc] initWithNibName:nil bundle:nil];
    self.searchViewController.delegate = self;
    self.searchViewController.view.frame = CGRectMake(0,
                                                      CGRectGetMinY(self.contentSubView.frame) + CGRectGetHeight(self.stationNameView.frame),
                                                      CGRectGetWidth(self.contentSubView.frame),
                                                      CGRectGetHeight(self.contentSubView.frame) - CGRectGetHeight(self.stationNameView.frame));
    
    [self.contentSubView insertSubview:self.searchViewController.view belowSubview:self.pdfWebView];
    
    // Load the map
    NSString *path = [[NSBundle mainBundle] pathForResource:@"map" ofType:@"pdf"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.pdfWebView loadRequest:request];
    
    // Setup and begin the flicker timer
    for (int i=0; i<6; i++) {
        UIImageView *brokenLED = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"broken-LED"]];
        [self.contentSubView addSubview:brokenLED];
        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(placeBrokenLED:) userInfo:brokenLED repeats:NO];
    }
    
    // Receive location and heading updates
    self.locationManager = [LocationManager instance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionUpdated) name:DRNotificationName.locationUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headingUpdated) name:DRNotificationName.headingUpdated object:nil];
    
    // Set the initial selected buttons
    self.nbButton.selected = YES;
    self.sbButton.selected = NO;
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // Have the main view that holds everything adjust for status bar
    self.contentSubView.frame = CGRectMake(0,
                                           self.topLayoutGuide.length,
                                           CGRectGetWidth(self.view.frame),
                                           CGRectGetHeight(self.view.frame) - self.topLayoutGuide.length);
}

// Notifying when the view will appear
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    // Adjust for 4 inch iPhones
    [self adjustForFourInchScreen];
}

// Change the status bar contrast
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// Make UI adjustments for larger iPhone screens
-(void)adjustForFourInchScreen{
    
    // Checks to make sure the screen is larger than normal iPhones
    if ([[UIScreen mainScreen] applicationFrame].size.height > 480) {
        
        UIImage *whiteBackground4Inch = [UIImage imageNamed:@"white-background-568h"];
        UIImage *middleBackground4Inch = [UIImage imageNamed:@"middle-568h"];
        UIImage *listBackground4Inch = [UIImage imageNamed:@"list-background-568h"];
        UIImage *nbNormalButton = [UIImage imageNamed:@"bottom-bar-left-button-568h"];
        UIImage *nbSelectedButton = [UIImage imageNamed:@"bottom-bar-left-button-selected-568h"];
        UIImage *sbNormalButton = [UIImage imageNamed:@"bottom-bar-right-button-568h"];
        UIImage *sbSelectedButton = [UIImage imageNamed:@"bottom-bar-right-button-selected-568h"];
        UIImage *shadow = [UIImage imageNamed:@"shadow"];
        
        [self.nbButton setBackgroundImage:nbNormalButton forState:UIControlStateNormal];
        [self.nbButton setBackgroundImage:nbSelectedButton forState:UIControlStateSelected];
        [self.sbButton setBackgroundImage:sbNormalButton forState:UIControlStateNormal];
        [self.sbButton setBackgroundImage:sbSelectedButton forState:UIControlStateSelected];
        
        self.nbButton.frame = CGRectMake(self.nbButton.frame.origin.x, 
                                         self.nbButton.frame.origin.y, nbNormalButton.size.width, nbNormalButton.size.height);
        self.sbButton.frame = CGRectMake(self.sbButton.frame.origin.x - 1,
                                         self.sbButton.frame.origin.y, sbNormalButton.size.width, sbNormalButton.size.height);
        
        
        
        self.whiteBackground.image = whiteBackground4Inch;
        self.middleSection.image = middleBackground4Inch;
        self.backgroundTop.image = listBackground4Inch;
        self.shadowAboveButtons.image = shadow;
        
        CGRect whiteBackgroundFrame = self.whiteBackground.frame;
        CGRect middleBackgroundFrame = self.middleSection.frame;
        CGRect listBackgroundFrame = self.backgroundTop.frame;
        CGRect nbButtonFrame = self.nbButton.frame;
        CGRect sbButtonFrame = self.sbButton.frame;
        CGRect bottomCapFrame = self.bottomCapImageView.frame;
        CGRect buttonDividerFrame = self.buttonDivider.frame;
        CGRect shadowFrame = self.shadowAboveButtons.frame;
        
        whiteBackgroundFrame.size.height = whiteBackground4Inch.size.height;
        middleBackgroundFrame.size.height = middleBackground4Inch.size.height - 6;
        listBackgroundFrame.size.height = listBackground4Inch.size.height - 20;
        bottomCapFrame.origin.y = middleBackgroundFrame.origin.y + middleBackgroundFrame.size.height;
        nbButtonFrame.origin.y = bottomCapFrame.origin.y - self.nbButton.frame.size.height + 13.5; // Height of the shadow
        sbButtonFrame.origin.y = nbButtonFrame.origin.y;
        buttonDividerFrame.origin.y = sbButtonFrame.origin.y;
        buttonDividerFrame.size.height = sbButtonFrame.size.height;
        shadowFrame.origin.y = nbButtonFrame.origin.y - 5;
        
        self.whiteBackground.frame = whiteBackgroundFrame;
        self.middleSection.frame = middleBackgroundFrame;
        self.backgroundTop.frame = listBackgroundFrame;
        self.bottomCapImageView.frame = bottomCapFrame;
        self.buttonDivider.frame = buttonDividerFrame;
        self.nbButton.frame = nbButtonFrame;
        self.sbButton.frame = sbButtonFrame;
        self.shadowAboveButtons.frame = shadowFrame;
    }
}

// Location Denied button was pressed
- (void)locationDenied {
    self.arrow.hidden = YES;
    self.distanceLabel.hidden = YES;
    self.autoButton.alpha = .4;
    
    // This will either switch to manual mode, or do nothing if we're already there
    [self toggleManualMode];
}

- (void)locationApproved {
	self.arrow.hidden = NO;
	self.distanceLabel.hidden = NO;
	self.autoButton.alpha = 1;
}

// This means the position has been updated in either modes
- (void)positionUpdated {
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    float distance = 0.0;
    
    // If in auto locate mode
    if (self.isAutoMode) {
        if (self.locationManager.closestStation != self.currentStation) {
            [self changeLightboardTo:self.locationManager.closestStation];
            [self checkButtons:self.locationManager.closestStation];
        }
        
        distance = [self.locationManager distanceInMilesToClosestStation];
        
    // If in manual mode 
    } else {
        distance = [self.locationManager distanceInMilesToStation:self.currentStation];
    }
    
    // Sets the number of digits to be displayed
    if (distance >= 9)
        [formatter setMaximumFractionDigits:0];
    else
        [formatter setMaximumFractionDigits:1];
  
    if (distance < 0)
        self.distanceLabel.text = [NSString stringWithFormat:@"NA"];
    else
        self.distanceLabel.text = [NSString stringWithFormat:@"%@ miles", [formatter stringFromNumber:[NSNumber numberWithFloat:distance]]];
    
}

// When the display heading for station is updated
- (void)headingUpdated {
    int stationBearing = 0;
    
    if (self.isAutoMode) {
        stationBearing = [self.locationManager bearingInDegreesToClosestStation];
    } else {
        stationBearing = [self.locationManager bearingInDegreesToStation:self.currentStation];
    }
    int currentHeading = self.locationManager.heading.trueHeading;
    int relativeBearing = stationBearing - currentHeading;
    [self rotateArrow:relativeBearing];
}

// Turn the directional arrow
- (void)rotateArrow:(int)degrees {
	self.arrow.transform = CGAffineTransformIdentity;
	self.arrow.transform = CGAffineTransformMakeRotation(degrees*0.0174532925);
}

#pragma mark - Lightboard -

// Shows tap to search if not on a searched station 
-(void)showTapToSearch {
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-to-edit"]];
    
    [self clearLightboard];
    
    // Center
    int x = (182 - iv.frame.size.width) / 2;
    iv.frame = CGRectMake(x, iv.frame.origin.y, iv.frame.size.width, iv.frame.size.height);
    
    // Display
    [self.stationNameView addSubview:iv];
    
    // Swap back to the previous display
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerFireMethod:) userInfo:self.currentStation repeats:NO];
}

// Shows the searched station
-(void)showSearch {
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    
    [self clearLightboard];
    
    // Center
    int x = (182 - iv.frame.size.width) / 2;
    iv.frame = CGRectMake(x, iv.frame.origin.y, iv.frame.size.width, iv.frame.size.height);
    
    // Display
    [self.stationNameView addSubview:iv];
}

// Clears the lightboard display
-(void)clearLightboard {
    
    // Stop animating if necessary
    if (self.currentTimer)
        [self.currentTimer invalidate];
    
    // Clear the board
    for(UIView *view in self.stationNameView.subviews)
        [view removeFromSuperview];
}

// Used to either trigger the next stage of the animation or to reset the lightboard after showing the tap to edit message
// it will reset back to either the station name or to search depending on the current state of the app
-(void)timerFireMethod:(NSTimer*)theTimer {
    if ([[theTimer userInfo] isKindOfClass:[NSNumber class]])
        [self animateLightboard];
    else
        if (self.isSearchMode) {
            [self changeLightboardTo:nil];
        } else {
            [self changeLightboardTo:[theTimer userInfo]];
        }
}

// Change the lightboard to a specific station name
-(void)changeLightboardTo:(Station *)_station {
    [self clearLightboard];
    
    // Nil station means show search

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = _station.columnName ?: @"";
    nameLabel.font = [UIFont fontWithName:DRFontName.lightboard size:32];
    UIColor *lightboardOrange = [UIColor colorWithRed:(255/255.0)
                                                green:(130/255.0)
                                                 blue:(14/255.0)
                                                alpha:1];
    nameLabel.textColor = lightboardOrange;
    nameLabel.layer.shadowColor = lightboardOrange.CGColor;
    nameLabel.layer.shadowRadius = 9.0f;
    nameLabel.layer.shadowOpacity = 1;
    nameLabel.layer.shadowOffset = CGSizeZero;
    nameLabel.layer.masksToBounds = NO;
    [nameLabel sizeToFit];
    
    // Either center the label if it will fit, or scroll it horizontally if not
    if (nameLabel.frame.size.width <= 182) {
        // Center it
        int x = (182 - nameLabel.frame.size.width) / 2;
        nameLabel.frame = CGRectMake(x,
                                     nameLabel.frame.origin.y,
                                     nameLabel.frame.size.width,
                                     nameLabel.frame.size.height);
    } else {
        // Scroll it
        self.stationNameLabelToAnimate = nameLabel;
        self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerFireMethod:)
                                                           userInfo:[NSNumber numberWithBool:YES] repeats:NO];
    }
    
    [self.stationNameView addSubview:nameLabel];
    //Center nameLabel inside of stationNameView
    nameLabel.center = CGPointMake(self.stationNameView.frame.size.width / 2, self.stationNameView.frame.size.height / 2);
    
    self.currentStation = _station;
    
    // Force position update
    [[NSNotificationCenter defaultCenter] postNotificationName:DRNotificationName.headingUpdated object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DRNotificationName.locationUpdated object:nil];
}


// Recursive method to animate the board
-(void)animateLightboard {
    
    if ([self moveLightboardLeftOneLED]) {
        self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(timerFireMethod:)
                                                           userInfo:[NSNumber numberWithBool:YES] repeats:NO];
    } else {
        self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(resetAnimation)
                                                           userInfo:nil repeats:NO];
    }
}

// Resets and returns NO if it's already at the left side
-(BOOL)moveLightboardLeftOneLED {
    //stationNameImageViewToAnimate is nil here
    if (fabs(self.stationNameLabelToAnimate.frame.origin.x - 2) <
       (self.stationNameLabelToAnimate.frame.size.width - self.stationNameView.frame.size.width)) {
        
        self.stationNameLabelToAnimate.frame = CGRectMake(self.stationNameLabelToAnimate.frame.origin.x - 4,
                                                              self.stationNameLabelToAnimate.frame.origin.y,
                                                              self.stationNameLabelToAnimate.frame.size.width,
                                                              self.stationNameLabelToAnimate.frame.size.height);
        return YES;
    } else {
        return NO;
    }
}

// Resets the lightboard animation part 1. 
-(void)resetAnimation {
    self.stationNameLabelToAnimate.hidden = YES;
    
    self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(resetAnimationPart2) userInfo:nil repeats:NO];
}

// Second part of the reset animation
-(void)resetAnimationPart2 {
    self.stationNameLabelToAnimate.frame = CGRectMake(0,
                                                      self.stationNameLabelToAnimate.frame.origin.y,
                                                      self.stationNameLabelToAnimate.frame.size.width,
                                                      self.stationNameLabelToAnimate.frame.size.height);
    self.stationNameLabelToAnimate.hidden = NO;
    
    self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(animateLightboard) userInfo:nil repeats:NO];
}

// Places the BrokenLED Image
-(void)placeBrokenLED:(NSTimer*)theTimer {
    UIImageView *brokenLED = [theTimer userInfo];
    CGRect brokenLEDFrame = brokenLED.frame;
    
    CGRect lightboardFrame = self.stationNameView.frame;
    lightboardFrame = CGRectMake(lightboardFrame.origin.x,
                                 lightboardFrame.origin.y + 9,
                                 lightboardFrame.size.width,
                                 lightboardFrame.size.height - 13);
    
    CGPoint pickAPixel = CGPointMake((int)((lightboardFrame.size.width / 2) * ((float)rand() / RAND_MAX)),
                                     (int)((lightboardFrame.size.height / 2) * ((float)rand() / RAND_MAX)));
    
    // Need to offset position because LED is 3x3 pixels
    CGRect pixelRect = CGRectMake(pickAPixel.x*2 - 1 + lightboardFrame.origin.x,
                                  pickAPixel.y*2 - 1 + lightboardFrame.origin.y,
                                  brokenLEDFrame.size.width,
                                  brokenLEDFrame.size.height);
    
    [brokenLED setFrame:pixelRect];
    
    // Flicker the image
    [NSTimer scheduledTimerWithTimeInterval:.05 
                                     target:self 
                                   selector:@selector(flickerBrokenLED:) 
                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:6],
                                             @"times", brokenLED, @"brokenLED", nil] repeats:NO];
    
    // Set the next flicker : interval between 2 and 5 for next flicker
    float placeInterval = 10 + ((float)rand() / RAND_MAX) * 5;
    [NSTimer scheduledTimerWithTimeInterval:placeInterval target:
     self selector:@selector(placeBrokenLED:) userInfo:brokenLED repeats:NO];
}

// Recursive function that flickers the broken LED
- (void)flickerBrokenLED:(NSTimer*)theTimer {
    NSNumber *times = [[theTimer userInfo] objectForKey:@"times"];
    UIImageView *brokenLED = [[theTimer userInfo] objectForKey:@"brokenLED"];
    
    // Exit condition
    if ([times intValue] == 0)
        return;
    
    [brokenLED setHidden:![brokenLED isHidden]];
    
    // Determine interval for next toggle. .05 if it's hidden. random between .1 and .6 if not
    float flickerInterval = .05;
    if (([times intValue] % 2) == 0)
        flickerInterval = 0.1 + ((float)rand()/RAND_MAX)*1.1;
    
    [NSTimer scheduledTimerWithTimeInterval:flickerInterval 
                                     target:self 
                                   selector:@selector(flickerBrokenLED:) 
                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[times intValue]-1],
                                             @"times", brokenLED, @"brokenLED", nil] repeats:NO];
}

#pragma mark - Buttons -

// When the northbound/westbound button pressed
-(IBAction)northboundTapped {
    self.isNorth = YES;

    self.nbButton.selected = YES;
    self.sbButton.selected = NO;

    [self.scheduleViewController updateCellsWithDirection:self.isNorth];
}

// When the southbound/eastbound button pressed
-(IBAction)southboundTapped {
    
    self.isNorth = NO;

    self.sbButton.selected = YES;
    self.nbButton.selected = NO;
    [self.scheduleViewController updateCellsWithDirection:self.isNorth];
}

// When the map button is pressed
-(IBAction)mapTapped {
    
    // If we are not in the search mode
    if (!self.isSearchMode) {
        
        // Hide the map
        if (self.isMapMode) {
            [UIView beginAnimations:nil context:nil];
            self.topLevelSlider.frame = CGRectMake(0, 44, 320, self.topLevelSlider.frame.size.height);
            [UIView commitAnimations];
            
            [self.mapButton setImage:[UIImage imageNamed:@"map-button"] forState:UIControlStateNormal];
        // Show the map
        } else {
            [UIView beginAnimations:nil context:nil];
            self.topLevelSlider.frame = CGRectMake(0, [[UIScreen mainScreen] applicationFrame].size.height +
                                              self.topSection.frame.size.height, 320, self.topLevelSlider.frame.size.height);
            [UIView commitAnimations];
            
            [self.mapButton setImage:[UIImage imageNamed:@"map-button-selected"] forState:UIControlStateNormal];
        }
        self.isMapMode = !self.isMapMode;
    }
}

// When the auto button pressed
-(IBAction)autoTapped {
    // If in map mode 
    if (!self.isSearchMode && self.isMapMode)
        [self mapTapped];
    
    // If not in search mode toggle manual mode
    if (!self.isSearchMode)
        [self toggleManualMode];
    
    // Checks the buttons to make sure they display the right information
    [self checkButtons:self.currentStation];
}

// Called when the lightboard is tapped
-(IBAction)searchTapped {
    
    // Enable manual mode
    if (self.isAutoMode) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DRUserDefaultKey.searchWillAppear];
        [self toggleManualMode];
    }
    
    // Hide the map if map mode
    if (self.isMapMode) {
        [UIView beginAnimations:nil context:nil];
        self.topLevelSlider.frame = CGRectMake(0, 44, 320, self.topLevelSlider.frame.size.height);
        [UIView commitAnimations];
        
        [self.mapButton setImage:[UIImage imageNamed:@"map-button"] forState:UIControlStateNormal];
        self.isMapMode = NO;
    }
    self.isSearchMode = YES;
    self.pdfWebView.hidden = YES;
    
    [UIView beginAnimations:nil context:nil];
    self.topLevelSlider.frame = CGRectMake(0, 620, 320, self.topLevelSlider.frame.size.height);
    [UIView commitAnimations];
    
    [self.searchViewController showKeyboard];
    
    [self showSearch];
}

// Hides the search display
-(IBAction)hideSearch:(id)sender {
    self.isSearchMode = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDone:finished:context:)];
    self.topLevelSlider.frame = CGRectMake(0, 44, 320, self.topLevelSlider.frame.size.height);
    [UIView commitAnimations];
}

// When the animation is done show map
- (void)animationDone:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    self.pdfWebView.hidden = NO;
}

// When a station is selected in the search view
- (void)searchStationSelected:(Station *)_station {
    self.lastUsedManualStation = _station;
    [self changeLightboardTo:_station];
    [self hideSearch:nil];

    // Check to make sure the right buttons are for that selected station
    [self checkButtons:_station];
    
    self.scheduleViewController.currentManualStation = _station;
    [self.scheduleViewController updateCellsWithDirection:self.isNorth];
    [self.scheduleViewController updateCellsManualMode];
}

/**
 Checks to see if the selected station shows the right buttons. Some need to have
 different directions, and some need to only enable one direction
*/
- (void)checkButtons:(Station *)_station {
    
    /* Checks to see if the selected station has only one direction. This dictates
     database lookups along with direction bound button selections. Ex. 16th and Stout
     only goes one way, so selecting that and then a direction that it does not have will
     cause the app to freeze in database lookup.
     */
    if (_station.southOnly) {
        self.isNorth = NO;
        self.sbButton.selected = YES;
        self.nbButton.selected = NO;
        
        // Disables buttons and changes text color
        [self.nbButton setUserInteractionEnabled:NO];
        [self.nbButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5] forState:UIControlStateNormal];
        [self.sbButton setUserInteractionEnabled:YES];
        [self.sbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else if (_station.northOnly) {
        self.isNorth = YES;
        self.sbButton.selected = NO;
        self.nbButton.selected = YES;
        
        // Disables buttons and changes text color
        [self.sbButton setUserInteractionEnabled:NO];
        [self.sbButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5] forState:UIControlStateNormal];
        [self.nbButton setUserInteractionEnabled:YES];
        [self.nbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        // Enables all buttons
    } else if (!_station.northOnly && !_station.southOnly) {
        
        [self.sbButton setUserInteractionEnabled:YES];
        [self.sbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.nbButton setUserInteractionEnabled:YES];
        [self.nbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
    
    // Changes from north south to east west
    if (_station.eastWest) {
        [self.sbButton setTitle:[LocalizedStrings eastbound] forState:UIControlStateNormal];
        [self.nbButton setTitle:[LocalizedStrings westbound] forState:UIControlStateNormal];
    } else {
        [self.sbButton setTitle:[LocalizedStrings southbound] forState:UIControlStateNormal];
        [self.nbButton setTitle:[LocalizedStrings northbound] forState:UIControlStateNormal];
    }
}

// When the search cancel button pressed
- (void)searchCancelTapped {
    [self changeLightboardTo:self.currentStation];
    [self hideSearch:nil];
}

// When the auto button pressed
-(void)toggleManualMode {
    
    BOOL locationDenied = [[NSUserDefaults standardUserDefaults] boolForKey:DRUserDefaultKey.locationDenied];
    
    // On 3.5 in screens we need to shift the screen 46 pixels.
    // These variables are adjustments depending on 3.5 or 4 inch screen
    int screenAdjust = 46;
    int topAdjust = 0;
    int middleAdjust = 98;
    
    
    // If 4 inch screen slight adjust
    if ([[UIScreen mainScreen] applicationFrame].size.height > 480) {
        screenAdjust = 48;
        topAdjust = 2;
        middleAdjust = 100;
    }
    
    // Switch to manual mode
    if (self.isAutoMode) {
        self.isAutoMode = NO;
        self.scheduleViewController.isAutoMode = NO;
        
        BOOL searchWillAppear = [[NSUserDefaults standardUserDefaults] boolForKey:DRUserDefaultKey.searchWillAppear];
        
        if (!self.lastUsedManualStation && !searchWillAppear)
            [self showTapToSearch];
        
        // Set the picker and current date to now if it hasn't been set before
        if (!self.scheduleViewController.currentManualDate) {
            [self datePickerNowTapped];
            [self updateManualDateLabels];
        }
        
        if (self.lastUsedManualStation)
            [self changeLightboardTo:self.lastUsedManualStation];

        [UIView beginAnimations:nil context:nil];
    
        self.topSection.frame = CGRectMake(0,topAdjust,320, 98);
        self.middleSection.frame = CGRectMake(9, middleAdjust, 302, self.middleSection.frame.size.height - screenAdjust);
        self.backgroundTop.frame = CGRectMake(self.backgroundTop.frame.origin.x,
                                         self.backgroundTop.frame.origin.y + screenAdjust,
                                         self.backgroundTop.frame.size.width,
                                         self.backgroundTop.frame.size.height - screenAdjust);
        
        // Move the schedule view down 46 pixels and make smaller. 48 if 4 inch screen
        self.scheduleViewController.view.frame = CGRectMake(24,
                                         self.scheduleViewController.view.frame.origin.y + screenAdjust,
                                         self.scheduleViewController.view.frame.size.width,
                                         self.scheduleViewController.view.frame.size.height - screenAdjust);
        [UIView commitAnimations];

        if (searchWillAppear) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DRUserDefaultKey.searchWillAppear];
        } else if (!locationDenied) {
            [self checkButtons:self.currentStation];
            [self.scheduleViewController updateCellsManualMode];
        }
        
        [self.autoButton setImage:[UIImage imageNamed:@"auto-off-button"] forState:UIControlStateNormal];
        
    // Switch to auto mode
    } else if (!locationDenied) {
        self.isAutoMode = YES;
        self.scheduleViewController.isAutoMode = YES;

        [self hidePickerView];
        [UIView beginAnimations:nil context:nil];
        self.topSection.frame = CGRectMake(0, -46, 320, 98);
        self.middleSection.frame = CGRectMake(9, 52, 302, self.middleSection.frame.size.height + screenAdjust);
        self.backgroundTop.frame = CGRectMake(self.backgroundTop.frame.origin.x,
                                         self.backgroundTop.frame.origin.y - screenAdjust,
                                         self.backgroundTop.frame.size.width,
                                         self.backgroundTop.frame.size.height + screenAdjust);
        
        // Move the schedule view back up 46 pixels and enlarge 46 pixels
        self.scheduleViewController.view.frame = CGRectMake(24,
                                         self.scheduleViewController.view.frame.origin.y - screenAdjust,
                                         self.scheduleViewController.view.frame.size.width,
                                         self.scheduleViewController.view.frame.size.height + screenAdjust);
        [UIView commitAnimations];
        
        [self.scheduleViewController updateCellsAutoMode];
        
        [self.autoButton setImage:[UIImage imageNamed:@"auto-button"] forState:UIControlStateNormal];
        
        [self changeLightboardTo:self.locationManager.closestStation];
        [self checkButtons:self.locationManager.closestStation];
    }
}

#pragma mark - Time Picker -

// Time selection bar is pressed show time picker
-(IBAction)timeSelectTapped {
    [self showPickerView];
}

// Sets up the time picker
-(IBAction)datePickerNowTapped {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Always use mountain no matter where we are
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:MountainTimeZone]];
    NSDateComponents *nowComponents = [calendar components:
                                       (NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:now];
    
    NSInteger weekday = [nowComponents weekday];
    
    if (weekday == 1)
        [self.datePicker selectRow:2 inComponent:0 animated:YES];
    else if ([TimetableSearchUtility isHoliday:now])
        [self.datePicker selectRow:3 inComponent:0 animated:YES];
    else if (weekday > 1 && weekday < 7) 
        [self.datePicker selectRow:0 inComponent:0 animated:YES];
    else if (weekday == 7)
        [self.datePicker selectRow:1 inComponent:0 animated:YES];

    NSInteger hour = [nowComponents hour];
    
    // AM
    if (hour < 12) {
        [self.datePicker selectRow:0 inComponent:3 animated:YES];
        [self.datePicker selectRow:(hour - 1) inComponent:1 animated:YES];
        
    // If 12 pm
    } else if (hour == 12) {
        [self.datePicker selectRow:11 inComponent:1 animated:YES];
        [self.datePicker selectRow:1 inComponent:3 animated:YES];
    
    // PM
    } else {
        [self.datePicker selectRow:1 inComponent:3 animated:YES];
        [self.datePicker selectRow:(hour - 13) inComponent:1 animated:YES];
    }
    
    NSInteger minute = [nowComponents minute];
    [self.datePicker selectRow:minute inComponent:2 animated:YES];
}

// DatePicker is done 
-(IBAction)datePickerDoneTapped {
    [self hidePickerView];
    [self updateManualDateLabels];
    [self.scheduleViewController updateCellsManualMode];
}

// Update the manual date labels for manual mode
-(void)updateManualDateLabels {
    NSInteger dayOfWeek = [self.datePicker selectedRowInComponent:0];
    NSInteger hour = [self.datePicker selectedRowInComponent:1];
    hour++;
    NSInteger minute = [self.datePicker selectedRowInComponent:2];
    BOOL isPM = [self.datePicker selectedRowInComponent:3] == 0 ? NO : YES;
    
    switch (dayOfWeek) {
        case 0: self.dayOfWeekLabel.text = [LocalizedStrings weekday]; break;
        case 1: self.dayOfWeekLabel.text = [LocalizedStrings friday]; break;
        case 2: self.dayOfWeekLabel.text = [LocalizedStrings saturday]; break;
        case 3: self.dayOfWeekLabel.text = [LocalizedStrings sunday]; break;
        case 4: self.dayOfWeekLabel.text = [LocalizedStrings holiday];
    }
    
    NSString *minuteString = nil;
    
    // Add the 0 if necessary
    if (minute < 10)
        minuteString = [NSString stringWithFormat:@"0%li", (long)minute];
    else
        minuteString = [NSString stringWithFormat:@"%li", (long)minute];
    
    if (isPM)
        self.timeLabel.text = [NSString stringWithFormat:@"%li:%@ PM", (long)hour, minuteString];
    else
        self.timeLabel.text = [NSString stringWithFormat:@"%li:%@ AM", (long)hour, minuteString];
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneWithName:MountainTimeZone]];
    NSDateComponents *comps = [NSDateComponents new];
    [comps setTimeZone:[NSTimeZone timeZoneWithName:MountainTimeZone]];
    
    [comps setYear:2013];
    [comps setMonth:1];
    [comps setCalendar:cal];
    
    if (isPM && hour != 12) {
        [comps setHour:hour+12];
    } else if (!isPM && hour == 12) {
        [comps setHour:0]; 
    } else {
        [comps setHour:hour];
    }
   
    [comps setMinute:minute];
    if (dayOfWeek == 0)
        [comps setDay:2];
    else if (dayOfWeek == 1)
        [comps setDay:7];
    else if (dayOfWeek > 1)
        [comps setDay:1];
    
    NSDate *md = [cal dateFromComponents:comps];

    self.scheduleViewController.currentManualDate = md;
}

// Display the time picker
-(void)showPickerView {
    if (self.pickerView.frame.origin.y >= [[UIScreen mainScreen] applicationFrame].size.height) {
        
        // Offscreen, so slide it up
        CGRect pickerFrame = self.pickerView.frame;
        pickerFrame.origin.y = [[UIScreen mainScreen] applicationFrame].size.height - self.pickerView.frame.size.height;

        [UIView animateWithDuration:0.2
                         animations:^
        {
            self.pickerView.frame = pickerFrame;
        }];
    }
}

// Hides the time picker
-(void)hidePickerView {
    if (self.pickerView.frame.origin.y < [[UIScreen mainScreen] applicationFrame].size.height) {
        
        // Onscreen, so slide it down
        [UIView beginAnimations:nil context:nil];
        self.pickerView.frame = CGRectMake(0, [[UIScreen mainScreen] applicationFrame].size.height,
                                           self.pickerView.frame.size.width,
                                           self.pickerView.frame.size.height);
        [UIView commitAnimations];
    }
}

// Number of components in the time picker should be 4
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 4;
}

// Number of rows per wheel 
- (NSInteger)pickerView: (UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component  { 
	switch (component) {
		case 0: return 5;
		case 1: return 12;
		case 2: return 60;
		case 3: return 2;
	}
    return -1;
}

// Time picker view 
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
	if (component == 0) {
		return 110.0;
	} else if (component == 3) {
		return 55.0;
	}
	return 46;
}

// Return the name of each cell by row and component 
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
	// Iterate through day of week / hour (1-12) / Minute (0-59) / AM or PM
	switch(component) {
		case 0:
			switch (row) {
				case 0: return [LocalizedStrings weekday];
                case 1: return [LocalizedStrings friday];
                case 2: return [LocalizedStrings saturday];
                case 3: return [LocalizedStrings sunday];
                case 4: return [LocalizedStrings holiday];
			}
            
        // Hour
		case 1:
			return [NSString stringWithFormat:@"%li", row+1];
            
        // Minute
		case 2:
            {
                NSString *minute = [NSString stringWithFormat:@"%li", (long)row];
                if ([minute length] < 2)
                    minute = [NSString stringWithFormat:@"0%@", minute];
                return minute;
            }
            
        // Am or PM
		case 3:
			if (row == 0) {
				return @"AM";
			} else {
				return @"PM";
			}
	}
	return nil;
} 

// Keep in portrait 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Remove view 
- (void)viewDidUnload {
    [self setWhiteBackground:nil];
    [self setBottomCapImageView:nil];
    [self setButtonDivider:nil];
    [self setShadowAboveButtons:nil];
    [super viewDidUnload];
}

@end
