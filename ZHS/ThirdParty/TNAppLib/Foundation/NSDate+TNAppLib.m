//
//  NSDate+TNAppLib.m
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "NSDate+TNAppLib.h"

@implementation NSDate (TNAppLib)

+ (NSDate *)dateWithTimeMillisSince1970:(long long)timeMillis
{
    NSTimeInterval timeInterval = timeMillis ;
    return [self dateWithTimeIntervalSince1970:timeInterval];
}

- (int64_t)timeMillisSince1970
{
    return (long long)(1000L * [self timeIntervalSince1970]);
}

+ (int64_t)timeMillisSince1970
{
    return [[self date] timeMillisSince1970];
}

- (BOOL)isToday
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:self];
    NSDate *otherDate = [cal dateFromComponents:components];
    return [today isEqualToDate:otherDate];
}
@end
