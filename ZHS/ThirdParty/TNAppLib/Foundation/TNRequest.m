//
//  TNRequest.m
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNRequest.h"
#import "NSString+TNAppLib.h"
#import "NSError+TNAppLib.h"
#import "NSData+GZIP.h"
#import "TNFormatUtil.h"
#import "TNThreadManager.h"
#import "TNLogger.h"

#define REQ_LOG_ENABLED 1

@interface TNRequest ()
{
    BOOL executing;
    BOOL finished;
    BOOL cached;
    BOOL cacheAllRequest;
    long long cachedTotalBytesExpectedToWrite;
}

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;

- (void)completeOperation;

@end

@implementation TNRequest

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        cacheAllRequest = NO;
        self.startTime = 0.0;
        self.endTime = 0.0;
        self.URL = [aDecoder decodeObjectForKey:@"URL"];
        self.HTTPGetParams = [aDecoder decodeObjectForKey:@"HTTPGetParams"];
        self.HTTPPostParams = [aDecoder decodeObjectForKey:@"HTTPPostParams"];
        self.HTTPPostData = [aDecoder decodeObjectForKey:@"HTTPPostData"];
        self.HTTPPostFilePath = [aDecoder decodeObjectForKey:@"HTTPPostFilePath"];
        self.HTTPHeaderFields = [aDecoder decodeObjectForKey:@"HTTPHeaderFields"];
        if (self.HTTPHeaderFields == nil) {
            self.HTTPHeaderFields = [NSMutableDictionary dictionary];
        }
        self.timeoutInterval = [aDecoder decodeDoubleForKey:@"timeoutInterval"];
        self.storagePolicy = [[aDecoder decodeObjectForKey:@"storagePolicy"] unsignedIntegerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.URL forKey:@"URL"];
    [aCoder encodeObject:self.HTTPGetParams forKey:@"HTTPGetParams"];
    [aCoder encodeObject:self.HTTPPostParams forKey:@"HTTPPostParams"];
    [aCoder encodeObject:self.HTTPPostData forKey:@"HTTPPostData"];
    [aCoder encodeObject:self.HTTPPostFilePath forKey:@"HTTPPostFilePath"];
    [aCoder encodeObject:self.HTTPHeaderFields forKey:@"HTTPHeaderFields"];
    [aCoder encodeDouble:self.timeoutInterval forKey:@"timeoutInterval"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.storagePolicy] forKey:@"storagePolicy"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark -
- (id)initWithURL:(NSURL *)URL
{
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        self.startTime = 0.0;
        self.endTime = 0.0;
        self.URL = URL;
        self.storagePolicy = NSURLCacheStorageNotAllowed;
        self.HTTPHeaderFields = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [self clean];
#if REQ_LOG_ENABLED
    LogDebug(@"");
#endif
}

- (void)clean
{
    [self.timer invalidate];
    self.timer = nil;
    [self.connection cancel];
    self.connection = nil;
    self.response = nil;
    self.data = nil;
    self.responseData = nil;
    self.error = nil;
}

