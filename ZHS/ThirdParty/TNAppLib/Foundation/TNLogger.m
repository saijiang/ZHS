//
//  TNLogger.m
//  WeZone
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNLogger.h"
#import "TNBean.h"
#import "NSObject+Automatic.h"
#import "TNFormatUtil.h"
#import "TNThreadManager.h"
#import "TNNumberUtil.h"
#import "TNJsonUtil.h"
#import <mach/mach.h>

#pragma mark - Logger Constants

#define kLoggerMemoryMaxCount 50
#define kLoggerDiskMaxCount 100 // max file count.
#define kLoggerScanTimeInterval 30.0
#define kLoggerDiskPath @"TNLogger"

#define kDebugLogMaxCount 100
#define kDebugLogFilePath @"WeZone.log"

#pragma mark - TNLogItem
@interface TNLogItem : TNBean

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *referer;
@property (nonatomic, strong) NSNumber *referenceId;
@property (nonatomic, strong) NSString *clientVersion;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic) NSUInteger options;

@end

@implementation TNLogItem

- (id)init
{
    if (self = [super init]) {
        self.timestamp = [NSDate date];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self decodePropertiesWithDecoder:aDecoder class:[TNLogItem class]];
    }
    return self;
}

- (id)initWithJsonValue:(NSDictionary *)jsonValue
{
    if (self = [super initWithJsonValue:jsonValue]) {
        [self decodePropertiesWithJsonValue:jsonValue class:[TNLogItem class]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [self encodePropertiesWithCoder:aCoder class:[TNLogItem class]];
}

- (void)encodeWithJsonValueContainer:(NSMutableDictionary *)jsonValueContainer
{
    [super encodeWithJsonValueContainer:jsonValueContainer];
    [self encodePropertiesWithJsonValueContainer:jsonValueContainer class:[TNLogItem class]];
    
    NSString *paramstring = [TNFormatUtil formatHTTPParams:self.parameters];
    if (paramstring.length > 0) {
        [jsonValueContainer setObject:paramstring forKey:@"parameters"];
    } else {
        [jsonValueContainer removeObjectForKey:@"parameters"];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; action = %@; timestamp = %@; parameters = %@>", NSStringFromClass([self class]), self, self.action, self.timestamp, self.parameters];
}

- (BOOL)isTransientForKey:(NSString *)key beanType:(TNBeanType)beanType
{
    if (beanType == TNBeanTypeJson && [key isEqualToString:@"options"]) {
        return YES;
    }
    return NO;
}

@end

#pragma mark - TNLogger
@interface TNLogger ()
{
    BOOL scanning;
    BOOL running;
}

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic) NSUInteger countLimit;
@property (nonatomic) NSUInteger diskCountLimit;
@property (nonatomic, strong) NSString *diskPath;

@property (nonatomic) NSTimeInterval scanTimeInterval;
@property (nonatomic, strong) NSTimer *scanTimer;

@property (nonatomic, strong) NSURL *logDirectory;
@property (nonatomic, strong) NSURL *crashDirectory;

@property (nonatomic, strong) NSMutableArray *debugLogCache;
@property (nonatomic) NSUInteger debugLogCountLimit;
@property (nonatomic, strong) NSURL *debugLogFileURL;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSMutableDictionary *commonParameters;

@end

@implementation TNLogger

+ (TNLogger *)sharedLogger
{
    static TNLogger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TNLogger alloc] initWithMemoryCountLimit:kLoggerMemoryMaxCount diskCountLimit:kLoggerDiskMaxCount diskPath:kLoggerDiskPath];
        instance.scanTimeInterval = kLoggerScanTimeInterval;
    });
    return instance;
}

