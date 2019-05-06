//
//  TNAlertAction.h
//  WeZone
//
//  Created by DengQiang on 14-9-15.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNAlertAction : NSObject <NSCopying>

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(TNAlertAction *action))handler;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, copy) void (^handler)(TNAlertAction *action);

@end
