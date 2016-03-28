//
//  LocationManager.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Station.h"

@interface LocationManager : NSObject <CLLocationManagerDelegate> 

@property (strong) CLHeading *heading;
@property (strong) Station *closestStation;
@property (weak) NSMutableArray *stations;

+ (LocationManager *)instance;

- (float)distanceInMilesToClosestStation;
- (int)bearingInDegreesToClosestStation;
- (float)distanceInMilesToStation:(Station *)_station;
- (int)bearingInDegreesToStation:(Station *)_station;

@end
