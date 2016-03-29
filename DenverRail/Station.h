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

- (id)initWithImageName:(NSString *)imageName
             columnName:(NSString *)columnName
               latitude:(double)latitude
              longitude:(double)longitude
              southOnly:(BOOL)southOnly
              northOnly:(BOOL)northOnly
               eastWest:(BOOL)eastWest;

@end
