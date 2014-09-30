//
//  TimetableSearchUtility.m
//  DenverRail
//
// 2008 - 2013 Tack Mobile.
//

#import "TimetableSearchUtility.h"
#import "FMDatabase.h"
#import "ScheduledStop.h"
#import "NSString+Common.h"

@implementation TimetableSearchUtility

// Gets the times of that station 
+(NSArray *)getTimetableWithStation:(Station *)station directionIsNorth:(BOOL)isNorth {
    return [self getTimetableWithDate:[NSDate new] andStation:station directionIsNorth:isNorth];
}

// Gets the time stations of the station with date and direction
+(NSArray *)getTimetableWithDate:(NSDate *)date andStation:(Station *)station directionIsNorth:(BOOL)isNorth {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"US/Mountain"]];
    NSDateComponents *dateComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [dateComponents weekday];

    NSString *scheduleCode = @"MT";
    
    if (weekday == 7)
        scheduleCode = @"SA";
    else if (weekday == 6)
        scheduleCode = @"FR";
    else if (weekday == 1 || [TimetableSearchUtility isHoliday:date])
        scheduleCode = @"SU";
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Mountain"]];
    [dateFormatter setDateFormat:@"HHmmss"];
    NSString *timeString = [dateFormatter stringFromDate:date];
    int timeInt = [timeString intValue];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"schedules" ofType:@"sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    
    if (![db open]) {
        NSLog(@"error opening database");
        return nil;
    }
    
    NSString *limit;
    int limitInt;
    if ([[UIScreen mainScreen] applicationFrame].size.height > 480) limitInt = 11;
    else limitInt = 9;
    
    limit = [NSString stringWithFormat:@"%i", limitInt];
  
    NSLog(@"SELECT departure_time, route_id FROM schedule WHERE stop_name = \"%@\" AND direction_id = %i AND departure_time > %i AND service_id = \"%@\" ORDER BY departure_time LIMIT 11", station.columnName, isNorth ? 0 : 1, timeInt, scheduleCode);
    
    FMResultSet *rs = [db executeQueryWithFormat:@"SELECT departure_time, route_id FROM schedule WHERE stop_name = %@ AND direction_id = %i AND departure_time > %i AND service_id = %@ ORDER BY departure_time LIMIT %@", station.columnName, isNorth ? 0 : 1, timeInt, scheduleCode, limit];
    
    NSLog(@"Query Error: %@", [db lastErrorMessage]);
    
    NSMutableArray *stops = [NSMutableArray new];
    while ([rs next]) {
        NSLog(@"ROW: %i, %@", [rs intForColumn:@"departure_time"], [rs stringForColumn:@"route_id"]);

        int timeInt = [rs intForColumn:@"departure_time"];
        NSString *routeString = [rs stringForColumn:@"route_id"]; // c d e f h w
        
        RailLine line = kCLine;
        if ([routeString contains:@"D"])
            line = kDLine;
        else if ([routeString contains:@"E"])
            line = kELine;
        else if ([routeString contains:@"F"])
            line = kFLine;
        else if ([routeString contains:@"H"])
            line = kHLine;
        else if ([routeString contains:@"W"])
            line = kWLine;
        
        // Assume today
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Mountain"]];
        [dateFormatter setDateFormat:@"HHmmss"];
        
        NSString *dateString = nil;
        if (timeInt > 239999)
            timeInt -= 240000;
        
        NSLog(@"time int: %i", timeInt);
        
        if (timeInt > 99999)
            dateString = [NSString stringWithFormat:@"%i", timeInt];
        else if (timeInt < 1000)
            dateString = [NSString stringWithFormat:@"000%i", timeInt];
        else if (timeInt < 10000)
            dateString = [NSString stringWithFormat:@"00%i", timeInt];
        else
            dateString = [NSString stringWithFormat:@"0%i", timeInt];
        
        NSDate *dateFromDBHMS = [dateFormatter dateFromString:dateString];
        
        NSDateComponents *dateComponentsFromDBHMS = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                fromDate:dateFromDBHMS];
        
        NSDate *today = [NSDate date];
        NSDateComponents *todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                        fromDate:today];
        
        [todayComponents setHour:[dateComponentsFromDBHMS hour]];
        [todayComponents setMinute:[dateComponentsFromDBHMS minute]];
        [todayComponents setSecond:[dateComponentsFromDBHMS second]];
        NSDate *dbDate = [calendar dateFromComponents:todayComponents];
        
        if ([today compare:dbDate] == NSOrderedDescending) {
            
            // Prevent minutes from appearing negative
            dbDate = [dbDate dateByAddingTimeInterval:86400.0];
        }
        
        NSLog(@"adding scheduled stop with date: %@", [dbDate description]);

        ScheduledStop *stop = [ScheduledStop new];
        stop.line = line;
        stop.date = dbDate;
        stop.isNorth = isNorth;
        stop.station = station;
        [stops addObject:stop];
     
    }
    
    // Done with db
    [rs close];
    [db close];
    
    if ([stops count] < limitInt) {
        NSDate *today = [NSDate date];
        NSDateComponents *todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
        [todayComponents setHour:0];
        [todayComponents setMinute:0];
        [todayComponents setSecond:1];
        NSDate *newDate = [calendar dateFromComponents:todayComponents];
        NSMutableArray *tomorrowStops = [[NSMutableArray alloc] initWithArray:[self getTimetableWithDate:newDate andStation:station directionIsNorth:isNorth]];
        [tomorrowStops removeObjectsInArray:stops];
        [stops addObjectsFromArray:tomorrowStops];
        if ([stops count] > limitInt) {
            for (int i=[stops count]-1; i > 8; i--)
                [stops removeLastObject];
        }
    }
    
    if ([stops count] > 0)
        return stops;
    return nil;
    
}

