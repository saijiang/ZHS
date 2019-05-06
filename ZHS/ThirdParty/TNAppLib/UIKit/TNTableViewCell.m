//
//  TNTableViewCell.m
//  WeZone
//
//  Created by kiri on 2013-10-29.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNTableViewCell.h"
#import "TNAppLibMacros.h"

@implementation TNTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.selectedBackgroundView && self.useGlobalBackground) {
        CGFloat w, a;
        [self.selectedBackgroundView.backgroundColor getWhite:&w alpha:&a];
        if (w < 0.001 && fabs(a - 0.04) < 0.001) {
            self.selectedBackgroundView.backgroundColor = RGB(255, 236, 79);
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.highlightedImageView.highlighted = highlighted;
}

- (void)prepareWithTag:(TNRowTag *)tag
{
}

- (BOOL)useGlobalBackground
{
    return YES;
}

@end
