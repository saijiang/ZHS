//
//  TNUtils.h
//  Tuhu
//
//  Created by 邢小迪 on 15/5/4.
//  Copyright (c) 2015年 telenav. All rights reserved.
//
//****************************************************************************************
// 通用工具类
//****************************************************************************************
//

#import <Foundation/Foundation.h>

@class TNSegueTarget;
@interface TNUtils : NSObject
/**
 *  万能跳转方法
 *
 *  @param taget      跳转规则对象，详细规则参考对象说明
 *  @param navigation 跳转的导航栏控制器
 */
+ (void)customSegueToTarget:(TNSegueTarget *)taget inNavigation:(UINavigationController *)navigation;
@end


@interface UIScrollView (TNRefresh)

- (void)addTNGIFHeaderWithBlock:(void (^)())block;
- (void)addTNGIFFooterWithBlock:(void (^)())block;
- (void)addTNGifHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action;
- (void)addTNGifFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

- (void)addPPHeaderWithBlock:(void (^)())block;
- (void)addPPFooterWithBlock:(void (^)())block;

@end