//
//  Station.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import "Station.h"

@implementation Station

- (id)initWithImageName:(NSString *)imageName
             columnName:(NSString *)columnName
               latitude:(double)latitude
               longitude:(double)longitude
              southOnly:(BOOL)southOnly
              northOnly:(BOOL)northOnly
               eastWest:(BOOL)eastWest {
    self = [super init];
    if (self) {
        _columnName = columnName;
        _latitude = latitude;
        _longitude = longitude;
        _southOnly = southOnly;
        _northOnly = northOnly;
        _eastWest = eastWest;
        _lightboardImage = [UIImage imageNamed:imageName];
        _location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    }
    
	return self;
}

@end
