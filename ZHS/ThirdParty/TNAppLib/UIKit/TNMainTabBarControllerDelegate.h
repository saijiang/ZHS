//
//  TNMainTabBarControllerDelegate.h
//  WeZone
//
//  Created by DengQiang on 14-7-2.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *TNMainTabBarSelectionChangedNotification;
extern NSString *TNMainTabBarNotificationTabBarControllerKey;
extern NSString *TNMainTabBarNotificationSelectedViewControllerKey;

@interface TNMainTabBarControllerDelegate : NSObject <UITabBarControllerDelegate>

+ (TNMainTabBarControllerDelegate *)sharedInstance;

@end