//
//  UINavigationController+MMExt.m
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "UINavigationController+MMExt.h"
#import <objc/runtime.h>

@implementation UINavigationController (MMExt)

#pragma mark - getter
static char mmNavigationControllerUserinfoSign;

- (id)userinfo
{
    return objc_getAssociatedObject(self, &mmNavigationControllerUserinfoSign);
}

#pragma mark - swizzling
+ (void)load
{
    Method systemMethod = class_getInstanceMethod(self, @selector(popViewControllerAnimated:));
    if (!systemMethod) return;
    Method customMethod = class_getInstanceMethod(self, @selector(popViewControllerAnimatedWithNotification:));
    if (!customMethod) return;
    method_exchangeImplementations(systemMethod, customMethod);
    
    systemMethod = class_getInstanceMethod(self, @selector(popToViewController:animated:));
    if (!systemMethod) return;
    customMethod = class_getInstanceMethod(self, @selector(popToViewControllerWithNotification:animated:));
    if (!customMethod) return;
    method_exchangeImplementations(systemMethod, customMethod);

    systemMethod = class_getInstanceMethod(self, @selector(popToRootViewControllerAnimated:));
    if (!systemMethod) return;
    customMethod = class_getInstanceMethod(self, @selector(popToRootViewControllerAnimatedWithNotification:));
    if (!customMethod) return;
    method_exchangeImplementations(systemMethod, customMethod);
}

- (NSArray *)getViewControllersAboveViewController:(UIViewController *)viewController
{
    NSArray *stack = [self.viewControllers mutableCopy];
    __block NSMutableArray *popArray = [@[] mutableCopy];
    __block BOOL found = NO;
    [stack enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        if (vc == viewController)
        {
            found = YES;
            *stop = YES;
        }
        else
        {
            [popArray addObject:vc];
        }
    }];
    return found ? popArray : nil;
}

- (UIViewController *)popViewControllerAnimatedWithNotification:(BOOL)animated
{
    if (self.visibleViewController != self.topViewController)
    {
        return [self popViewControllerAnimatedWithNotification:animated];
    }
    else if (self.viewControllers.count <= 1)
    {
        return [self popViewControllerAnimatedWithNotification:animated];
    }
    else
    {
        UIViewController *willShowVC = [self.viewControllers objectAtIndex:self.viewControllers.count -2];
        if ([willShowVC conformsToProtocol:@protocol(MMNavigationControllerNotificationDelegate)])
        {
            UIViewController<MMNavigationControllerNotificationDelegate> *delegateVC = (UIViewController<MMNavigationControllerNotificationDelegate> *)willShowVC;
            BOOL canPop = YES;
            NSArray *popedVCs = [self getViewControllersAboveViewController:delegateVC];
            if ([delegateVC respondsToSelector:@selector(viewControllerWillShowWithPop:)])
            {
                canPop = [delegateVC viewControllerWillShowWithPop:popedVCs];
            }
            if (canPop)
            {
                UIViewController *popedView = [self popViewControllerAnimatedWithNotification:animated];
                if ([delegateVC respondsToSelector:@selector(viewControllerDidShowWithPop:)])
                {
                    [delegateVC viewControllerDidShowWithPop:popedVCs];
                }
                return popedView;
            }
            else
            {
                return nil;
            }
        }
        else
        {
            return [self popViewControllerAnimatedWithNotification:animated];
        }
    }
    
}

- (NSArray *)popToViewControllerWithNotification:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.visibleViewController != self.topViewController)
    {
        return [self popToViewControllerWithNotification:viewController animated:animated];
    }
    else if (self.viewControllers.count <= 1)
    {
        return [self popToViewControllerWithNotification:viewController animated:animated];
    }
    else
    {
        if ([viewController conformsToProtocol:@protocol(MMNavigationControllerNotificationDelegate)])
        {
            UIViewController<MMNavigationControllerNotificationDelegate> *delegateVC = (UIViewController<MMNavigationControllerNotificationDelegate> *)viewController;
            BOOL canPop = YES;
            NSArray *popedVCs = [self getViewControllersAboveViewController:delegateVC];
            if ([delegateVC respondsToSelector:@selector(viewControllerWillShowWithPop:)])
            {
                canPop = [delegateVC viewControllerWillShowWithPop:popedVCs];
            }
            if (canPop)
            {
                [self popToViewControllerWithNotification:viewController animated:animated];
                if ([delegateVC respondsToSelector:@selector(viewControllerDidShowWithPop:)])
                {
                    [delegateVC viewControllerDidShowWithPop:popedVCs];
                }
                return popedVCs;
            }
            else
            {
                return nil;
            }
        }
        else
        {
            return [self popToViewControllerWithNotification:viewController animated:animated];
        }
    }
}

