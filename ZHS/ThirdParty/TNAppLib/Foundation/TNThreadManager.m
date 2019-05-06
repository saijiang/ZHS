//
//  TNThreadManager.m
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNThreadManager.h"
#import "TNLogger.h"
#import "TNAppLibMacros.h"

@interface TNThreadManager ()

@property (nonatomic, strong) NSOperationQueue *serialQueue0;

@end

@implementation TNThreadManager

+ (TNThreadManager *)defaultManager
{
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{ instance = self.new; });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        self.serialQueue0 = [NSOperationQueue new];
        self.serialQueue0.maxConcurrentOperationCount = 1;
        self.serialQueue0.name = @"com.telenav.serialQueue0";
        [self.serialQueue0 setSuspended:NO];
    }
    return self;
}

- (void)dealloc
{
    [self.serialQueue0 cancelAllOperations];
    self.serialQueue0 = nil;
}

+ (void)asyncExecuteInBackgroundThread:(void (^)(void))block
{
#ifdef DEBUG
    static int count = 0;
    count++;
    if (block == nil) {
//        LogDebug(@"async background block (%i) is nil.", count);
        return;
    }
    
    BasicBlock wrapper = ^{
//        NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
//        LogDebug(@"start async background block (%i)", count);
        block();
//        LogDebug(@"async background block (%i) duration = %f", count, [NSDate timeIntervalSinceReferenceDate] - start);
    };
    [[self defaultManager].serialQueue0 addOperationWithBlock:wrapper];
#else
    if (block == nil) {
        return;
    }
    
    [[self defaultManager].serialQueue0 addOperationWithBlock:block];
#endif
}

+ (void)asyncExecuteInMainThread:(void (^)(void))block
{
#ifdef DEBUG
    static int count = 0;
    count++;
    if (block == nil) {
//        LogDebug(@"async main block (%i) is nil.", count);
        return;
    }
    
    BasicBlock wrapper = ^{
//        NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
//        LogDebug(@"start async main block (%i)", count);
        block();
//        LogDebug(@"async main block (%i) duration = %f", count, [NSDate timeIntervalSinceReferenceDate] - start);
    };
    dispatch_async(dispatch_get_main_queue(), wrapper);
#else
    if (block == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), block);
#endif
}

+ (void)syncExecuteInMainThread:(void (^)(void))block
{
#ifdef DEBUG
    static int count = 0;
    count++;
    if (block == nil) {
//        LogDebug(@"sync main block (%i) is nil.", count);
        return;
    }
    
    BasicBlock wrapper = ^{
//        NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
//        LogDebug(@"start sync main block (%i)", count);
        block();
//        LogDebug(@"sync main block (%i) duration = %f", count, [NSDate timeIntervalSinceReferenceDate] - start);
    };
    dispatch_sync(dispatch_get_main_queue(), wrapper);
#else
    if (block == nil) {
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), block);
#endif
}

+ (void)executeInMainThread:(void (^)(void))block after:(NSTimeInterval)delayInSeconds
{
#ifdef DEBUG
    static int count = 0;
    count++;
    if (block == nil) {
//        LogDebug(@"after main block (%i, %f) is nil.", count, delayInSeconds);
        return;
    }
    
    BasicBlock wrapper = ^{
//        LogDebug(@"start after main block (%i, %f)", count, delayInSeconds);
        block();
//        LogDebug(@"after main block (%i, %f) duration = %f", count, delayInSeconds, [NSDate timeIntervalSinceReferenceDate] - start);
    };
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), wrapper);
#else
    if (block == nil) {
        return;
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
#endif
}

@end
