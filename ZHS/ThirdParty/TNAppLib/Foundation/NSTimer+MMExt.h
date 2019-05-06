//
//  NSTimer+MMExt.h
//  Mikoto
//
//  Created by xxd on 15/4/7.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  Add block method for NSTimer.
//****************************************************************************************
//

#import <Foundation/Foundation.h>
#import "MMConstants.h"

typedef void(^MMTimerCountBLock)(NSTimer *timer, BOOL *stop);
typedef MMResultBlock MMTimerCompletionBlock;
typedef MMDelegateBlock MMTimerLoopBlock;

@interface NSTimer (MMExt)
/**
 *  NSTimer factory method with  repeat count block, creat and retrun new NSTimer instance. You must add the new timer to a run loop, using addTimer:forMode:.
 *
 *  @param ti          The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 *  @param block       Main block, is ^(NSTimer *timer, BOOL *stop){}, do some in it. It will be called when the timer fires until repeat count is equal to repeatCount parameter or set the stop to YES in block
 *  @param userInfo    The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. Get it from timerObject.userInfo. This parameter may be nil.
 *  @param repeatCount Total timer fires count. The timer will be invalidated after fires enough times.
 *  @param completion  Completion callback block, will be called when timer is invalidated. The BOOL parameter in block depends on the timer is compeleted or cancel.
 *
 *  @return New timer instance without added in a run loop
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti forCountBlock:(MMTimerCountBLock)block userInfo:(id)userInfo repeatCount:(NSUInteger)repeatCount completion:(MMTimerCompletionBlock)completion;
/**
 *  NSTimer factory method with  repeat count block, creat and retrun new NSTimer instance. The timer is scheduled on the current run loop in the default mode.
 *
 *  @param ti          The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 *  @param block       Main block, is ^(NSTimer *timer, BOOL *stop){}, do some in it. It will be called when the timer fires until repeat count is equal to repeatCount parameter or set the stop to YES in block
 *  @param userInfo    The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. Get it from timerObject.userInfo. This parameter may be nil.
 *  @param repeatCount Total timer fires count. The timer will be invalidated after fires enough times.
 *  @param completion  Completion callback block, will be called when timer is invalidated. The BOOL parameter in block depends on the timer is compeleted or cancel.
 *
 *  @return  New timer instance already added in current run loop.
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti forCountBlock:(MMTimerCountBLock)block userInfo:(id)userInfo repeatCount:(NSUInteger)repeatCount completion:(MMTimerCompletionBlock)completion;
/**
 *  NSTimer factory method with unstopabel block, creat and retrun new NSTimer instance. You must add the new timer to a run loop, using addTimer:forMode:.
 *
 *  @param ti          The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 *  @param block       Main block, is ^(NSTimer *timer){}, do some in it. It will be called when the timer fires until the time is invalidated.
 *  @param userInfo    The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. Get it from timerObject.userInfo. This parameter may be nil.
 *  @param repeat   If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 *
 *  @return New timer instance without added in a run loop
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti forLoopBlock:(MMTimerLoopBlock)block userInfo:(id)userInfo repeats:(BOOL)repeat;
/**
 *  NSTimer factory method with unstopabel block, creat and retrun new NSTimer instance. The timer is scheduled on the current run loop in the default mode.
 *
 *  @param ti          The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 *  @param block       Main block, is ^(NSTimer *timer){}, do some in it. It will be called when the timer fires until the time is invalidated.
 *  @param userInfo    The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. Get it from timerObject.userInfo. This parameter may be nil.
 *  @param repeat   If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 *
 *  @return  New timer instance already added in current run loop.
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti forLoopBlock:(MMTimerLoopBlock)block userInfo:(id)userInfo repeats:(BOOL)repeat;
@end
