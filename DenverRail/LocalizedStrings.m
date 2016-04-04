//
//  LocalizedStrings.m
//  denverrail
//
//  Created by Naomi Himley on 3/28/16.
//  Copyright © 2016 Tack Mobile. All rights reserved.
//

#import "LocalizedStrings.h"

@implementation LocalizedStrings

+ (NSString *)weekday
{
    return NSLocalizedString(@"Weekday",
                             @"Title for 'weekday' choice in schedule type dropdown");
}

+ (NSString *)friday
{
    return NSLocalizedString(@"Friday",
                             @"Title for 'Friday' choice in schedule type dropdown");
}

+ (NSString *)saturday
{
    return NSLocalizedString(@"Saturday",
                             @"Title for 'Saturday' choice in schedule type dropdown");
}

+ (NSString *)sunday
{
    return NSLocalizedString(@"Sunday",
                             @"Title for 'Sunday' choice in schedule type dropdown");
}

+ (NSString *)holiday
{
    return NSLocalizedString(@"Holiday",
                             @"Title for 'Holiday' choice in schedule type dropdown");
}

+ (NSString *)lessThanOneMinute
{
    return NSLocalizedString(@"< 1 Minute",
                             @"Title for less than 1 minute remaining until train arrives");
}

+ (NSString *)moreThanOneMinuteFormatString
{
    return NSLocalizedString(@"in %i Minutes%@",
                             @"Title for more than 1 minute remaining until train arrivers");
}

+ (NSString *)notice
{
    return NSLocalizedString(@"NOTICE",
                             @"Title for Notice Alerts");
}

+ (NSString *)nonEndOfLineRoute
{
    return NSLocalizedString(@"This route does not continue all the way to the end of the line.",
                             @"Explanation text for non end of line routes");
}

+ (NSString *)close
{
    return NSLocalizedString(@"Close",
                             @"Button title for close button");
}

+ (NSString *)northbound
{
    return NSLocalizedString(@"Northbound",
                             @"Button title for north option");
}

+ (NSString *)southbound
{
    return NSLocalizedString(@"Southbound",
                             @"Button title for south option");
}

+ (NSString *)eastbound
{
    return NSLocalizedString(@"Eastbound",
                             @"Button title for east option");
}

+ (NSString *)westbound
{
    return NSLocalizedString(@"Westbound",
                             @"Button title for west option");
}

+ (NSString *)note
{
    return NSLocalizedString(@"Note",
                             @"Title for generic Alert Views");
}

+ (NSString *)cannotDetermineLocation
{
    return NSLocalizedString(@"The application cannot determine your location. Auto mode is disabled.",
                             @"Explanation text for cannot determine location alert");
}

+ (NSString *)ok
{
    return NSLocalizedString(@"OK", @"Button title for OK buttons");
}

@end
