//
//  ScheduleViewController.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import <AVFoundation/AVFoundation.h>

@interface ScheduleViewController : UIViewController

@property BOOL isNorthAuto;
@property BOOL isNorthManual;
@property BOOL isAutoMode;
@property BOOL firstLoc;
@property (weak) LocationManager *locationManager; //singleton
@property (strong) NSArray *currentStops;
@property (strong) Station *currentManualStation;
@property (strong) NSDate *currentManualDate;

@property (strong) AVAudioPlayer *audioPlayer;

- (void)updateCellsAutoMode;
- (void)updateCellsManualMode;
- (void)updateCellsAutoModeIsNorth:(BOOL)_isNorth;
- (void)updateCellsManualModeWithStation:(Station *)_station date:(NSDate *)_date;
- (void)updateCellsManualModeWithStation:(Station *)_station date:(NSDate *)_date direction:(BOOL)_isNorth;
- (void)updateCellsWithDirection:(BOOL)_isNorth;
- (void)clearCells;
- (void)playFlipsSound;


@end
