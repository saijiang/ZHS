//
//  NSArray+TNAppLib.h
//  TNAppLib
//
//  Created by kiri on 2013-11-21.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TNAppLib)

+ (instancetype)arrayWithArray:(NSArray *)array converter:(id (^)(id src))converter;
+ (instancetype)arrayWithArray:(NSArray *)array converter:(id (^)(id src))converter nilValue:(id)nilValue;

- (instancetype)arrayWithConverter:(id (^)(id src))converter;
- (instancetype)arrayWithConverter:(id (^)(id src))converter nilValue:(id)nilValue;

- (NSMutableDictionary *)dictionaryWithKeyGenerator:(id (^)(id obj, NSUInteger idx))keyGenerator;
- (NSMutableDictionary *)dictionaryWithKeyGenerator:(id (^)(id obj, NSUInteger idx))keyGenerator valueGenerator:(id (^)(id obj, NSUInteger idx))valueGenerator;

@end