- (NSArray *)popToRootViewControllerAnimatedWithNotification:(BOOL)animated
{
    if (self.visibleViewController != self.topViewController)
    {
        return [self popToRootViewControllerAnimatedWithNotification:animated];
    }
    else if (self.viewControllers.count <= 1)
    {
        return [self popToRootViewControllerAnimatedWithNotification:animated];
    }
    else
    {
        UIViewController *rootVC = self.viewControllers[0];
        if ([rootVC conformsToProtocol:@protocol(MMNavigationControllerNotificationDelegate)])
        {
            UIViewController<MMNavigationControllerNotificationDelegate> *delegateVC = (UIViewController<MMNavigationControllerNotificationDelegate> *)rootVC;
            BOOL canPop = YES;
            NSArray *popedVCs = [self getViewControllersAboveViewController:delegateVC];
            if ([delegateVC respondsToSelector:@selector(viewControllerWillShowWithPop:)])
            {
                canPop = [delegateVC viewControllerWillShowWithPop:popedVCs];
            }
            if (canPop)
            {
                [self popToRootViewControllerAnimatedWithNotification:animated];
                if ([delegateVC respondsToSelector:@selector(viewControllerDidShowWithPop:)])
                {
                    [delegateVC viewControllerDidShowWithPop:popedVCs];
                }
                return popedVCs;
            }
            else
            {
                return nil;
            }
        }
        else
        {
            return [self popToRootViewControllerAnimatedWithNotification:animated];
        }
    }

}

#pragma mark - publick methods

- (id)getTopViewControllerOfClass:(Class)targetClass
{
    UIViewController *currentController = self.topViewController;
    NSArray *stack = [self.viewControllers mutableCopy];
    __block UIViewController *targetController = nil;
    __block BOOL start = NO;
    [stack enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        if (vc == currentController)
        {
            start = YES;
        }
        else if (start)
        {
            if ([vc isKindOfClass:targetClass])
            {
                targetController = vc;
                *stop = YES;
            }
        }
    }];
    return targetController;
}

- (NSArray *)poptoTargetViewControllerOfClass:(Class)targetClass animated:(BOOL)animated
{
    UIViewController *targetVC = [self getTopViewControllerOfClass:targetClass];
    if (targetVC) {
        return [self popToViewController:targetVC animated:animated];
    }
    else
    {
        return nil;
    }
}

- (NSArray *)popPassViewControllerClass:(Class)passClass animated:(BOOL)animated
{
    UIViewController *currentController = self.topViewController;
    NSArray *stack = [self.viewControllers mutableCopy];
    __block UIViewController *targetController = nil;
    __block BOOL start = NO;
    [stack enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        if (vc == currentController)
        {
            start = YES;
        }
        else if (start)
        {
            if (![vc isKindOfClass:passClass])
            {
                targetController = vc;
                *stop = YES;
            }
        }
    }];
    return [self popToViewController:targetController animated:animated];
}

- (NSArray *)popPassViewControllerClasses:(NSArray*)passClasses animated:(BOOL)animated
{
    UIViewController *currentController = self.topViewController;
    NSArray *stack = [self.viewControllers mutableCopy];
    __block UIViewController *targetController = nil;
    __block BOOL start = NO;
    [stack enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        if (vc == currentController)
        {
            start = YES;
        }
        else if (start)
        {
            if (![passClasses containsObject:NSStringFromClass([vc class])])
            {
                targetController = vc;
                *stop = YES;
            }
        }
    }];
    return [self popToViewController:targetController animated:animated];

}

#pragma mark pop methods with userinfo

id _popWithUserinfo(id userinfo, UINavigationController* navi, id (^block)())
{
    objc_setAssociatedObject(navi, &mmNavigationControllerUserinfoSign, userinfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    id resault = block();
    objc_setAssociatedObject(navi, &mmNavigationControllerUserinfoSign, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return resault;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated withUserinfo:(id)userinfo
{
    return _popWithUserinfo(userinfo, self, ^id{
        return [self popViewControllerAnimated:animated];
    });
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated withUserinfo:(id)userinfo
{
    return _popWithUserinfo(userinfo, self, ^id{
        return [self popToViewController:viewController animated:animated];
    });
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated withUserinfo:(id)userinfo
{
    return _popWithUserinfo(userinfo, self, ^id{
        return [self popToRootViewControllerAnimated:animated];
    });
}

- (NSArray *)poptoTargetViewControllerOfClass:(Class)targetClass animated:(BOOL)animated withUserinfo:(id)userinfo
{
    return _popWithUserinfo(userinfo, self, ^id{
        return [self poptoTargetViewControllerOfClass:targetClass animated:animated];
    });
}

- (NSArray *)popPassViewControllerClass:(Class)passClass animated:(BOOL)animated withUserinfo:(id)userinfo
{
    return _popWithUserinfo(userinfo, self, ^id{
        return [self popPassViewControllerClass:passClass animated:animated];
    });
}

- (NSArray *)popPassViewControllerClasses:(NSArray *)passClasses animated:(BOOL)animated withUserinfo:(id)userinfo
{
    return _popWithUserinfo(userinfo, self, ^id{
        return [self popPassViewControllerClasses:passClasses animated:animated];
    });
}

@end
