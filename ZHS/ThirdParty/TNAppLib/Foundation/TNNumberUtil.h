//
//  TNNumberUtil.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNNumberUtil : NSObject

+ (BOOL)float:(float)a isEqual:(float)b;

+ (BOOL)double:(double)a isEqual:(double)b;

+ (NSComparisonResult)float:(float)a compare:(float)b;

+ (NSComparisonResult)double:(double)a compare:(double)b;

+ (BOOL)isDoubleZero:(double)d;

+ (BOOL)isFloatZero:(float)f;

@end
