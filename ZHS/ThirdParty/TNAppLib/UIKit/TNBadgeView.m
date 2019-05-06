//
//  TNBadgeView.m
//  WeZone
//
//  Created by Frank on 13-12-27.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNBadgeView.h"
#import "TNNibUtil.h"

@interface TNBadgeView()

@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeMoreLabel;

@end

@implementation TNBadgeView

+ (TNBadgeView *)viewFromNib
{
    return [TNNibUtil loadMainObjectFromNib:@"TNBadgeView"];
}

- (void)updateWithBadge:(NSInteger)badge
{
    if (badge <= 0) {
        self.hidden = YES;
    } else if (badge >= 10) {
        self.hidden = NO;
        self.badgeLabel.hidden = YES;
        self.badgeMoreLabel.hidden = NO;
    } else {
        self.hidden = NO;
        self.badgeLabel.hidden = NO;
        self.badgeMoreLabel.hidden = YES;
        self.badgeLabel.text = [NSString stringWithFormat:@"%@", @(badge)];
    }
}

@end
