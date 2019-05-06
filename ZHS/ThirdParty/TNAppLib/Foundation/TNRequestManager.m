//
//  TNRequestManager.m
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNRequestManager.h"
#import "Reachability.h"
#import "NSString+TNAppLib.h"

#define kUserDefaultsSsoToken @"kUserDefaultsSsoToken"

NSString *const kTNReachabiblityChangedNotification = @"kTNReachabiblityChangedNotification";

@interface TNRequestManager ()

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic) NetworkStatus reachabilityStatus;

@property (nonatomic, strong) NSOperationQueue *concurrentQueue;
@property (nonatomic, strong) NSOperationQueue *serialQueue;
@property (nonatomic, strong) NSOperationQueue *systemQueue;

@property (nonatomic, strong) NSURLCache *URLCache;

@property (nonatomic, strong) NSMutableDictionary *commonGetParameters;
@property (nonatomic, strong) NSMutableDictionary *commonPostParameters;

@property (nonatomic, strong) NSMutableDictionary *commonHandlers;

@end

@implementation TNRequestManager

+ (TNRequestManager *)defaultManager
{
    static dispatch_once_t onceToken;
    static TNRequestManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [self new];
        instance.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:kURLCacheMemoryMaxSize diskCapacity:kURLCacheDiskMaxSize diskPath:kURLCacheDiskPath];
        [NSURLCache setSharedURLCache:instance.URLCache];
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        
        _ssoToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsSsoToken];
        self.reachability = [Reachability reachabilityWithHostname:@"wzone.tiantianxing.cn"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChanged:) name:kReachabilityChangedNotification object:self.reachability];
        [self.reachability startNotifier];
    }
    return self;
}

- (void)dealloc
{
    [_concurrentQueue cancelAllOperations];
    _concurrentQueue = nil;
    [_serialQueue cancelAllOperations];
    _serialQueue = nil;
    [self.reachability stopNotifier];
    self.reachability = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSOperationQueue *)systemQueue
{
    if (!_systemQueue) {
        _systemQueue = [NSOperationQueue new];
        _systemQueue.maxConcurrentOperationCount = 5;
        _systemQueue.name = @"com.telenav.systemHttpRequestQueue";
        [_systemQueue setSuspended:NO];
    }
    return _systemQueue;
}

- (NSOperationQueue *)concurrentQueue
{
    if (!_concurrentQueue) {
        _concurrentQueue = [NSOperationQueue new];
        _concurrentQueue.maxConcurrentOperationCount = 5;
        _concurrentQueue.name = @"com.telenav.concurrentHttpRequestQueue";
        [_concurrentQueue setSuspended:NO];
    }
    return _concurrentQueue;
}

- (NSOperationQueue *)serialQueue
{
    if (!_serialQueue) {
        _serialQueue = [NSOperationQueue new];
        _serialQueue.maxConcurrentOperationCount = 1;
        _serialQueue.name = @"com.telenav.serialHttpRequestQueue";
        [_serialQueue setSuspended:NO];
    }
    return _serialQueue;
}

