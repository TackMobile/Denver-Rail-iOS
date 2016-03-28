//
//  AppDelegate.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 Holds all of the rail stations
*/
@property (strong, nonatomic) NSMutableArray *stations;
@property (nonatomic) BOOL playSounds;

@end
