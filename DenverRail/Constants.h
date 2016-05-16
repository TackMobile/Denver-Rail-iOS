//
//  Constants.h
//  denverrail
//
//  Created by Naomi Himley on 4/4/16.
//  Copyright © 2016 Tack Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT const struct DRUserDefaultKey {
    __unsafe_unretained NSString *searchWillAppear;
    __unsafe_unretained NSString *locationDenied;
} DRUserDefaultKey;

FOUNDATION_EXPORT const struct DRNotificationName {
    __unsafe_unretained NSString *locationDenied;
    __unsafe_unretained NSString *locationApproved;
    __unsafe_unretained NSString *locationUpdated;
    __unsafe_unretained NSString *headingUpdated;
} DRNotificationName;

FOUNDATION_EXPORT const struct DRFontName {
    __unsafe_unretained NSString *lightboard;
} DRFontName;