- (void)setCommonParameters:(NSDictionary *)parameters forMethod:(NSString *)method
{
    if (method.length == 0) {
        return;
    }
    if (parameters.count > 0) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [dictionary setObject:[obj stringByURLEncoding] forKey:key];
        }];
        
        if ([method compare:@"GET" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            self.commonGetParameters = dictionary;
        } else if ([method compare:@"POST" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            self.commonPostParameters = dictionary;
        }
    } else {
        if ([method compare:@"GET" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            self.commonGetParameters = nil;
        } else if ([method compare:@"POST" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            self.commonPostParameters = nil;
        }
    }
}

- (void)setCommonParameterValue:(NSString *)value forKey:(NSString *)key method:(NSString *)method
{
    NSMutableDictionary *dictionary = nil;
    if ([method compare:@"GET" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        if (value.length > 0 && !self.commonGetParameters) {
            self.commonGetParameters = [NSMutableDictionary dictionary];
        }
        dictionary = self.commonGetParameters;
    } else {
        if (value.length > 0 && !self.commonPostParameters) {
            self.commonPostParameters = [NSMutableDictionary dictionary];
        }
        dictionary = self.commonPostParameters;
    }
    
    if (value.length > 0) {
        [dictionary setObject:value forKey:key];
    } else {
        [dictionary removeObjectForKey:key];
    }
}

- (void)setCommonHandler:(TNRequestCompletionHandler)handler forKey:(NSString *)key
{
    if (key == nil) {
        return;
    }
    
    if (self.commonHandlers == nil) {
        self.commonHandlers = [NSMutableDictionary dictionary];
    }
    
    if (handler == nil) {
        [self.commonHandlers removeObjectForKey:key];
    } else {
        TNRequestCompletionHandler hCopy = [handler copy];
        [self.commonHandlers setObject:hCopy forKey:key];
    }
}

#pragma mark - reachability
- (void)refreshReachability
{
    self.reachabilityStatus = [self.reachability currentReachabilityStatus];
}

- (void)reachabilityDidChanged:(NSNotification *)noti
{
    [self refreshReachability];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTNReachabiblityChangedNotification object:self];
}

- (BOOL)isReachable
{
    return self.reachabilityStatus != NotReachable;
}

- (BOOL)isReachableViaWifi
{
    return self.reachabilityStatus == ReachableViaWiFi;
}

#pragma mark - ssoToken
- (void)setSsoToken:(NSString *)ssoToken
{
    if (![_ssoToken isEqualToString:ssoToken]) {
        _ssoToken = ssoToken;
        if (ssoToken.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:ssoToken forKey:kUserDefaultsSsoToken];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsSsoToken];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - request
- (TNRequest *)sendServiceRequestWithSubpath:(NSString *)subpath getParams:(NSDictionary *)getParams postParams:(id)postParams responseClass:(Class)responseJSONClass preparationHandler:(TNRequestPreparationHandler)preparationHandler completion:(TNRequestCompletionHandler)completion inQueue:(NSOperationQueue *)queue waitUntilFinished:(BOOL)wait needToken:(BOOL)needToken
{
    if (self.serviceURL.absoluteString.length == 0) {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil]);
            });
        }
        return nil;
    }
    // add common get params
   
    
    NSMutableDictionary *processedParams = [NSMutableDictionary dictionary];
    
    if (self.commonGetParameters.count > 0) {
        [processedParams addEntriesFromDictionary:self.commonGetParameters];
    }
    [processedParams addEntriesFromDictionary:getParams];
    
    NSURL *url;
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"istire"] isEqualToString:@"istire"]) {
        url = [self.serviceURL URLByAppendingPathComponent:subpath];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"istire"];
               self.serviceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",kHeaderURL]];
    }else{
      url = [self.serviceURL URLByAppendingPathComponent:subpath];
    }
    
    TNRequest *request = [[TNRequest alloc] initWithURL:url];
    
    request.HTTPGetParams = processedParams;
    if (self.ssoToken.length > 0) {
        request.HTTPHeaderFields = @{@"usersession": self.ssoToken};
    }
    
    [request.request setHTTPMethod:@"POST"];
    if ([postParams isKindOfClass:[NSData class]]) {
        request.HTTPPostData = postParams;
    } else if ([postParams isKindOfClass:[NSDictionary class]]) {
        if (self.commonPostParameters.count > 0) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.commonPostParameters];
            [dictionary addEntriesFromDictionary:postParams];
            request.HTTPPostParams = dictionary;
        } else {
            request.HTTPPostParams = postParams;
        }
    } else if ([postParams isKindOfClass:[NSString class]]) {
        request.HTTPPostFilePath = postParams;
    }
    
    if (preparationHandler) {
        preparationHandler(request);
    }

    [self sendRequest:request withResponseClass:responseJSONClass completion:completion inQueue:queue waitUntilFinished:wait];
    return request;
}


