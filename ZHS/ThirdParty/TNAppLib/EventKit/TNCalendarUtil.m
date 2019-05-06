//
//  TNCalendarUtil.m
//  WeZone
//
//  Created by Mr.Wang(Wang Zhao) on 13-12-31.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNCalendarUtil.h"
#import <EventKit/EventKit.h>
#import "TNAppLibMacros.h"
#import "NSDate+TNAppLib.h"

#define ALARM_OFFSET_DEFAULT - 3600//一个小时
#define MIN_ALARM_DIFFERENCE 7200 //2个小时。

@implementation TNCalendarUtil

+ (void)requestPermession
{
    [self requestPermisson:nil];
}

+ (EKEvent*)generateEventInStore:(EKEventStore*)store Title:(NSString*)title date:(NSDate*)date
{
    if(!title) {
        title = @"";
    }
    
    NSDate* scheduleDate = date;
    EKEvent* event = [EKEvent eventWithEventStore: store];
    [event setTitle:[NSString stringWithFormat:@"%@:%@",TNLStr(@"CFBundleDisplayName"), title]];
    [event setStartDate:scheduleDate];
    [event setEndDate:scheduleDate];
    [event setAllDay:NO];
    EKCalendar *calendar = [store defaultCalendarForNewEvents];
    [event setCalendar: calendar];
    
    if([self checkNeedAlarm:date]) {
        EKAlarm* alarm = [EKAlarm alarmWithAbsoluteDate:scheduleDate];
        alarm.relativeOffset = ALARM_OFFSET_DEFAULT;
        [event addAlarm:alarm];
    }
    return event;
}

+ (BOOL)checkNeedAlarm:(NSDate*)date
{
    long long dateMills = [date timeMillisSince1970];
    long long now = [NSDate timeMillisSince1970];
    return dateMills - now >= MIN_ALARM_DIFFERENCE;
}

+ (void)addEventWithTitle:(NSString*)title date:(NSDate*)date completion:(void(^)(BOOL success, NSString* eventIdentifier, NSError* error))completion
{
    [self requestPermisson:^(BOOL granted, EKEventStore *store) {
        if(granted && store) {
            EKEvent* event = [self generateEventInStore:store Title:title date:date];
            NSError* error = nil;
            BOOL success = [store saveEvent:event span:EKSpanThisEvent error:&error];
            if(completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success, event.eventIdentifier, error);
                });
            }
        }
    }];
}

+ (void)requestPermisson:(void(^)(BOOL granted, EKEventStore* store))completion
{
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if(completion) {
            completion(granted, store);
        }
    }];
}

+ (void)removeEventWithIdentifier:(NSString*)identifiler completion:(void(^)(BOOL success, NSError* error))completion
{
    [self requestPermisson:^(BOOL granted, EKEventStore *store) {
        if(granted && store) {
            EKEvent* event = [store eventWithIdentifier:identifiler];
            if(event) {
                NSError* error = nil;
                BOOL success = [store removeEvent:event span:EKSpanThisEvent error:&error];
                if(completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(success, error);
                    });
                }
            }
            else {
                if(completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, nil);
                    });
                }
            }
        }
    }];
}

@end
