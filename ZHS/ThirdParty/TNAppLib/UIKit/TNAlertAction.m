//
//  TNAlertAction.m
//  WeZone
//
//  Created by DengQiang on 14-9-15.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNAlertAction.h"

@implementation TNAlertAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(TNAlertAction *))handler
{
    TNAlertAction *action = self.new;
    action.title = title;
    action.enabled = YES;
    action.handler = handler;
    return action;
}

- (id)copyWithZone:(NSZone *)zone
{
    TNAlertAction *action = [[self class] allocWithZone:zone];
    action.title = self.title;
    action.enabled = self.enabled;
    action.handler = self.handler;
    return action;
}

@end
