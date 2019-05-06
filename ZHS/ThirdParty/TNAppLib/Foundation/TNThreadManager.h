//
//  TNThreadManager.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNThreadManager : NSObject

/*!
 *  Add a operation run in a serial background thread.
 *  @param block The block to be executed.
 */
+ (void)asyncExecuteInBackgroundThread:(void (^)(void))block;

/*!
 *  Add a asynchronous operation run in the main thread.
 *  @param block The block to be executed.
 */
+ (void)asyncExecuteInMainThread:(void (^)(void))block;

/*!
 *  Add a synchronous operation run in the main thread.
 *  @param block The block to be executed.
 */
+ (void)syncExecuteInMainThread:(void (^)(void))block;

/*!
 *  Add a asynchronous operation run in the main thread after seconds.
 *  @param block The block to be executed.
 *  @param delayInSeconds The delay in seconds.
 */
+ (void)executeInMainThread:(void (^)(void))block after:(NSTimeInterval)delayInSeconds;

@end