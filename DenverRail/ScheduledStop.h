//
//  ScheduledStop.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <Foundation/Foundation.h>
#import "Station.h"

typedef NS_ENUM(NSUInteger, RailLine) {
    kCLine = 0,
    kDLine,
    kELine,
    kFLine,
    kHLine,
    kWLine
};

@interface ScheduledStop : NSObject

@property (strong, nonatomic) NSDate *date;
@property RailLine line;
@property BOOL isNorth;
@property (strong, nonatomic) Station *station;
@property BOOL isHighlighted;

@end
