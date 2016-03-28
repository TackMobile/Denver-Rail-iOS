//
//  LocalizedStrings.h
//  denverrail
//
//  Created by Naomi Himley on 3/28/16.
//  Copyright © 2016 Tack Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalizedStrings : NSObject

+ (NSString *)weekday;
+ (NSString *)friday;
+ (NSString *)saturday;
+ (NSString *)sunday;
+ (NSString *)holiday;
+ (NSString *)lessThanOneMinute;
+ (NSString *)moreThanOneMinuteFormatString;
+ (NSString *)notice;
+ (NSString *)nonEndOfLineRoute;
+ (NSString *)close;
+ (NSString *)northbound;
+ (NSString *)southbound;
+ (NSString *)eastbound;
+ (NSString *)westbound;
@end
