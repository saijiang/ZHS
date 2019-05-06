//
//  NSDictionary+MMExt.m
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "NSDictionary+MMExt.h"
#import "NSArray+MMExt.h"
#import "NSSet+MMExt.h"
#import "MMBaseModel.h"

@implementation NSDictionary (MMExt)

- (NSDictionary*)dictionaryWithMapKeysWithMap:(NSDictionary *)map
{
    if (!map)
    {
        return [NSDictionary dictionaryWithDictionary:self];
    }
    NSMutableDictionary* mappedDic = [@{} mutableCopy];
    [map enumerateKeysAndObjectsUsingBlock:^(id mapedKey, id originalKey, BOOL *stop) {
        if ([self valueForKeyPath:originalKey])
        {
            [mappedDic setObject:[self valueForKeyPath:originalKey] forKey:mapedKey];
        }
    }];
    return mappedDic;
}

- (NSDictionary *)dictionaryWithMapKeysWithSameValue:(NSDictionary *)aDic
{
    NSMutableDictionary* mappingDic = [@{} mutableCopy];
    if (aDic)
    {
        [aDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
           [self enumerateKeysAndObjectsUsingBlock:^(id selfKey, id selfObj, BOOL *stop) {
               if ([obj isEqual:selfObj])
               {
                   [mappingDic setObject:key forKey:selfKey];
               }
           }];
        }];
    }
    return mappingDic;
}

- (NSDictionary *)dictionaryWithCleanNSNullValue
{
    NSMutableDictionary* newDic = [@{} mutableCopy];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSNull class]])
        {
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                [newDic setObject:[obj dictionaryWithCleanNSNullValue] forKey:key];
            }
            else if ([obj isKindOfClass:[NSArray class]])
            {
                [newDic setObject:[obj arrayWithCleanNSNullValue] forKey:key];
            }
            else if ([obj isKindOfClass:[NSSet class]])
            {
                [newDic setObject:[obj setWithCleanNSNullValue] forKey:key];
            }
            else
            {
                [newDic setObject:obj forKey:key];
            }
        }
    }];
    return newDic;
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
    NSMutableString* desc = [[NSString stringWithFormat:@"<%@: %p  keysCount = %lu>\n", self.class, self, (unsigned long)self.allKeys.count] mutableCopy];
    for (int i=0; i<indent; i++)
    {
        [desc appendString:@"\t"];
    }
    [desc appendString:@" {\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        for (int i=0; i<indent; i++)
        {
            [desc appendString:@"\t"];
        }
        if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[MMBaseModel class]])
        {
            [desc appendFormat:@"\t\"%@\" : %@,\n", key, [obj descriptionWithLocale:nil indent:indent+1]];
        }
        else if ([obj isKindOfClass:[NSString class]])
        {
            [desc appendFormat:@"\t\"%@\" : \"%@\",\n", key, obj];
        }
        else
        {
            [desc appendFormat:@"\t\"%@\" : %@,\n", key, obj];
        }
    }];
    for (int i=0; i<indent; i++)
    {
        [desc appendString:@"\t"];
    }
    [desc appendString:@" }"];
    return desc;
}
@end
