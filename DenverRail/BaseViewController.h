//
//  BaseViewController.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <UIKit/UIKit.h>
#import "ScheduleViewController.h"
#import "LocationManager.h"
#import "Station.h"
#import "SearchViewController.h"


// Main view controller and booleans for each state of the application
@interface BaseViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, SearchStationDelegate> {
    BOOL isAutoMode;
    BOOL isNorth;
    BOOL isMapMode;
    BOOL isSearchMode;
}

@property (strong, nonatomic) IBOutlet UIView *buttonDivider;
@property (strong, nonatomic) IBOutlet UIImageView *whiteBackground;

@property (strong, nonatomic) IBOutlet UIImageView *listBackground;
@property (strong, nonatomic) IBOutlet UIImageView *bottomCapImageView;
@property (strong, nonatomic) IBOutlet UIImageView * shadowAboveButtons;

/**
 Store all content in this subview that will adjust if statusbar is there or not
*/
@property (weak, nonatomic) IBOutlet UIView *contentSubView;

@property (weak) IBOutlet UIImageView *backgroundTop;
@property (weak) IBOutlet UIImageView *arrow;
@property (weak) IBOutlet UIImageView *middleSection;
@property (weak) IBOutlet UIView *stationNameView;
@property (weak) UIView *stationNameImageViewToAnimate;
@property (weak) IBOutlet UIView *topSection;
@property (weak) IBOutlet UIButton *autoButton;
@property (weak) IBOutlet UIButton *mapButton;
@property (weak) IBOutlet UIButton *nbButton;
@property (weak) IBOutlet UIButton *sbButton;
@property (weak) IBOutlet UIButton *wbButton;
@property (weak) IBOutlet UIView *topLevelSlider;
@property (weak) IBOutlet UIScrollView *mapScrollView;
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
@property (strong) Station *stationToReturnToAfterSearchCancelled;

-(IBAction)mapTapped;
-(IBAction)autoTapped;
-(IBAction)searchTapped;
-(IBAction)timeSelectTapped;
-(IBAction)northboundTapped;
-(IBAction)southboundTapped;

// Date picker
-(IBAction)datePickerNowTapped;
-(IBAction)datePickerDoneTapped;
-(void)showPickerView;
-(void)hidePickerView;
-(void)updateManualDateLabels;

-(void)toggleManualMode;
-(void)positionUpdated;
-(void)headingUpdated;
-(void)changeLightboardTo:(Station *)_station;
-(void)animateLightboard;
-(BOOL)moveLightboardLeftOneLED;
-(void)resetAnimation;
-(void)resetAnimationPart2;
-(void)rotateArrow:(int)degrees;
-(void)clearLightboard;
-(void)placeBrokenLED:(NSTimer *)theTimer;
-(void)flickerBrokenLED:(NSTimer *)theTimer;
-(void)showTapToSearch;
-(void)showSearch;
-(void)locationDenied;
-(void)locationApproved;
-(void)checkButtons:(Station *)_station;

@end
