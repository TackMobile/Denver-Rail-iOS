//
//  ScheduledStop.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <Foundation/Foundation.h>
#import "Station.h"

typedef enum {
    kCLine,
    kDLine,
    kELine,
    kFLine,
    kHLine,
    kWLine
} RailLine;

@interface ScheduledStop : NSObject

@property (strong, nonatomic) NSDate *date;
@property RailLine line;
@property BOOL isNorth;
@property (strong, nonatomic) Station *station;

@end
