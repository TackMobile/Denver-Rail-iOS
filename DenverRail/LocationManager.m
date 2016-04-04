//
//  LocationManager.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile
//

#import "LocationManager.h"
#import "AppDelegate.h"
#import "Constants.h"
@interface LocationManager()

@property (strong) CLLocation *location;
@property (strong) CLLocationManager *locationManager;

@end

@implementation LocationManager

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
		
		// Attempt to fire up location services based on availability and authorization
		[sharedSingleton activateLocationServices];
    }
}

// Returns that one instance
+ (LocationManager *)instance {
    return sharedSingleton;
}

#pragma mark - CLLocationManagerDelegate methods -

// Updates the heading for location 
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.heading = newHeading;
    [[NSNotificationCenter defaultCenter] postNotificationName:DRNotificationName.headingUpdated object:nil];
    
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DRNotificationName.locationUpdated object:nil];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	if ([error code] == kCLErrorDenied) {
		[self locationServicesNotAvailable];
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
		[self locationServicesAvailable];
	}
}

#pragma mark - Activating and deactivating location services methods -

- (void)activateLocationServices {
	
	// Ensure location services are enabled
	if ([CLLocationManager locationServicesEnabled]) {
		
		switch ([CLLocationManager authorizationStatus]) {
			case kCLAuthorizationStatusNotDetermined:
			{
        // User has not been asked to approve access. Ask them.
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8+
          // Sending a message to avoid compile time error
          [sharedSingleton.locationManager requestWhenInUseAuthorization];
        }
				break;
			}
			case kCLAuthorizationStatusRestricted:
			case kCLAuthorizationStatusDenied:
			{
				// App is not authorized to use location services
				[self locationServicesNotAvailable];
				break;
			}
			case kCLAuthorizationStatusAuthorized:
			case kCLAuthorizationStatusAuthorizedWhenInUse:
			{
				// Location services are available and app is allowed to use them
				[self locationServicesAvailable];
				break;
			}
		}
		
	} else {
		
		// Location services are not available
		[self locationServicesNotAvailable];
	}
}

- (void)locationServicesNotAvailable {
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:DRUserDefaultKey.locationDenied];
	[sharedSingleton.locationManager stopUpdatingHeading];
	[sharedSingleton.locationManager stopUpdatingLocation];
	[[NSNotificationCenter defaultCenter] postNotificationName:DRNotificationName.locationDenied object:nil];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note"
                                                    message:@"The application cannot determine your location. Auto mode is disabled."
												   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
	[alert show];
}

- (void)locationServicesAvailable {
	
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:DRUserDefaultKey.locationDenied];
	[sharedSingleton.locationManager startUpdatingLocation];
	[sharedSingleton.locationManager startUpdatingHeading];
	[[NSNotificationCenter defaultCenter] postNotificationName:DRNotificationName.locationApproved object:nil];
}

#pragma mark - Heading and distance methods -

// Shows the display heading calibration
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
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
    double lat1 = (self.location.coordinate.latitude * (3.14159265 / 180));
    double long1 = (self.location.coordinate.longitude * (3.14159265 / 180));
    double lat2 = (self.closestStation.latitude * (3.14159265 / 180));
    double long2 = (self.closestStation.longitude * (3.14159265 / 180));
    
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
    double lat1 = (self.location.coordinate.latitude * (3.14159265 / 180));
    double long1 = (self.location.coordinate.longitude * (3.14159265 / 180));
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

@end