- (void)sendRequest:(TNRequest *)request withResponseClass:(Class)responseClass completion:(TNRequestCompletionHandler)completion inQueue:(NSOperationQueue *)queue waitUntilFinished:(BOOL)wait
{
    TNRequestCompletionHandler mainThreadHandler = ^(TNRequest *request, id responseJSONObject, NSError *error) {
        NSArray *commonHandlers = self.commonHandlers.allValues;
        if (commonHandlers.count > 0) {
            for (TNRequestCompletionHandler h in commonHandlers) {
                h(request, responseJSONObject, error);
                if (request.error.code == TNRequestErrorCancelSubsequentHandlers) {
                    [TNToast hideLoadingToast];
                    return;
                }
            }
        }
        
        if (completion) {
            completion(request, responseJSONObject, error);
        }
    };
    
    TNRequestCompletionHandler wrappedHandler = ^(TNRequest *request, id responseJSONObject, NSError *error) {
        if ([NSThread isMainThread]) {
            mainThreadHandler(request, responseJSONObject, error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                mainThreadHandler(request, responseJSONObject, error);
            });
        }
    };
    @try {
        if (wait) {
            [request startSynchronously];
            id obj = nil;
            NSError *error = nil;
            if (responseClass != NULL && request.response.statusCode == 200) {
                if ([responseClass isSubclassOfClass:[NSDictionary class]] || [responseClass isSubclassOfClass:[NSArray class]]) {
                    obj = [TNJsonUtil objectWithData:request.responseData error:&error];
                } else {
                    obj = [TNJsonUtil objectWithData:request.responseData class:responseClass error:&error];
                }
            }
            if (error) {
                request.error = error;
            }
            wrappedHandler(request, obj, request.error);
        } else {
            if (request.sendProgressBlock != nil || request.downloadProgressBlock != nil) {
//            if (true) {
                __weak __typeof(request) weakRequest = request;
                request.completionBlock = ^{
                    __strong __typeof(weakRequest) strongRequest = weakRequest;
                    
                    id obj = nil;
                    NSError *error = nil;
                    if (responseClass != NULL && strongRequest.response.statusCode == 200) {
                        if ([responseClass isSubclassOfClass:[NSDictionary class]] || [responseClass isSubclassOfClass:[NSArray class]]) {
                            obj = [TNJsonUtil objectWithData:strongRequest.responseData error:&error];
                        } else {
                            obj = [TNJsonUtil objectWithData:strongRequest.responseData class:responseClass error:&error];
                        }
                    }
                    if (error) {
                        strongRequest.error = error;
                    }
                    
                    wrappedHandler(strongRequest, obj, strongRequest.error);
                };
                
                [request startAsynchronouslyInQueue:queue];
            } else {
                [request buildRequest];
                
                if (request.startBlock) {
                    __weak __typeof(request) weakObj = request;
                    request.startBlock(weakObj);
                }
                
                LogDebug(@"Start request async system: %@\n\tmethod: %@\n\tpost params: %@", request.request, request.request.HTTPMethod, request.HTTPPostData ? request.HTTPPostData : request.HTTPPostFilePath ? request.HTTPPostFilePath : request.HTTPPostParams);
                
                // fix system not timeout.
                __block BOOL executed = NO;
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:request.timeoutInterval + 1 block:^(NSTimer *timer) {
                    if (executed) {
                        return;
                    }
                    executed = YES;
                    
                    LogDebug(@"Finish request async system: automatic timeout exception!");
                    wrappedHandler(request, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil]);
                } userInfo:nil repeats:NO];
                [NSURLConnection sendAsynchronousRequest:request.request queue:self.systemQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (executed) {
                        return;
                    }
                    executed = YES;
                    [timer invalidate];
                    
                    LogDebug(@"Finish request async system: %@\n\tresponse: %@\n\tdata: %@\n\terror: %@", request.request, response, data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil, connectionError);
                    
                    request.response = (NSHTTPURLResponse *)response;
                    request.responseData = data;
                    request.error = connectionError;
                    
                    if (responseClass != NULL && request.response.statusCode == 200) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            id obj = nil;
                            NSError *error = nil;
                            if ([responseClass isSubclassOfClass:[NSDictionary class]] || [responseClass isSubclassOfClass:[NSArray class]]) {
                                obj = [TNJsonUtil objectWithData:request.responseData error:&error];
                            } else {
                                obj = [TNJsonUtil objectWithData:request.responseData class:responseClass error:&error];
                            }
                            if (error) {
                                request.error = error;
                            }
                            wrappedHandler(request, obj, request.error);
                        });
                    } else {
                        wrappedHandler(request, nil, request.error);
                    }
                }];
            }
        }
    }
    @catch (NSException *exception) {
        wrappedHandler(nil, nil, [NSError errorWithException:exception]);
    }
}

- (TNRequest *)getWithServcie:(NSString *)subpath params:(NSDictionary *)params responseClass:(Class)responseClass completion:(TNRequestCompletionHandler)completion
{
    return [self getWithServcie:subpath params:params responseClass:responseClass completion:completion needToken:NO];
}

- (TNRequest *)getWithServcie:(NSString *)subpath params:(NSDictionary *)params responseClass:(Class)responseClass completion:(TNRequestCompletionHandler)completion needToken:(BOOL)needToken
{
    return [self sendServiceRequestWithSubpath:subpath getParams:params ? params : @{} postParams:nil responseClass:responseClass preparationHandler:nil completion:completion inQueue:self.concurrentQueue waitUntilFinished:NO needToken:needToken];
}

- (TNRequest *)postWithServcie:(NSString *)subpath params:(NSDictionary *)params responseClass:(Class)responseClass completion:(TNRequestCompletionHandler)completion
{
    return [self postWithServcie:subpath params:params responseClass:responseClass completion:completion needToken:NO];
}

- (TNRequest *)postWithServcie:(NSString *)subpath params:(NSDictionary *)params responseClass:(Class)responseClass completion:(TNRequestCompletionHandler)completion needToken:(BOOL)needToken
{
    return [self sendServiceRequestWithSubpath:subpath getParams:nil postParams:params ? params : @{} responseClass:responseClass preparationHandler:nil completion:completion inQueue:self.concurrentQueue waitUntilFinished:NO needToken:needToken];
}

- (NSURL *)imageURLWithPath:(NSString *)imagePath
{
    return [NSURL URLWithString:[self.imageURL.absoluteString stringByAppendingString:imagePath.length?imagePath:@""]];
}

- (NSURL *)voiceURLWithId:(NSString *)voiceId
{
    if (voiceId.length <= 0) {
        return nil;
    }
    
    return [self.imageURL URLByAppendingPathComponent:[NSString stringWithFormat:@"usr-%@", voiceId]];
}

- (void)downloadVoiceWithId:(NSString *)voiceId destURL:(NSURL *)url completion:(void (^)(NSURLResponse *, NSData *, NSError *))completion
{
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[self voiceURLWithId:voiceId]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (url) {
            [data writeToURL:url atomically:YES];
        }
        
        if (completion) {
            completion(response, data, connectionError);
        }
    }];
}

@end