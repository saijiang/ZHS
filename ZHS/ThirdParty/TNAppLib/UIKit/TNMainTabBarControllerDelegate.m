//
//  TNMainTabBarControllerDelegate.m
//  WeZone
//
//  Created by DengQiang on 14-7-2.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNMainTabBarControllerDelegate.h"
#import "TNAppContext.h"
#import "TNFlowUtil.h"

NSString *TNMainTabBarSelectionChangedNotification = @"TNMainTabBarSelectionChangedNotification";

NSString *TNMainTabBarNotificationTabBarControllerKey = @"tabVc";
NSString *TNMainTabBarNotificationSelectedViewControllerKey = @"selectVc";

@interface TNMainTabBarControllerDelegate ()

@property (nonatomic, weak) UIViewController *lastSelectedTab;

@end

@implementation TNMainTabBarControllerDelegate

+ (TNMainTabBarControllerDelegate *)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];

    if (index == 2) {
//        return NO;
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    self.lastSelectedTab = viewController;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TNMainTabBarSelectionChangedNotification object:self userInfo:@{TNMainTabBarNotificationTabBarControllerKey: tabBarController, TNMainTabBarNotificationSelectedViewControllerKey: viewController}];
}

@end
