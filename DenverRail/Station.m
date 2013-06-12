//
//  Station.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import "Station.h"

@implementation Station
@synthesize latitude, longitude, columnName, location, lightboardImage, southOnly, northOnly, eastWest;

- (id)initWithImageName:(NSString *)_imageName columnName:(NSString *)_columnName
               latitude:(double)_latitude logitude:(double)_longitude
              southOnly:(bool)_southOnly northOnly:(bool)_northOnly
               eastWest:(bool)_eastWest {
    
	self.lightboardImage = [UIImage imageNamed:_imageName];
    
    // If no image found
    if(!self.lightboardImage)
        NSLog(@"Error: no image found named %@", _imageName);
	self.columnName = _columnName;
	self.latitude = _latitude;
	self.longitude = _longitude;
    self.southOnly = _southOnly;
    self.northOnly = _northOnly;
    self.eastWest = _eastWest;
	self.location = [[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude];
    
	return self;
}

@end
