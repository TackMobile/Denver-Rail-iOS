//
//  AutoTableViewCell.m
//  denverrail
//
//  Created by Kelvin Kosbab on 8/3/15.
//  Copyright (c) 2015 Tack Mobile. All rights reserved.
//

#import "AutoTableViewCell.h"

@implementation AutoTableViewCell
@synthesize lineGraphic, relativeTimeLabel, absoluteTimeLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
