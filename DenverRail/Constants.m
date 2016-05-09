//
//  Constants.m
//  denverrail
//
//  Created by Naomi Himley on 4/4/16.
//  Copyright © 2016 Tack Mobile. All rights reserved.
//

#import "Constants.h"

const struct DRUserDefaultKey DRUserDefaultKey = {
    .searchWillAppear = @"searchWillAppear",
    .locationDenied = @"locationDenied",
};

const struct DRNotificationName DRNotificationName = {
    .locationDenied = @"locationDenied",
    .locationApproved = @"locationApproved",
    .locationUpdated = @"locationUpdated",
    .headingUpdated = @"headingUpdated",
};

const struct DRFontName DRFontName = {
    .lightboard = @"Lightboard",
};
