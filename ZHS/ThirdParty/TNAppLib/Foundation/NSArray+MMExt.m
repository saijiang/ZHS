//
//  NSArray+MMExt.m
//  Mikoto
//
//  Created by xxd on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "NSArray+MMExt.h"
#import "NSSet+MMExt.h"
#import "NSDictionary+MMExt.h"
#import "MMBaseModel.h"

@implementation NSArray (MMExt)

- (BOOL)containsObjectClass:(Class)aClass
{
    __block BOOL has = NO;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:aClass])
        {
            has = YES;
            *stop = YES;
        }
    }];
    return has;
}

- (NSArray *)arrayTransformObjectWithBlock:(id (^)(id obj, NSInteger index, BOOL *stop))block
{
    NSMutableArray* newArr = [@[] mutableCopy];
    if (block)
    {
        [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id newObj = block(obj, idx, stop);
            if (newObj)
            {
                [newArr addObject:newObj];
            }
        }];
    }
    return [NSArray arrayWithArray:newArr];
}

- (NSArray *)arrayWithConditionBlock:(BOOL (^)(id obj, NSInteger index, BOOL *stop))block
{
    NSMutableArray* newArr = [@[] mutableCopy];
    if (block)
    {
        [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (block(obj, idx, stop))
            {
                [newArr addObject:obj];
            }
        }];
    }
    return [NSArray arrayWithArray:newArr];
}

- (NSArray *)arrayWithCleanNSNullValue
{
    NSMutableArray* newArr = [@[] mutableCopy];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[NSNull class]])
        {
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                [newArr addObject:[obj dictionaryWithCleanNSNullValue]];
            }
            else if ([obj isKindOfClass:[NSArray class]])
            {
                [newArr addObject:[obj arrayWithCleanNSNullValue]];
            }
            else if ([obj isKindOfClass:[NSArray class]])
            {
                [newArr addObject:[obj setWithCleanNSNullValue]];
            }
            else
            {
                [newArr addObject:obj];
            }
        }
    }];
    return [NSArray arrayWithArray:newArr];
}

#pragma mark formatter log
- (NSString *)description
{
    return [self customDescription:0];
}

- (NSString *)debugDescription
{
    return [self customDescription:0];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    return [self customDescription:0];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale indent:(NSUInteger)level
{
    return [self customDescription:level];
}

- (NSString *)customDescription:(NSUInteger)indent
{
    NSMutableString* desc = [[NSString stringWithFormat:@"<%@: %p  count = %lu>\n", [self class], self, (unsigned long)self.count] mutableCopy];
    for (int i=0; i<indent; i++)
    {
        [desc appendString:@"\t"];
    }
    [desc appendString:@" [\n"];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        for (int i=0; i<indent; i++)
        {
            [desc appendString:@"\t"];
        }
        if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]])
        {
            [desc appendFormat:@"\t%lu. %@,\n", (unsigned long)idx, [obj descriptionWithLocale:nil indent:indent+1]];
        }
        else if ([obj isKindOfClass:[NSString class]])
        {
            [desc appendFormat:@"\t%lu. \"%@\",\n", (unsigned long)idx, obj];
        }
        else
        {
            [desc appendFormat:@"\t%lu. %@,\n", (unsigned long)idx, obj];
        }
    }];
    for (int i=0; i<indent; i++)
    {
        [desc appendString:@"\t"];
    }
    [desc appendString:@" ]"];
    return desc;
}
@end
