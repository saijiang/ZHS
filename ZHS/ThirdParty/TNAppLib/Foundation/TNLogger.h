//
//  TNLogger.h
//  WeZone
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#define LogDebug(fmt, ...) [[TNLogger sharedLogger] logWithLevel:TNLogLevelDebug format:fmt @" %s line:%d", ##__VA_ARGS__, __PRETTY_FUNCTION__, __LINE__]
#else
#define LogDebug(fmt, ...)
#endif

#define LogError(fmt, ...) [[TNLogger sharedLogger] logWithLevel:TNLogLevelError format:fmt @" %s line:%d", ##__VA_ARGS__, __PRETTY_FUNCTION__, __LINE__]

#pragma mark - TNLogOptions
typedef NS_OPTIONS(NSUInteger, TNLogOptions) {
    TNLogOptionsTargetBackend = 1UL << 0,
    TNLogOptionsTargetUmeng = 1UL << 1,
};

#pragma mark - TNLogLevel
typedef NS_ENUM(NSUInteger, TNLogLevel) {
    TNLogLevelDebug = 1,
    TNLogLevelError = 100,
};

#pragma mark - TNLogger
@interface TNLogger : NSObject

/*!
 *  Should enable log in console, if DEBUG, default YES, else default NO.
 */
@property (nonatomic, getter = isLogEnabled) BOOL logEnabled;

/*!
 *  Should enable CrashReport collection, default YES.
 */
@property (nonatomic, getter = isCrashReportEnabled) BOOL crashReportEnabled;

@property (nonatomic, strong) UITextView *logView;

/*!
 *  @return The singleton.
 */
+ (TNLogger *)sharedLogger;

- (void)start;
- (void)stop;
- (void)flush;

/*!
 *  Log for crash
 *  @param e The exception when crash
 */
- (void)logCrashWithException:(NSException *)e;

/*!
 *  Log for statstics, use options: TNLogOptionsTargetBackend | TNLogOptionsTargetUmeng.
 *  @param eventName Name of event, as a key.
 *  @param parameters Parameters of event.
 */
- (void)logEvent:(NSString *)eventName;

/*!
 *  Log for statstics, use options: TNLogOptionsTargetBackend | TNLogOptionsTargetUmeng.
 *  @param eventName Name of event, as a key.
 *  @param parameters Parameters of event.
 */
- (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;

/*!
 *  Log for statstics
 *  @param eventName Name of event, as a key.
 *  @param parameters Parameters of event.
 *  @param options The TNLogOptions, indicating the targets to send.
 */
- (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters options:(TNLogOptions)options;

/*!
 *  Log for statstics
 *  @param eventName Name of event, as a key.
 *  @param options The TNLogOptions, indicating the targets to send.
 *  @param parameterObjectsAndKeys Parameters of event.
 */
- (void)logEvent:(NSString *)eventName options:(TNLogOptions)options parameterObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

- (void)logViewAppear:(NSString *)pageName;

- (void)logViewDisappear:(NSString *)pageName duration:(NSTimeInterval)duration;

/*!
 *  Log for debug.
 *  @param level The level of log, decide whether this log should be print and serialize.
 *  @param format The format of log.
 */
- (void)logWithLevel:(TNLogLevel)level format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

- (void)setCommonParameters:(NSDictionary *)parameters forOption:(TNLogOptions)anOption;

@end