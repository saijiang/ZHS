//
//  TNResponse.m
//  WeZone
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNResponse.h"
#import "NSObject+Automatic.h"

NSString *const TNResponseCodeFailure = @"0";
NSString *const TNResponseCodeSuccess = @"1";
NSString *const TNResponseCodeAgain = @"2";
NSString *const TNResponseCodeExpiresTimeout = @"3";
NSString *const TNResponseCodeCodeExpiresTimeout = @"4";

@implementation TNResponse

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self decodePropertiesWithDecoder:aDecoder class:[TNResponse class]];
    }
    return self;
}

- (id)initWithJsonValue:(NSDictionary *)jsonValue
{
    if (self = [super initWithJsonValue:jsonValue]) {
        [self decodePropertiesWithJsonValue:jsonValue class:[TNResponse class]];
        if ([self.code isKindOfClass:[NSNumber class]]) {
            self.code = [(NSNumber *)self.code stringValue];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [self encodePropertiesWithCoder:aCoder class:[TNResponse class]];
}

- (void)encodeWithJsonValueContainer:(NSMutableDictionary *)jsonValueContainer
{
    [super encodeWithJsonValueContainer:jsonValueContainer];
    [self encodePropertiesWithJsonValueContainer:jsonValueContainer class:[TNResponse class]];
}

- (BOOL)isSuccess
{
    return [self.code isEqualToString:TNResponseCodeSuccess];
}

@end
