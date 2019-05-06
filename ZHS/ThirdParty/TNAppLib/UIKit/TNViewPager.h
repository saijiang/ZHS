//
//  TNViewPager.h
//  WeZone
//
//  Created by Mr.Wang(Wang Zhao) on 14-1-3.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TNViewPager;

@protocol TNViewPagerDataResource <NSObject>

@required
- (NSInteger)numberOfPages;
- (UIView *)viewPager:(TNViewPager*)viewPager pageAtIndex:(NSInteger)index;

@end

@protocol TNViewPagerDelegate <NSObject>

@optional
- (void)viewPager:(TNViewPager*)viewPager didClickAtIndex:(NSUInteger)index;

@end

/*!
 * 目前不循环滚动是在循环滚动的基础上做限制实现的，会多占一些内存。 //TODO:WangZhao
 */
@interface TNViewPager : UIView

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic) BOOL scrollCircularly;
@property (nonatomic) BOOL onePageScrollEnable;
@property (nonatomic) BOOL showPageControl;
@property (nonatomic, weak) IBOutlet id<TNViewPagerDataResource> dataResource;
@property (nonatomic, weak) IBOutlet id<TNViewPagerDelegate> delegate;

- (void)reloadData;
- (id)dequeueReusableViewWithIdentifier:(NSString *)identifier;

- (void)scrollToNextPage;

- (void)startAutoScroll:(NSTimeInterval)timeInterval;
- (void)stopAutoScroll;
@end

