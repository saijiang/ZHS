//
//  TNFormatUtil.m
//  TNAppLib
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNFormatUtil.h"
#import "TNJsonUtil.h"
#import "NSDate+TNAppLib.h"
#import "NSString+TNAppLib.h"

@implementation TNFormatUtil

+ (NSString *)formatHTTPParams:(NSDictionary *)HTTPParams
{
    if (HTTPParams.count == 0) {
        return @"";
    }
    NSDictionary *temp = [NSDictionary dictionaryWithDictionary:HTTPParams];
    NSMutableString *result = [NSMutableString string];
    [temp enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        void (^action)(id) = ^(id value){
            NSString *desc = nil;
            if ([value isKindOfClass:[NSString class]]) {
                desc = value;
            } else if ([value isKindOfClass:[NSValue class]]) {
                desc = [value description];
            } else if ([value isKindOfClass:[NSDate class]]) {
                desc = [NSString stringWithFormat:@"%lli", [value timeMillisSince1970]];
            } else if ([value conformsToProtocol:@protocol(TNJsonObject)] || [value isKindOfClass:[NSDictionary class]]) {
                desc = [TNJsonUtil stringWithObject:value prettyPrinted:NO error:nil];
            }
            if (desc) {
                [result appendFormat:@"%@=%@&", key, [desc stringByURLEncoding]];
            }
        };
        
        if ([obj isKindOfClass:[NSArray class]]) {
            [obj enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
                action(value);
            }];
        } else {
            action(obj);
        }
    }];
    if ([result hasSuffix:@"&"]) {
        [result deleteCharactersInRange:NSMakeRange(result.length - 1, 1)];
    }
    return result;
}

+ (NSDictionary *)parseHTTPParams:(NSString *)HTTPParamString
{
    if (HTTPParamString.length == 0) {
        return @{};
    }
    
    NSArray *array = [HTTPParamString componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *keyValue = [obj componentsSeparatedByString:@"="];
        if (keyValue.count == 2) {
            NSString *key = [keyValue firstObject];
            NSString *value = [[keyValue lastObject] stringByURLDecoding];
            [params setObject:value forKey:key];
        }
    }];
    return params;
}

@end
