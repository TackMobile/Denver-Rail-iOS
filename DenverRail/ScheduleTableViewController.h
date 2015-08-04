//
//  ScheduleTableViewController.h
//  denverrail
//
//  Created by Kelvin Kosbab on 8/3/15.
//  Copyright (c) 2015 Tack Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import <AVFoundation/AVFoundation.h>

@interface ScheduleTableViewController : UITableViewController

@property BOOL isNorthAuto;
@property BOOL isNorthManual;
@property BOOL isAutoMode;
@property BOOL firstLoc;
@property (weak) LocationManager *locationManager; //singleton
@property (strong) NSArray *currentStops;
@property (strong) Station *currentManualStation;
@property (strong) NSDate *currentManualDate;
@property (nonatomic,strong) NSMutableArray *scheduleItems;

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
