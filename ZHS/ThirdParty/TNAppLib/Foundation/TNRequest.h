//
//  TNRequest.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNHttpStatusCode.h"

@class TNRequest;

/*!
 *  Progress block for TNRequest.
 *  @param request Current request.
 *  @param currentBytesLength The length of sended/received bytes.
 *  @param totalBytesLength The total length expected to write/read..
 */
typedef void (^TNRequestProgressBlock)(TNRequest *request, long long currentBytesLength, long long totalBytesLength);

/*!
 *  A Request is an operation of sending or receiving via http.
 *  @note It considers completionBlock to be its completion callback.
 */
@interface TNRequest : NSOperation <NSSecureCoding>

/*! The URL of current request */
@property (nonatomic, strong) NSURL *URL;

/*! Don't url encode the values. */
@property (nonatomic, strong) NSDictionary *HTTPGetParams;

/*! Priority: HTTPPostData > HTTPPostFilePath > HTTPPostParams. Don't url encode the values */
@property (nonatomic, strong) NSDictionary *HTTPPostParams;

/*! Don't url encode the values. */
@property (nonatomic, strong) NSString *HTTPPostFilePath;

/*! Don't url encode the values. */
@property (nonatomic, strong) NSData *HTTPPostData;

/*! Only contains special headers. */
@property (nonatomic, strong) NSDictionary *HTTPHeaderFields;

/*! An arbitrary dictionary that stores objects for callback. */
@property (nonatomic, strong) NSDictionary *userInfo;

/*! The request that created by request when calling start. */
@property (nonatomic, readonly, strong) NSMutableURLRequest *request;

/*! The real timeout seconds, maybe not equal to self.request.timeout. Default is 30 seconds. */
@property (nonatomic) NSTimeInterval timeoutInterval;

/*! Default is NSURLCacheStorageNotAllowed. */
@property (nonatomic) NSURLCacheStoragePolicy storagePolicy;

/*! The callback that called before starting the NSMutableURLRequest. */
@property (nonatomic, copy) void (^startBlock)(TNRequest *request);

/*! The callback among progress of sending data to server. */
@property (nonatomic, copy) TNRequestProgressBlock sendProgressBlock;

/*! The callback among progress of receiving data from server. */
@property (nonatomic, copy) TNRequestProgressBlock downloadProgressBlock;

/**
 *  @param response
 */
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, readonly) NSTimeInterval usedTimeInterval;

- (id)initWithURL:(NSURL *)URL;

- (void)startSynchronously;
- (void)startAsynchronouslyInQueue:(NSOperationQueue *)queue;

- (void)buildRequest;

@end
