//
//  UINavigationController+TNAppLib.h
//  WeZone
//
//  Created by DengQiang on 14-6-30.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (TNAppLib)

- (id)nearestViewControllerWithClass:(Class)cls;
- (NSArray *)popToNearestViewControllerWithClass:(Class)cls animated:(BOOL)animated;

@end
