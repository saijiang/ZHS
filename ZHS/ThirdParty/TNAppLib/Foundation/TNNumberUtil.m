//
//  TNNumberUtil.m
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNNumberUtil.h"

@implementation TNNumberUtil

+ (BOOL)float:(float)a isEqual:(float)b
{
    return [self float:a compare:b] == NSOrderedSame;
}

+ (BOOL)double:(double)a isEqual:(double)b
{
    return [self double:a compare:b] == NSOrderedSame;
}

#define kFloatSmallValue 0.000001f  // Float accuracy: 6~7,
+ (NSComparisonResult)float:(float)a compare:(float)b
{
    float delta = a - b;
    return delta > kFloatSmallValue ? NSOrderedDescending : delta < -kFloatSmallValue ? NSOrderedAscending : NSOrderedSame;
}

#define kDoubleSmallValue 0.000000000000001 // Double accuracy: 15~16
+ (NSComparisonResult)double:(double)a compare:(double)b
{
    double delta = a - b;
    return delta > kDoubleSmallValue ? NSOrderedDescending : delta < -kDoubleSmallValue ? NSOrderedAscending : NSOrderedSame;
}

+ (BOOL)isDoubleZero:(double)d
{
    return [self double:d isEqual:0.0];
}

+ (BOOL)isFloatZero:(float)f
{
    return [self float:f isEqual:0.f];
}

@end
