//
//  AppDelegate.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"

@class BaseViewController, WhistleBlowerController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BaseViewController *viewController;

// Holds all of the rail stations
@property (strong, nonatomic) NSMutableArray *stations;

// WhistleBlower easter egg
@property (strong, nonatomic) WhistleBlowerController *whistleBlower;
@property (nonatomic) BOOL playSounds;

- (void)test;
- (void)initStations;

// Set up audio for whistleblower
- (void)initializeAudio;
- (void)initializePreferences;
- (void)configureAudioSession;

@end
