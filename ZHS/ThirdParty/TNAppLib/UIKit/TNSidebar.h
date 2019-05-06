//
//  TNSidebar.h
//  WeZone
//
//  Created by DengQiang on 14-5-26.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TNSidebar <NSObject>

@optional
- (void)sidebarWillAppear:(BOOL)animated;
- (void)sidebarDidAppear:(BOOL)animated;
- (void)sidebarWillDisappear:(BOOL)animated;
- (void)sidebarDidDisappear:(BOOL)animated;

@end
