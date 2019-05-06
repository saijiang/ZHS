//
//  TNGuideView.m
//  WeZone
//
//  Created by DengQiang on 14-3-27.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNGuideView.h"
#import "TNNibUtil.h"
#import "TNAppLibMacros.h"

#define kUserDefaultGuideViewMaxCountTokenPrefix @"kUserDefaultGuideViewMaxCountToken"

@implementation TNGuideView

+ (TNGuideView *)guideViewWithNibNamed:(NSString *)nibName maxCount:(int)maxCount token:(NSString *)token
{
    if (token) {
        NSString *key = [kUserDefaultGuideViewMaxCountTokenPrefix stringByAppendingString:token];
        NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:key];
        if (count >= maxCount) {
            return nil;
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:count + 1 forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    TNGuideView *guideView = [TNNibUtil loadObjectWithClass:[self class] fromNib:nibName];
    guideView.scrollView.delegate = guideView;
    return guideView;
}

- (void)show
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    self.alpha = 0.f;
    self.frame = window.bounds;
    [window addSubview:self];
    [UIView animateWithDuration:TNAnimateDurationNormal delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.f;
    } completion:nil];
}

- (IBAction)didTapGuideView:(id)sender {
    [UIView animateWithDuration:TNAnimateDurationNormal delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    int index = (offset.x + 160)/320;
    
    self.pageControl.currentPage = index;
}

@end
