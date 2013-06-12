//
//  Station.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Station : NSObject

@property bool southOnly;
@property bool northOnly;
@property bool eastWest;
@property double latitude;
@property double longitude;
@property (strong, nonatomic) NSString *columnName;
@property (strong) CLLocation *location;
@property (strong) UIImage *lightboardImage;

- (id)initWithImageName:(NSString *)_imageName columnName:(NSString *)_columnName latitude:(double)_latitude logitude:(double)_longitude southOnly:(bool)_southOnly northOnly:(bool)_northOnly eastWest:(bool)_eastWest;

@end