- (id)initWithMemoryCountLimit:(NSUInteger)countLimit diskCountLimit:(NSUInteger)diskCountLimit diskPath:(NSString *)diskPath
{
    if (self = [super init]) {
        self.countLimit = countLimit;
        self.diskCountLimit = diskCountLimit;
        self.diskPath = diskPath;
        
        NSURL *cacheURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        
        self.logDirectory = [cacheURL URLByAppendingPathComponent:diskPath isDirectory:YES];
        self.crashDirectory = [cacheURL URLByAppendingPathComponent:@"/CrashLog" isDirectory:YES];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir = NO;
        if (![fm fileExistsAtPath:self.logDirectory.path isDirectory:&isDir] || !isDir) {
            [fm createDirectoryAtURL:self.logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fm fileExistsAtPath:self.crashDirectory.path isDirectory:&isDir] || !isDir) {
            [fm createDirectoryAtURL:self.crashDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        self.crashReportEnabled = YES;
        
#ifdef  DEBUG
        self.logEnabled = YES;
#else
        self.logEnabled = NO;
#endif
        
        self.items = [NSMutableArray array];
        self.debugLogCache = [NSMutableArray array];
        self.debugLogCountLimit = kDebugLogMaxCount;
        self.debugLogFileURL = [cacheURL URLByAppendingPathComponent:kDebugLogFilePath isDirectory:NO];
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss.SSS";
    }
    return self;
}

- (void)dealloc
{
    [self stop];
}

#pragma mark - Start & Stop
- (void)start
{
    if (running) {
        return;
    }
    
    running = YES;
//    self.scanTimer = [NSTimer timerWithTimeInterval:self.scanTimeInterval target:self selector:@selector(scan) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (NSString *)idfvString
{
    if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return @"";
}

- (void)stop
{
    if (!running) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.scanTimer invalidate];
    self.scanTimer = nil;
    running = NO;
}

#pragma mark - Log Actions
- (void)logCrashWithException:(NSException *)e
{
    if (!running || !self.isCrashReportEnabled) {
        return;
    }
    
    TNLogItem *item = [[TNLogItem alloc] init];
    item.type = @"CRASH";
    item.action = @"TNCrashHandler";
    item.options = TNLogOptionsTargetBackend;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
    if (version) {
        [params setObject:version forKey:@"version"];
    }
    if (e.name) {
        [params setObject:e.name forKey:@"exceptionName"];
    }
    if (e.reason) {
        [params setObject:e.reason forKey:@"reason"];
    }
    if (e.callStackSymbols) {
        [params setObject:e.callStackSymbols forKey:@"callStackSymbols"];
    }
    if (e.callStackReturnAddresses) {
        [params setObject:e.callStackReturnAddresses forKey:@"callStackReturnAddresses"];
    }
    if (e.userInfo) {
        [params setObject:e.userInfo forKey:@"userInfo"];
    }
    item.parameters = params;
    
    // Always log crash to console.
//    NSLog(@"Crash:\r\n%@: %@\r\n%@: %@", NSStringFromClass([e class]), e, NSStringFromClass([item class]), item);
    
//    // in crash handler, all action is synchronized.
//    NSURL *fileURL = [self.logDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%f_Crash.log", [NSDate timeIntervalSinceReferenceDate]]];
//    NSURL *crashURL = [self.crashDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%f_Crash.log", [NSDate timeIntervalSinceReferenceDate]]];
//    NSError *error = nil;
//    NSData *data = [TNJsonUtil dataWithObject:@[item] prettyPrinted:NO error:&error];
//    [data writeToURL:fileURL atomically:YES];
//    [data writeToURL:crashURL atomically:YES];
//    [[TNRequestManager defaultManager] requestLogBatchWithData:data sync:YES completion:^(TNRequest *request, id responseObject, NSError *error) {
//        if (request.response.statusCode == kHTTPStatusCodeOK) {
//            NSFileManager *fm = [NSFileManager defaultManager];
//            if ([fm fileExistsAtPath:fileURL.path]) {
//                [fm removeItemAtURL:fileURL error:nil];
//            }
//        }
//    }];
}

- (void)logEvent:(NSString *)eventName
{
    //默认不发送友盟事件
    //[self logEvent:eventName parameters:nil options:TNLogOptionsTargetBackend | TNLogOptionsTargetUmeng];
//    [TNToast showWithText:eventName];
    [self logEvent:eventName parameters:nil options:TNLogOptionsTargetBackend];
}

- (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    //默认不发送友盟事件
    //[self logEvent:eventName parameters:parameters options:TNLogOptionsTargetBackend | TNLogOptionsTargetUmeng];
    [self logEvent:eventName parameters:parameters options:TNLogOptionsTargetBackend];
}

- (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters options:(TNLogOptions)options
{
    if (!running) {
        return;
    }
    
    TNLogItem *item = [[TNLogItem alloc] init];
    item.type = @"GLOBAL";
    item.action = eventName;
    item.parameters = parameters;
    item.options = options;
    
    [self logItem:item forceToFlush:NO];
}

- (void)logEvent:(NSString *)eventName options:(TNLogOptions)options parameterObjectsAndKeys:(id)firstObject, ...
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    id obj = nil;
    va_list args;
    va_start(args, firstObject);
    id temp = firstObject;
    while (temp) {
        if (obj == nil) {
            obj = temp;
        } else {
            [dict setObject:obj forKey:temp];
            obj = nil;
        }
        temp = va_arg(args, id);
    }
    va_end(args);
    [self logEvent:eventName parameters:dict options:options];
}

- (void)logItem:(TNLogItem *)item forceToFlush:(BOOL)isForceToFlush
{
    if (!running || !item) {
        return;
    }
    
    [TNThreadManager asyncExecuteInMainThread:^{
        if (TNHasOption(item.options, TNLogOptionsTargetUmeng)) {
            // NO UMeng
        }
        if (TNHasOption(item.options, TNLogOptionsTargetBackend)) {
            NSDictionary *common = [self.commonParameters objectForKey:[NSNumber numberWithUnsignedInteger:TNLogOptionsTargetBackend]];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params addEntriesFromDictionary:item.parameters];
            if (common.count > 0) {
                [params addEntriesFromDictionary:common];
            }
            
            if (params.count > 0) {
                item.parameters = params;
            }
            
            [self.items addObject:item];
            if (isForceToFlush || self.items.count >= self.countLimit) {
                [self flush];
            }
        }
    }];
    
    if (self.isLogEnabled) {
//        NSLog(@"%@", item);
    }
}

- (void)logViewAppear:(NSString *)pageName
{
    TNLogItem *item = [TNLogItem new];
    item.action = @"ENTER";
    item.type = @"UI";
    item.parameters = @{@"CURRENT_MODULE_NAME": pageName};
    item.options = TNLogOptionsTargetBackend;
    [self logItem:item forceToFlush:NO];
}

- (void)logViewDisappear:(NSString *)pageName duration:(NSTimeInterval)duration
{
    TNLogItem *item = [TNLogItem new];
    item.action = @"LEAVE";
    item.type = @"UI";
    item.parameters = @{@"CURRENT_MODULE_NAME": pageName, @"DURATION": [NSNumber numberWithLongLong:(long long)(duration * 1000L)]};
    item.options = TNLogOptionsTargetBackend;
    [self logItem:item forceToFlush:NO];
}

- (void)logWithLevel:(TNLogLevel)level format:(NSString *)format, ...
{
    if (!running) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
//    NSLog(@"%@", logString);
    
    NSProcessInfo *pinfo = [NSProcessInfo processInfo];
    logString = [[NSString alloc] initWithFormat:@"%@ %@[%i:%x] %@", [self.dateFormatter stringFromDate:[NSDate date]], pinfo.processName, pinfo.processIdentifier, mach_thread_self(), logString];
    
    if (logString.length == 0) {
        return;
    }
    
    if (self.logView) {
        self.logView.text = self.logView.text ? [NSString stringWithFormat:@"%@\r\n%@", self.logView.text, logString] : logString;
    }
    
    if (level >= TNLogLevelError) {
        [self.debugLogCache addObject:logString];
        if (self.debugLogCache.count >= self.debugLogCountLimit) {
            [self flushDebugLog];
        }
    }
}

#pragma mark - Flushs
- (void)flush
{
    if (self.items.count == 0) {
        return;
    }
    
//    NSArray *array = [self.items mutableCopy];
    self.items = [NSMutableArray array];
    
//    NSURL *fileURL = [self.logDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%f.log", [NSDate timeIntervalSinceReferenceDate]]];
//    [TNThreadManager asyncExecuteInBackgroundThread:^{
//        NSError *error = nil;
//        NSData *data = [TNJsonUtil dataWithObject:array prettyPrinted:NO error:&error];
//        [data writeToURL:fileURL atomically:YES];
//        
//        [TNThreadManager asyncExecuteInMainThread:^{
//            [self.scanTimer fire];
//        }];
//    }];
}

- (void)flushDebugLog
{
    if (self.debugLogCache.count == 0) {
        return;
    }
    
//    NSArray *array = self.debugLogCache;
    self.debugLogCache = [NSMutableArray array];
//    [array writeToURL:self.debugLogFileURL atomically:YES];
}

#pragma mark - Timer Handler
//- (void)scan
//{
//    if (scanning) {
//        return;
//    }
//    
//    scanning = YES;
//    [TNThreadManager asyncExecuteInBackgroundThread:^{
//        NSFileManager *fm = [NSFileManager defaultManager];
//        NSError *error = nil;
//        NSArray *fileURLs = [fm contentsOfDirectoryAtURL:self.logDirectory includingPropertiesForKeys:@[NSURLIsRegularFileKey, NSURLCreationDateKey]
//                                                 options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
//        if (fileURLs) {
//            fileURLs = [fileURLs sortedArrayUsingComparator:^NSComparisonResult(NSURL *obj1, NSURL * obj2) {
//                NSDate *date1 = nil;
//                NSDate *date2 = nil;
//                BOOL success1 = [obj1 getResourceValue:&date1 forKey:NSURLCreationDateKey error:nil];
//                BOOL success2 = [obj2 getResourceValue:&date2 forKey:NSURLCreationDateKey error:nil];
//                if (success1 && success2) {
//                    return [date1 compare:date2];
//                } else {
//                    return [obj1.path compare:obj2.path options:NSCaseInsensitiveSearch];
//                }
//            }];
//            
//            NSUInteger removeCount = 0;
//            if (fileURLs.count > self.diskCountLimit) {
//                removeCount = self.diskCountLimit - fileURLs.count;
//            }
//            [fileURLs enumerateObjectsUsingBlock:^(NSURL *obj, NSUInteger idx, BOOL *stop) {
//                if (removeCount > idx) {
//                    [fm removeItemAtURL:obj error:nil];
//                } else {
//                    NSNumber *isRegularFile = [NSNumber numberWithBool:NO];
//                    [obj getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:nil];
//                    if ([isRegularFile boolValue]) {
//                        NSData *data = [NSData dataWithContentsOfURL:obj];
//                        if (data) {
//                            [[TNRequestManager defaultManager] requestLogBatchWithData:data sync:NO completion:^(TNRequest *request, id responseObject, NSError *error) {
//                                if (request.response.statusCode == kHTTPStatusCodeOK) {
//                                    [TNThreadManager asyncExecuteInBackgroundThread:^{
//                                        if ([fm fileExistsAtPath:obj.path]) {
//                                            [fm removeItemAtURL:obj error:nil];
//                                        }
//                                    }];
//                                }
//                            }];
//                        }
//                    }
//                }
//            }];
//        }
//        scanning = NO;
//    }];
//}

#pragma mark - Application Notifications
- (void)applicationDidEnterBackground:(NSNotification *)noti
{
    [self flush];
    [self flushDebugLog];
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)noti
{
    [self flush];
    [self flushDebugLog];
}

- (void)setCommonParameters:(NSDictionary *)parameters forOption:(TNLogOptions)anOption
{
    if (parameters.count > 0) {
        [self.commonParameters setObject:parameters forKey:[NSNumber numberWithUnsignedInteger:anOption]];
    } else {
        [self.commonParameters removeObjectForKey:[NSNumber numberWithUnsignedInteger:anOption]];
    }
}

@end
