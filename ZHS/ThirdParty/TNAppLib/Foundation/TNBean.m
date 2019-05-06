//
//  TNBean.m
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNBean.h"

@implementation TNBean

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithJsonValue:(NSDictionary *)jsonValue
{
    if (self = [self init]) {
    }
    return self;
}

- (void)encodeWithJsonValueContainer:(NSMutableDictionary *)jsonValueContainer
{
}

- (NSDictionary *)jsonValue
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self encodeWithJsonValueContainer:result];
    return result;
}

- (BOOL)isTransientForKey:(NSString *)key beanType:(TNBeanType)beanType
{
    return NO;
}

- (BOOL)isCustomForKey:(NSString *)key beanType:(TNBeanType)beanType
{
    return NO;
}

- (Class)classForKey:(NSString *)key
{
    return NULL;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
