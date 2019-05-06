//
//  TNRequestManager.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNRequest.h"
#import "NSError+TNAppLib.h"
#import "NSDictionary+TNAppLib.h"
#import "TNJsonUtil.h"

#pragma mark - Error
enum {
    TNURLErrorBadToken = 1000,
    TNURLErrorBadPoiId,
    TNURLErrorBadParameters,
    TNRequestErrorCancelSubsequentHandlers,
};

#pragma mark - Notifications
extern NSString *const kTNReachabiblityChangedNotification;

#pragma mark - Callback Handlers
/*!
 *  A handler for response of the specified request.
 *  @param request The request sended.
 *  @param responseObject An object parsed by JSON. If need raw data, get it from request plz.
 *  @param error The error occurred.
 */
typedef void (^TNRequestCompletionHandler) (TNRequest *request, id responseObject, NSError *error);

/*!
 *  A handler for preparing the specified request.
 *  @param request The request for preparation.
 */
typedef void (^TNRequestPreparationHandler) (TNRequest *request);

#pragma mark - Manager
@interface TNRequestManager : NSObject

@property (nonatomic, strong) NSURL *serviceURL;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *websiteURL;

@property (nonatomic, strong) NSString *ssoToken;

@property (nonatomic, readonly) BOOL isReachable;
@property (nonatomic, readonly) BOOL isReachableViaWifi;

@property (nonatomic, readonly, strong) NSOperationQueue *concurrentQueue;
@property (nonatomic, readonly, strong) NSOperationQueue *serialQueue;

#pragma mark - Instance
+ (TNRequestManager *)defaultManager;

/*!
 *  No URL Encoding!
 */
- (void)setCommonParameters:(NSDictionary *)parameters forMethod:(NSString *)method;
- (void)setCommonParameterValue:(NSString *)value forKey:(NSString *)key method:(NSString *)method;

- (void)setCommonHandler:(TNRequestCompletionHandler)handler forKey:(NSString *)key;

#pragma mark - Basic Request Function
/*!
 *  A request is a NSOperation.
 *  @param subpath The subpath append to http://.../ttx/service/
 *  @param headerFields Additional HTTP headers.
 *  @param getParams Query in URL.
 *  @param postParams Can be a file path(NSString)/params(NSDictionary)/binary data(NSData)
 *  @param responseClass A preffered class for parsing JSON, can be NULL. If NULL, responseObject in completion is nil.
 *  @param preparationHandler Always callback in current thread. call after all settings and before [NSOperationQueue addOperation:]
 *  @param completion Always callback in main thread.
 *  @param queue A queue that the request run in.
 *  @param wait Should block current thread until finished. If YES, request synchronous, else asynchronous.
 *  @param needToken Need ssoToken.
 *  @return The created request.
 */
- (TNRequest *)sendServiceRequestWithSubpath:(NSString *)subpath getParams:(NSDictionary *)getParams postParams:(id)postParams responseClass:(Class)responseClass preparationHandler:(TNRequestPreparationHandler)preparationHandler completion:(TNRequestCompletionHandler)completion inQueue:(NSOperationQueue *)queue waitUntilFinished:(BOOL)wait needToken:(BOOL)needToken;

/*!
 *  A convenient method to send a HTTP GET request.
 *  @param subpath The subpath append to http://.../ttx/service/
 *  @param params Get params.
 *  @param responseClass A preffered class for parsing JSON, can be NULL. If NULL, responseObject in completion is nil.
 *  @param completion Always callback in main thread.
 *  @return The created request.
 */
- (TNRequest *)getWithServcie:(NSString *)subpath params:(NSDictionary *)params responseClass:(Class)responseClass completion:(TNRequestCompletionHandler)completion;

/*!
 *  A convenient method to send a HTTP POST request. The responseObject in completion is a NSDictionary object.
 *  @param subpath The subpath append to http://.../ttx/service/
 *  @param params Post params.
 *  @param responseClass A preffered class for parsing JSON, can be NULL. If NULL, responseObject in completion is nil.
 *  @param completion Always callback in main thread.
 *  @return The created request.
 */
- (TNRequest *)postWithServcie:(NSString *)subpath params:(NSDictionary *)params responseClass:(Class)responseClass completion:(TNRequestCompletionHandler)completion;

/*!
 *  Send a request directly.
 *  @param request The request to send.
 *  @param responseClass A preffered class for parsing JSON, can be NULL. If NULL, responseObject in completion is nil.
 *  @param completion Always callback in main thread.
 *  @param queue A queue that the request run in.
 *  @param wait Should block current thread until finished. If YES, request synchronous, else asynchronous.
 */
- (void)sendRequest:(TNRequest *)request withResponseClass:(Class)responseClass completion:(TNRequestCompletionHandler)completion inQueue:(NSOperationQueue *)queue waitUntilFinished:(BOOL)wait;

/*!
 *  Return URL for resource located in the media server.
 *
 *  @return The specified URL for resource located in the image server.
 */
- (NSURL *)imageURLWithPath:(NSString *)imagePath;

- (NSURL *)voiceURLWithId:(NSString *)voiceId;

- (void)downloadVoiceWithId:(NSString *)voiceId destURL:(NSURL *)url completion:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))completion;

@end
