//
//  TNTransferObject.m
//  TTX
//
//  Created by zhdong on 13-11-11.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNTransferObject.h"
#import "NSObject+Automatic.h"

@implementation TNTransferObject

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self decodePropertiesWithDecoder:aDecoder class:[TNTransferObject class]];
    }
    return self;
}

- (id)initWithJsonValue:(NSDictionary *)jsonValue
{
    if (self = [super initWithJsonValue:jsonValue]) {
        [self decodePropertiesWithJsonValue:jsonValue class:[TNTransferObject class]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [self encodePropertiesWithCoder:aCoder class:[TNTransferObject class]];
}

- (void)encodeWithJsonValueContainer:(NSMutableDictionary *)jsonValueContainer
{
    [super encodeWithJsonValueContainer:jsonValueContainer];
    [self encodePropertiesWithJsonValueContainer:jsonValueContainer class:[TNTransferObject class]];
}

@end
