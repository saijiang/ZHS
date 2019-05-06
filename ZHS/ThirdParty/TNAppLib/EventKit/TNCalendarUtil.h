//
//  TNCalendarUtil.h
//  WeZone
//
//  Created by Mr.Wang(Wang Zhao) on 13-12-31.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNCalendarUtil : NSObject

+ (void)requestPermession;

+ (void)addEventWithTitle:(NSString*)title date:(NSDate*)date completion:(void(^)(BOOL success, NSString* eventIdentifier, NSError* error))completion;

+ (void)removeEventWithIdentifier:(NSString*)identifiler completion:(void(^)(BOOL success, NSError* error))completion;

@end
