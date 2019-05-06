//
//  TNRoundProgressView.m
//  WeZone
//
//  Created by kiri on 2014-02-11.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNRoundProgressView.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation TNRoundProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = 5.f;
        self.progressTintColor = [UIColor whiteColor];
        self.trackTintColor = [UIColor colorWithWhite:1.f alpha:.1f];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.lineWidth = 5.f;
    self.progressTintColor = [UIColor whiteColor];
    self.trackTintColor = [UIColor colorWithWhite:1.f alpha:.1f];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat lineWidth = self.lineWidth;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (self.bounds.size.width - lineWidth) / 2;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = M_PI * 2 * self.progress + startAngle;
    
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    progressPath.lineWidth = lineWidth;
    progressPath.lineCapStyle = kCGLineCapRound;
    [progressPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [self.progressTintColor set];
    [progressPath stroke];
    
    UIBezierPath *trackPath = [UIBezierPath bezierPath];
    trackPath.lineWidth = lineWidth;
    trackPath.lineCapStyle = kCGLineCapButt;
    startAngle = endAngle;
    endAngle = M_PI_2 * 3;
    [trackPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [self.trackTintColor set];
    [trackPath stroke];
}
@end
