//
//  NSDictionary+TNAppLib.h
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSNull+TNAppLib.h"

@interface NSDictionary (TNAppLib)

- (double)doubleForKey:(id)aKey;
- (float)floatForKey:(id)aKey;
- (int)intForKey:(id)aKey;
- (NSInteger)integerForKey:(id)aKey;
- (long long)longLongForKey:(id)aKey;
- (BOOL)boolForKey:(id)aKey;

+ (instancetype)dictionaryWithArray:(NSArray *)objects keyGenerator:(id (^)(id obj, NSUInteger idx))keyGenerator;
+ (instancetype)dictionaryWithArray:(NSArray *)objects keyGenerator:(id (^)(id obj, NSUInteger idx))keyGenerator valueGenerator:(id (^)(id obj, NSUInteger idx))valueGenerator;

@end

@interface NSMutableDictionary (TNAppLib)

- (void)setDouble:(double)value forKey:(id<NSCopying>)aKey;
- (void)setFloat:(float)value forKey:(id<NSCopying>)aKey;
- (void)setInt:(int)value forKey:(id<NSCopying>)aKey;
- (void)setInteger:(NSInteger)value forKey:(id<NSCopying>)aKey;
- (void)setLongLong:(long long)value forKey:(id<NSCopying>)aKey;
- (void)setBool:(BOOL)value forKey:(id<NSCopying>)aKey;

@end
