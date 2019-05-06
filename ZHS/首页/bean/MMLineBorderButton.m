//
//  MMLineBorderButton.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/4.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "MMLineBorderButton.h"

@implementation MMLineBorderButton

-(void)privateInit{
    self.layer.cornerRadius = _radius;
    self.layer.borderColor = _borderColor.CGColor;
    self.layer.borderWidth = _borderWidth;
    self.clipsToBounds = true;
}
- (void)drawRect:(CGRect)rect {
    [self privateInit];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
