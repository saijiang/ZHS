//
//  TNGuideView.h
//  WeZone
//
//  Created by DengQiang on 14-3-27.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNGuideView : UIView<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
+ (TNGuideView *)guideViewWithNibNamed:(NSString *)nibName maxCount:(int)maxCount token:(NSString *)token;
- (void)show;

@end
