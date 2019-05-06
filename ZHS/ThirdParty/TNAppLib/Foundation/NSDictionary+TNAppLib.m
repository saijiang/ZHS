//
//  NSDictionary+TNAppLib.m
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "NSDictionary+TNAppLib.h"
#import "NSArray+TNAppLib.h"

@implementation NSDictionary (TNAppLib)

- (double)doubleForKey:(id)aKey
{
    return [[self objectForKey:aKey] doubleValue];
}

- (float)floatForKey:(id)aKey
{
    return [[self objectForKey:aKey] floatValue];
}

- (int)intForKey:(id)aKey
{
    return [[self objectForKey:aKey] intValue];
}

- (NSInteger)integerForKey:(id)aKey
{
    return [[self objectForKey:aKey] integerValue];
}

- (long long)longLongForKey:(id)aKey
{
    return [[self objectForKey:aKey] longLongValue];
}

- (BOOL)boolForKey:(id)aKey
{
    return [[self objectForKey:aKey] boolValue];
}

+ (instancetype)dictionaryWithArray:(NSArray *)objects keyGenerator:(id (^)(id, NSUInteger))keyGenerator
{
    return [self dictionaryWithDictionary:[objects dictionaryWithKeyGenerator:keyGenerator]];
}

+ (instancetype)dictionaryWithArray:(NSArray *)objects keyGenerator:(id (^)(id, NSUInteger))keyGenerator valueGenerator:(id (^)(id, NSUInteger))valueGenerator
{
    return [self dictionaryWithDictionary:[objects dictionaryWithKeyGenerator:keyGenerator valueGenerator:valueGenerator]];
}

@end

@implementation NSMutableDictionary (TNAppLib)

- (void)setDouble:(double)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:aKey];
}

- (void)setFloat:(float)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithFloat:value] forKey:aKey];
}

- (void)setInt:(int)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithInt:value] forKey:aKey];
}

- (void)setInteger:(NSInteger)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithInteger:value] forKey:aKey];
}

- (void)setLongLong:(long long)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithLongLong:value] forKey:aKey];
}

- (void)setBool:(BOOL)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithBool:value] forKey:aKey];
}

@end
