//
//  TNPlugin.h
//  WeZone
//
//  Created by DengQiang on 14-6-17.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TNPlugin <NSObject>

@optional
- (void)loadPlugin;
- (void)unloadPlugin;

@end
