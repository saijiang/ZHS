//
//  NSTimer+MMExt.m
//  Mikoto
//
//  Created by xxd on 15/4/7.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "NSTimer+MMExt.h"
#import <objc/runtime.h>

#pragma mark - Timer Handle
typedef enum : NSUInteger {
    Count,
    Loop,
} MMTimerBlockType;

@interface MMTimerHandle : NSObject
@property (nonatomic) MMTimerBlockType type;
@property (nonatomic) NSUInteger currentCount;
@property (nonatomic) NSUInteger totalRepeatCount;
@property (copy, nonatomic) MMTimerCountBLock countBlock;
@property (copy, nonatomic) MMTimerCompletionBlock completionBlock;
@property (copy, nonatomic) MMTimerLoopBlock loopBlock;
+ (MMTimerHandle *)handleWithCountBlock:(MMTimerCountBLock)block repeatCount:(NSUInteger)count completion:(MMTimerCompletionBlock)completion;
+ (MMTimerHandle *)handleWithLoopBlock:(MMTimerLoopBlock)block;
- (void)handleTimer:(NSTimer *)timer;
@end

@implementation MMTimerHandle
+ (MMTimerHandle *)handleWithCountBlock:(MMTimerCountBLock)block repeatCount:(NSUInteger)count completion:(MMTimerCompletionBlock)completion
{
    MMTimerHandle *handle = [[MMTimerHandle alloc] init];
    handle.type = Count;
    handle.currentCount = 0;
    handle.totalRepeatCount = count;
    handle.countBlock = block;
    handle.completionBlock = completion;
    return handle;
}

+ (MMTimerHandle *)handleWithLoopBlock:(MMTimerLoopBlock)block
{
    MMTimerHandle *handle = [[MMTimerHandle alloc] init];
    handle.type = Loop;
    handle.loopBlock = block;
    return handle;
}

- (void)handleTimer:(NSTimer *)timer
{
    switch (self.type)
    {
        case Count:
        {
            BOOL cancel = NO;
            if (_currentCount < _totalRepeatCount)
            {
                if (_countBlock)
                {
                    _countBlock(timer, &cancel);
                }
                _currentCount++;
            }
            
            if (_currentCount >= _totalRepeatCount || cancel)
            {
                [timer invalidate];
                if (_completionBlock)
                {
                    _completionBlock(!cancel);
                }
            }
            break;
        }
        case Loop:
        {
            if (_loopBlock)
            {
                _loopBlock(timer);
            }
            break;
        }
    }
}

@end


#pragma mark - Timer BLock Category
@implementation NSTimer (MMExt)

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti forCountBlock:(MMTimerCountBLock)block userInfo:(id)userInfo repeatCount:(NSUInteger)repeatCount completion:(MMTimerCompletionBlock)completion
{
    MMTimerHandle *handle = [MMTimerHandle handleWithCountBlock:block repeatCount:repeatCount completion:completion];
    NSTimer* timer = [NSTimer timerWithTimeInterval:ti target:handle selector:@selector(handleTimer:) userInfo:userInfo repeats:YES];
    return timer;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti forCountBlock:(MMTimerCountBLock)block userInfo:(id)userInfo repeatCount:(NSUInteger)repeatCount completion:(MMTimerCompletionBlock)completion
{
    MMTimerHandle *handle = [MMTimerHandle handleWithCountBlock:block repeatCount:repeatCount completion:completion];
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:ti target:handle selector:@selector(handleTimer:) userInfo:userInfo repeats:YES];
    return timer;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti forLoopBlock:(MMTimerLoopBlock)block userInfo:(id)userInfo repeats:(BOOL)repeat
{
    MMTimerHandle *handle = [MMTimerHandle handleWithLoopBlock:block];
    NSTimer *timer = [NSTimer timerWithTimeInterval:ti target:handle selector:@selector(handleTimer:) userInfo:userInfo repeats:repeat];
    return timer;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti forLoopBlock:(MMTimerLoopBlock)block userInfo:(id)userInfo repeats:(BOOL)repeat
{
    MMTimerHandle *handle = [MMTimerHandle handleWithLoopBlock:block];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ti target:handle selector:@selector(handleTimer:) userInfo:userInfo repeats:repeat];
    return timer;
}

@end
