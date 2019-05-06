//
//  UINavigationController+TNAppLib.m
//  WeZone
//
//  Created by DengQiang on 14-6-30.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "UINavigationController+TNAppLib.h"

@implementation UINavigationController (TNAppLib)

- (id)nearestViewControllerWithClass:(Class)cls
{
    UIViewController *currentViewController = self.topViewController;
    NSArray *stack = [self.viewControllers mutableCopy];
    __block BOOL startCalc = NO;
    __block UIViewController *found = nil;
    [stack enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
        if (obj == currentViewController) {
            startCalc = YES;
        } else if (startCalc && [obj isMemberOfClass:cls]) {
            found = obj;
            *stop = YES;
        } else if (startCalc && [obj isKindOfClass:cls] && found == nil) {
            found = obj;
        }
    }];
    return found;
}

- (NSArray *)popToNearestViewControllerWithClass:(Class)cls animated:(BOOL)animated
{
    UIViewController *found = [self nearestViewControllerWithClass:cls];
    if (found) {
        return [self popToViewController:found animated:animated];
    }
    return nil;
}

@end