// US federal holidays (RTD holidays)
+(BOOL)isHoliday:(NSDate *)date {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSWeekOfMonthCalendarUnit |
                                                             NSMonthCalendarUnit |
                                                             NSDayCalendarUnit |
                                                             NSWeekdayCalendarUnit) fromDate:date];

    NSInteger day = [dateComponents day];
    NSInteger month = [dateComponents month];
    NSInteger weekday = [dateComponents weekday];
    NSInteger weekOfMonth = [dateComponents weekOfYear];

    // New years
    if (day == 1 && month == 1)
        return YES;
    
    // Independence day
    if (day == 4 && month == 7)
        return YES;
    
    // Christmas
    if (day == 25 && month == 12)
        return YES;
    
    // Memorial day (last monday of may)
    if (month == 5 && weekday == 2 && weekOfMonth > 3) {
        
        // Add a week and see if we end up in june
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:7];
        NSDate *newDate = [calendar dateByAddingComponents:comps toDate:date  options:0];
        NSDateComponents *newDateComponents = [calendar components:(NSMonthCalendarUnit) fromDate:newDate];
        
        if ([newDateComponents month] == 6)
            return YES;
    }
    
    // Labor day (first monday of september)
    if (month == 9 && weekday == 2 && weekOfMonth < 3) {
        
        // Subtract a week and see if we end up in august
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:-7];
        NSDate *newDate = [calendar dateByAddingComponents:comps toDate:date  options:0];
        NSDateComponents *newDateComponents = [calendar components:(NSMonthCalendarUnit) fromDate:newDate]; 
        
        if ([newDateComponents month] == 8)
            return YES;
    }
    
    // Thanksgiving (last thursday of november)
    if (month == 11 && weekday == 5 && weekOfMonth > 3) {
        // Add a week and see if we end up in december
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:7];
        NSDate *newDate = [calendar dateByAddingComponents:comps toDate:date  options:0];
        NSDateComponents *newDateComponents = [calendar components:(NSMonthCalendarUnit) fromDate:newDate]; 
        
        if ([newDateComponents month] == 12)
            return YES;
    }
    return NO;
}

// Directory path
+(NSString *)documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return documentsDirectoryPath;
}  
@end
