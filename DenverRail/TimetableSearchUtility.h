//
//  TimetableSearchUtility.h
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import <Foundation/Foundation.h>
#import "Station.h"

@interface TimetableSearchUtility : NSObject {

}

+(NSArray *)getTimetableWithStation:(Station *)station directionIsNorth:(BOOL)isNorth;
+(NSArray *)getTimetableWithDate:(NSDate *)date andStation:(Station *)station directionIsNorth:(BOOL)isNorth;
+(BOOL)isHoliday:(NSDate *)date;
+(NSString *)documentsDirectoryPath;

@end
