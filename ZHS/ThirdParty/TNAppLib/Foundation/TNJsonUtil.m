//
//  TNJsonUtil.m
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNJsonUtil.h"
#import "NSError+TNAppLib.h"

@implementation TNJsonUtil

+ (id)objectWithData:(NSData *)jsonData error:(NSError **)error
{
    if (jsonData.length == 0) {
        if (error) {
            *error = [NSError errorWithCode:TNJsonErrorInputNull localizedDescription:@"JSONData is empty."];
        }
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
}

+ (id)objectWithString:(NSString *)jsonString error:(NSError **)error
{
    return [self objectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] error:error];
}

+ (NSString *)stringWithRawJsonObject:(id)jsonValue prettyPrinted:(BOOL)isPrettyPrinted error:(NSError **)error;
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonValue options:isPrettyPrinted ? NSJSONWritingPrettyPrinted : 0 error:error];
    if (data) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return result;
    }
    return nil;
}

+ (id)objectWithData:(NSData *)jsonData class:(Class)objectClass error:(NSError **)error
{
    if (objectClass == NULL || [self isBasicClass:objectClass]) {
        return [self objectWithData:jsonData error:error];
    }
    if (error) {
        *error = nil;
    }
    if (![objectClass conformsToProtocol:@protocol(TNJsonObject)]) {
        if (error) {
            *error = [NSError errorWithCode:TNJsonErrorUnsupportedClass localizedDescription:@"JSONObjectClass must conform to TNJsonObject protocol."];
        }
        return nil;
    }
    id jsonValue = [self objectWithData:jsonData error:error];
    if (jsonValue) {
        if ([jsonValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *objList = [NSMutableArray array];
            [(NSArray *)jsonValue enumerateObjectsUsingBlock:^(NSDictionary *subJsonValue, NSUInteger idx, BOOL *stop) {
                id obj = [[objectClass alloc] initWithJsonValue:subJsonValue];
                [objList addObject:obj];
            }];
            return objList;
        } else if ([jsonValue isKindOfClass:[NSDictionary class]]) {
            return [[objectClass alloc] initWithJsonValue:jsonValue];
        }
    }
    return nil;
}

+ (id)objectWithString:(NSString *)jsonString class:(Class)objectClass error:(NSError **)error
{
    if (objectClass == NULL || [self isBasicClass:objectClass]) {
        return [self objectWithString:jsonString error:error];
    }
    if (error) {
        *error = nil;
    }
    if (![objectClass conformsToProtocol:@protocol(TNJsonObject)]) {
        if (error) {
            *error = [NSError errorWithCode:TNJsonErrorUnsupportedClass localizedDescription:@"objectClass must conform to TNJsonObject protocol."];
        }
        return nil;
    }
    id jsonValue = [self objectWithString:jsonString error:error];
    if (jsonValue) {
        if ([jsonValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *objList = [NSMutableArray array];
            [(NSArray *)jsonValue enumerateObjectsUsingBlock:^(NSDictionary *subJsonValue, NSUInteger idx, BOOL *stop) {
                id obj = [[objectClass alloc] initWithJsonValue:subJsonValue];
                [objList addObject:obj];
            }];
            return objList;
        } else if ([jsonValue isKindOfClass:[NSDictionary class]]) {
            return [[objectClass alloc] initWithJsonValue:jsonValue];
        }
    }
    return nil;
}

+ (BOOL)isBasicClass:(Class)objectClass
{
    return  [objectClass isSubclassOfClass:[NSNumber class]] || [objectClass isSubclassOfClass:[NSString class]] || [objectClass isSubclassOfClass:[NSArray class]] || [objectClass isSubclassOfClass:[NSDictionary class]];
}

+ (NSString *)stringWithObject:(id)object
{
    return [self stringWithObject:object prettyPrinted:NO error:nil];
}

+ (NSString *)stringWithObject:(id)object prettyPrinted:(BOOL)isPrettyPrinted error:(NSError **)error
{
    NSData *data = [self dataWithObject:object prettyPrinted:isPrettyPrinted error:error];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

+ (NSData *)dataWithObject:(id)object prettyPrinted:(BOOL)isPrettyPrinted error:(NSError **)error
{
    id jsonValue = [self jsonValueWithObject:object error:error];
    if (jsonValue) {
        return [NSJSONSerialization dataWithJSONObject:jsonValue options:isPrettyPrinted ? NSJSONWritingPrettyPrinted : 0 error:error];
    }
    if(error) {
        *error = [NSError errorWithCode:TNJsonErrorUnsupportedClass localizedDescription:@"jsonObject must conform to TNJsonObject protocol or is a valided JSON object."
                               userInfo:@{@"obj": object}];
    }
    return nil;
}

+ (id)jsonValueWithObject:(id)object error:(NSError **)error
{
    if (error) {
        *error = nil;
    }
    if ([NSJSONSerialization isValidJSONObject:object]) {
        return object;
    }
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        __block BOOL hasError = NO;
        [(NSArray *)object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([NSJSONSerialization isValidJSONObject:obj] || [obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSNull class]]) {
                [array addObject:obj];
            } else if ([obj conformsToProtocol:@protocol(TNJsonObject)] && [obj respondsToSelector:@selector(jsonValue)]) {
                [array addObject:[obj jsonValue]];
            } else {
                if (error) {
                    *error = [NSError errorWithCode:TNJsonErrorUnsupportedClass localizedDescription:@"jsonObject must conform to TNJsonObject protocol or is a valided JSON object."
                                           userInfo:@{@"obj": object}];
                }
                *stop = YES;
                hasError = YES;
            }
        }];
        if (hasError) {
            return nil;
        }
        return array;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        __block BOOL hasError = NO;
        [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([NSJSONSerialization isValidJSONObject:obj] || [obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSNull class]]) {
                [dictionary setObject:obj forKey:key];
            } else if ([obj conformsToProtocol:@protocol(TNJsonObject)] && [obj respondsToSelector:@selector(jsonValue)]) {
                [dictionary setObject:[obj jsonValue] forKey:key];
            } else {
                if (error) {
                    *error = [NSError errorWithCode:TNJsonErrorUnsupportedClass localizedDescription:@"jsonObject must conform to TNJsonObject protocol or is a valided JSON object."
                                           userInfo:@{@"key": key, @"obj": obj}];
                }
                *stop = YES;
                hasError = YES;
            }
        }];
        if (hasError) {
            return nil;
        }
        return dictionary;
    } else if ([object conformsToProtocol:@protocol(TNJsonObject)] && [object respondsToSelector:@selector(jsonValue)]) {
        return [(id<TNJsonObject>)object jsonValue];
    }
    if(error) {
        *error = [NSError errorWithCode:TNJsonErrorUnsupportedClass localizedDescription:@"jsonObject must conform to TNJsonObject protocol or is a valided JSON object."
                               userInfo:@{@"obj": object}];
    }
    return nil;
}

+ (id)objectWithJsonValue:(id)jsonValue withClass:(Class)objectClass
{
    if ([jsonValue isKindOfClass:[NSString class]]) {
        jsonValue = [self objectWithString:jsonValue error:nil];
    }
    if ([jsonValue isKindOfClass:[NSDictionary class]]) {
        if ([objectClass conformsToProtocol:@protocol(TNJsonObject)]) {
            return [[objectClass alloc] initWithJsonValue:jsonValue];
        }
    } else if ([jsonValue isKindOfClass:[NSArray class]]) {
        if ([objectClass conformsToProtocol:@protocol(TNJsonObject)]) {
            NSMutableArray *result = [NSMutableArray array];
            [(NSArray *)jsonValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    [result addObject:[[objectClass alloc] initWithJsonValue:obj]];
                }
            }];
            return result;
        }
    }
    return nil;
}

+ (id)copyJsonObject:(id)jsonObject
{
    if (jsonObject == nil) {
        return nil;
    }
    
    NSData *data = [self dataWithObject:jsonObject prettyPrinted:NO error:nil];
    return [self objectWithData:data class:[jsonObject class] error:nil];
}
@end