#pragma mark - NSOperation
- (void)buildRequest
{
    if (self.timeoutInterval < kVerySmallValue) {
        self.timeoutInterval = 30.0;
    }
    
    self.request = [NSMutableURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeoutInterval];
    
    if (self.HTTPHeaderFields) {
        [self.HTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self.request setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    // make get params
    NSMutableString *urlString = [NSMutableString stringWithString:self.URL.absoluteString];
    NSUInteger pos = [urlString rangeOfString:@"?"].location;
    if (pos != NSNotFound) {
        [urlString deleteCharactersInRange:NSMakeRange(pos, urlString.length - pos)];
    }
    NSDictionary *getParams = self.HTTPGetParams;
    if (getParams.count > 0) {
        if (![urlString hasSuffix:@"?"]) {
            [urlString appendString:@"?"];
        }
        [urlString appendString:[TNFormatUtil formatHTTPParams:self.HTTPGetParams]];
    }
    self.request.URL = [NSURL URLWithString:urlString];
    
    // make post params
    self.request.HTTPMethod = @"POST";
    if (self.HTTPPostData) {
        self.request.HTTPBody = self.HTTPPostData;
    } else if (self.HTTPPostFilePath) {
        self.request.HTTPBodyStream = [NSInputStream inputStreamWithFileAtPath:self.HTTPPostFilePath];
        cachedTotalBytesExpectedToWrite = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.HTTPPostFilePath error:nil] fileSize];
    } else if (self.HTTPPostParams != nil) {
        self.request.HTTPBody = [[TNFormatUtil formatHTTPParams:self.HTTPPostParams] dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        self.request.HTTPMethod = @"GET";
    }
    
    if (self.request.HTTPBody != nil && self.request.HTTPBodyStream == nil) {
        cachedTotalBytesExpectedToWrite = self.request.HTTPBody.length;
    }
    
    if (self.startBlock) {
        [self performSelectorOnMainThread:@selector(runStartBlock) withObject:nil waitUntilDone:YES];
    }
}

- (void)runStartBlock
{
    __weak __typeof(self) weakObj = self;
    self.startBlock(weakObj);
}

- (void)start
{
    cached = NO;
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    self.endTime = 0.0;
    if ([self isCancelled]) {
        [self completeOperation];
        return;
    }
    
    @try {
        [self willChangeValueForKey:@"isExecuting"];
        executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        [self clean];
        
        [self buildRequest];
        if (self.request) {
            self.data = [NSMutableData data];
            
            // start timeout timer. According the test on simulator, the timeout property of NSURLRequest is effective, so we give the timer 1.0 seconds to avoid calling timeout twice.
            self.timer = [NSTimer timerWithTimeInterval:self.timeoutInterval + 1.0 target:self selector:@selector(timerHandler:) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
            
            // start request
            self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
            [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [self.connection start];
#if REQ_LOG_ENABLED
            LogDebug(@"Start request async: %@\n\tmethod: %@\n\tpost params: %@", self.request, self.request.HTTPMethod,
                     self.HTTPPostData ? self.HTTPPostData : self.HTTPPostFilePath ? self.HTTPPostFilePath : self.HTTPPostParams);
#endif
        } else {
            self.error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
            [self completeOperation];
        }
    }
    @catch (NSException *exception) {
        self.error = [NSError errorWithException:exception];
        [self completeOperation];
    }
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isFinished
{
    return finished;
}

- (void)cancelWithError:(NSError *)error
{
    [self clean];
    self.error = error;
    [self cancel];
    self.endTime = [NSDate timeIntervalSinceReferenceDate];
    if (self.completionBlock) {
        [self performSelectorOnMainThread:@selector(runCompletionBlock) withObject:nil waitUntilDone:YES];
    }
}

- (void)runCompletionBlock
{
    self.completionBlock();
}

- (void)completeOperation {
    [self.timer invalidate];
    self.timer = nil;
    
    self.endTime = [NSDate timeIntervalSinceReferenceDate];
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Timer
- (void)timerHandler:(NSTimer *)timer
{
    if (self.isFinished) {
        return;
    }
    
    [self cancelWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil]];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
    [self completeOperation];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = (NSHTTPURLResponse *)response;
    
#if REQ_LOG_ENABLED
    LogDebug(@"Receive response async: %@\n\tmessage: %@", response, [NSHTTPURLResponse localizedStringForStatusCode:self.response.statusCode]);
#endif
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [(NSMutableData *)self.data appendData:data];
    if (self.downloadProgressBlock) {
        long long currentLen = self.data.length;
        long long expectedLen = self.response.expectedContentLength;
        __weak __typeof(self) weakObj = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakObj) strongObj = weakObj;
            self.downloadProgressBlock(strongObj, currentLen, expectedLen);
        });
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.responseData = self.data;
    if (cacheAllRequest && !cached && self.response.statusCode == kHTTPStatusCodeOK) {
        NSCachedURLResponse *cache = [[NSCachedURLResponse alloc] initWithResponse:self.response data:self.responseData userInfo:nil storagePolicy:self.storagePolicy];
        [[NSURLCache sharedURLCache] storeCachedResponse:cache forRequest:self.request];
    }
    [self completeOperation];
    
#if REQ_LOG_ENABLED
    LogDebug(@"Finish request async: %@\n\tdata: %@", self.request, self.responseData ? [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] : nil);
#endif
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.sendProgressBlock) {
        long long totalBytesLength = totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : cachedTotalBytesExpectedToWrite;
        __weak __typeof(self) weakObj = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakObj) strongObj = weakObj;
            self.sendProgressBlock(strongObj, totalBytesWritten, totalBytesLength);
        });
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    cached = [(NSHTTPURLResponse *)cachedResponse.response statusCode] == kHTTPStatusCodeOK;
    return cachedResponse;
}

#pragma mark - start
- (void)startSynchronously
{
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    self.endTime = 0.0;
    [self buildRequest];
    
#if REQ_LOG_ENABLED
    LogDebug(@"Start request sync: %@\n\tmethod: %@\n\tpost params: %@", self.request, self.request.HTTPMethod,
             self.HTTPPostData ? self.HTTPPostData : self.HTTPPostFilePath ? self.HTTPPostFilePath : self.HTTPPostParams);
#endif
    NSHTTPURLResponse *resp = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:self.request returningResponse:&resp error:&error];
    self.response = resp;
    self.error = error;
    self.data = data;
    self.responseData = data;
    
    if (cacheAllRequest && self.response.statusCode == kHTTPStatusCodeOK) {
        NSCachedURLResponse *cache = [[NSCachedURLResponse alloc] initWithResponse:self.response data:self.data userInfo:nil storagePolicy:self.storagePolicy];
        [[NSURLCache sharedURLCache] storeCachedResponse:cache forRequest:self.request];
    }
    
    self.endTime = [NSDate timeIntervalSinceReferenceDate];
    
#if REQ_LOG_ENABLED
    LogDebug(@"Finished request sync: %@\n\tmesssage: %@\n\t data:%@", self.response, [NSHTTPURLResponse localizedStringForStatusCode:self.response.statusCode],
             self.responseData ? [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] : nil);
#endif
}

- (void)startAsynchronouslyInQueue:(NSOperationQueue *)queue
{
    BOOL isQueueSuspended = queue.isSuspended;
    [queue setSuspended:YES];
    [queue addOperation:self];
    [queue setSuspended:isQueueSuspended];
}

#pragma mark -
- (NSTimeInterval)usedTimeInterval
{
    if (!self.isFinished) {
        return 0.0;
    }
    return MIN(0.0, self.endTime - self.startTime);
}

@end
