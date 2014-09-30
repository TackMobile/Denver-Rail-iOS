//
//  LocationManager.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile
//

#import "LocationManager.h"
#import "AppDelegate.h"

@implementation LocationManager
@synthesize locationManager;
@synthesize heading, location;
@synthesize stations, closestStation;

static LocationManager *sharedSingleton;

// Initializes one instance
+ (void)initialize
{
    static BOOL initialized = NO;
    
    if (!initialized) {
        initialized = YES;
        
        sharedSingleton = [LocationManager new];
        
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate]; 
        sharedSingleton.stations = ad.stations;
        
        sharedSingleton.locationManager = [CLLocationManager new];
        
        sharedSingleton.locationManager.delegate = sharedSingleton;
        sharedSingleton.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        sharedSingleton.locationManager.distanceFilter = 50;
		[sharedSingleton.locationManager requestWhenInUseAuthorization];
        [sharedSingleton.locationManager startUpdatingLocation];
        
        if ([CLLocationManager headingAvailable]) {
            [sharedSingleton.locationManager startUpdatingHeading];
        } else {
            NSLog(@"heading info not available");
        }
        
        NSLog(@"location manager initialized");
        
    }
}

// Returns that one instance
+ (LocationManager *)instance {
    return sharedSingleton;
}

// Updates the heading for location 
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.heading = newHeading;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"headingUpdated" object:nil];
    
}

// Updates the location 
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
   
    self.location = newLocation;
       
    // Update closest station
    int i = 0;
    for(Station *station in self.stations) {
        if (!self.closestStation || ([newLocation distanceFromLocation:station.location] < [newLocation distanceFromLocation:self.closestStation.location]))
            self.closestStation = [self.stations objectAtIndex:i];
        i++;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdated" object:nil];
    
    NSLog(@"new location");
}

// Shows the display heading calibration
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    NSLog(@"ignoring request to calibrate heading");
    return NO;
}

// Gets the miles from the closest station 
- (float)distanceInMilesToClosestStation {
    if (!self.location || !self.closestStation)
        return -1;
    
    double meters = [self.location distanceFromLocation:self.closestStation.location];

    // Convert meters to miles
    return (meters * 0.000621371192);
}

// Gets the distance in miles from a specific station
- (float)distanceInMilesToStation:(Station *)_station {
    if (!self.location || !_station)
        return -1;
    
    double meters = [self.location distanceFromLocation:_station.location];
    
    // Convert meters to miles 
    return (meters * 0.000621371192);
}

// True bearing
- (int)bearingInDegreesToClosestStation {
    if (!self.location || !self.closestStation)
        return -1;
    
    // Coordinates in radians
    double lat1 = (location.coordinate.latitude * (3.14159265 / 180));
    double long1 = (location.coordinate.longitude * (3.14159265 / 180));
    double lat2 = (closestStation.latitude * (3.14159265 / 180));
    double long2 = (closestStation.longitude * (3.14159265 / 180));
    
    // Do the calculations to determine direction
    double y = sin(long2-long1)*cos(lat2);
    double x = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(long2-long1);
    double bearingDouble = atan2(y,x);
    
    // Convert to degrees
    bearingDouble = bearingDouble * (180 / 3.14159265);
    
    // Normalize from -180/+180 to compass (0-360)
    bearingDouble = bearingDouble + 360;
    int bearing = round(bearingDouble);
    bearing = bearing % 360;
    return bearing;
}

// Bearings from a specific station 
- (int)bearingInDegreesToStation:(Station *)_station {
    if (!self.location || !_station)
        return -1;
    
    // Coordinates in radians
    double lat1 = (location.coordinate.latitude * (3.14159265 / 180));
    double long1 = (location.coordinate.longitude * (3.14159265 / 180));
    double lat2 = (_station.latitude * (3.14159265 / 180));
    double long2 = (_station.longitude * (3.14159265 / 180));
    
    // Do the calculations to determine direction
    double y = sin(long2-long1)*cos(lat2);
    double x = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(long2-long1);
    double bearingDouble = atan2(y,x);
    
    // Convert to degrees
    bearingDouble = bearingDouble * (180 / 3.14159265);
    
    // Normalize from -180/+180 to compass (0-360)
    bearingDouble = bearingDouble + 360;
    int bearing = round(bearingDouble);
    bearing = bearing % 360;
    return bearing;
}

// If the location manager fails 
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if ([error code] == kCLErrorDenied) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"locationDenied"];
        [sharedSingleton.locationManager stopUpdatingHeading];
        [sharedSingleton.locationManager stopUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationDenied" object:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"The application cannot determine your location. Auto mode is disabled."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
@end
