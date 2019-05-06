//
//  DWTabBar.m
//  DWCustomTabBarDemo
//
//  Created by Damon on 10/20/15.
//  Copyright © 2015 damonwong. All rights reserved.
//

#import "DWTabBar.h"

#import "DWPublishButton.h"

#define ButtonNumber 5


@interface DWTabBar ()

@property (nonatomic, strong) DWPublishButton *publishButton;/**< 发布按钮 */

@end

@implementation DWTabBar

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self config];
        DWPublishButton *button = [DWPublishButton publishButton];
        [self addSubview:button];
        self.publishButton = button;
        
    }
    
    return self;
}


- (void)config {
    self.backgroundColor = [UIColor whiteColor];
    UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, kWidth, 2)];
    topLine.image = [UIImage imageNamed:@"tapbar_top_line"];
    [self addSubview:topLine];
}
-(void)layoutSubviews{
    
    
    NSLog(@"%s",__func__);
    
    [super layoutSubviews];
    
    CGFloat barWidth = self.frame.size.width;
    CGFloat barHeight = self.frame.size.height;
    
    CGFloat buttonW = barWidth / ButtonNumber;
    CGFloat buttonH = barHeight - 2;
    CGFloat buttonY = 1;
    
    NSInteger buttonIndex = 0;
    if (kDevice_Is_iPhoneX) {
        self.publishButton.center = CGPointMake(barWidth * 0.5, barHeight * 0.2);
    }
    else
     self.publishButton.center = CGPointMake(barWidth * 0.5, barHeight * 0.3);
    
    for (UIView *view in self.subviews) {
        
        NSString *viewClass = NSStringFromClass([view class]);
        if (![viewClass isEqualToString:@"UITabBarButton"]) continue;

        CGFloat buttonX = buttonIndex * buttonW;
        if (buttonIndex >= 2) { // 右边2个按钮
            if (kDevice_Is_iPhoneX) {
                 buttonX += buttonW -10;
            }
            else
            buttonX += buttonW ;
        }
        //影响底部tabbbar位置
        if (kDevice_Is_iPhoneX) {
            //iPhoneX tabbbar 高出34px
             view.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH-34);
        }
        else
        view.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        
        buttonIndex ++;
        
        
    }
}
/*
-(void)setFrame:(CGRect)frame{
    if (kDevice_Is_iPhoneX) {
        if (frame.origin.y < ([UIScreen mainScreen].bounds.size.height - 83)) {
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - 83;
        }
    }
    [super setFrame:frame];
}
*/
@end
