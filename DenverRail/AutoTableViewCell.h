//
//  AutoTableViewCell.h
//  denverrail
//
//  Created by Kelvin Kosbab on 8/3/15.
//  Copyright (c) 2015 Tack Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *lineGraphic;
@property (weak, nonatomic) IBOutlet UILabel *relativeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *absoluteTimeLabel;

@end
