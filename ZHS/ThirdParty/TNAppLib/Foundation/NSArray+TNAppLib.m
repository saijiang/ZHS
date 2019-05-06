//
//  NSArray+TNAppLib.m
//  TNAppLib
//
//  Created by kiri on 2013-11-21.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "NSArray+TNAppLib.h"

@implementation NSArray (TNAppLib)

+ (instancetype)arrayWithArray:(NSArray *)array converter:(id (^)(id))converter
{
    return [self arrayWithArray:array converter:converter nilValue:nil];
}

+ (instancetype)arrayWithArray:(NSArray *)array converter:(id (^)(id))converter nilValue:(id)nilValue
{
    if (array.count == 0) {
        return [self arrayWithArray:array];
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id obj2 = converter(obj);
        if (obj2) {
            [temp addObject:obj2];
        } else if (nilValue != nil) {
            [temp addObject:nilValue];
        }
    }];
    
    return [self arrayWithArray:temp];
}

- (instancetype)arrayWithConverter:(id (^)(id))converter
{
    return [self arrayWithConverter:converter nilValue:nil];
}

- (instancetype)arrayWithConverter:(id (^)(id))converter nilValue:(id)nilValue
{
    return [[self class] arrayWithArray:self converter:converter nilValue:nilValue];
}

- (NSMutableDictionary *)dictionaryWithKeyGenerator:(id (^)(id, NSUInteger))keyGenerator
{
    return [self dictionaryWithKeyGenerator:keyGenerator valueGenerator:^id(id obj, NSUInteger idx) {
        return obj;
    }];
}

- (NSMutableDictionary *)dictionaryWithKeyGenerator:(id (^)(id, NSUInteger))keyGenerator valueGenerator:(id (^)(id, NSUInteger))valueGenerator
{
    if (keyGenerator == nil || valueGenerator == nil) {
        return [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id key = keyGenerator(obj, idx);
        id value = valueGenerator(obj, idx);
        if (key && value) {
            [result setObject:value forKey:key];
        }
    }];
    return result;
}

@end