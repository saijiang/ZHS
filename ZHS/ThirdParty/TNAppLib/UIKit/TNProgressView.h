//
//  TNProgressView.h
//  FitTime
//
//  Created by DengQiang on 14-5-28.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNProgressView : UIControl

@property (nonatomic) CGFloat progress;
@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *trackTintColor;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated maxDuration:(NSTimeInterval)maxDuration completion:(void (^)(void))completion;
- (void)stopAnimating;

@end
