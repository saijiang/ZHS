//
//  TNSegueTarget.m
//  Tuhu
//
//  Created by 邢小迪 on 15/5/18.
//  Copyright (c) 2015年 telenav. All rights reserved.
//
//****************************************************************************************
// LAST UPDATE 2015-06-29 : 添加 targetParams 类型判断
//****************************************************************************************
//

#import "TNSegueTarget.h"

@implementation TNSegueTarget

+ (NSArray *)uncodeKeys
{
    return nil;
}

+ (NSDictionary *)jsonMap
{
    return nil;
}

#pragma mark - setter
- (void)setTargetParams:(NSMutableDictionary *)targetParams
{
    if ([targetParams isKindOfClass:[NSDictionary class]])
    {
        _targetParams = targetParams;
    }
    else if ([targetParams isKindOfClass:[NSString class]])
    {
        _targetParams = [NSJSONSerialization JSONObjectWithData:[(NSString *)targetParams dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    else
    {
        _targetParams = nil;
    }
}

@end
