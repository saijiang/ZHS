//
//  THRequstManager.h
//  Tuhu
//
//  Created by 邢小迪 on 15/6/30.
//  Copyright (c) 2015年 telenav. All rights reserved.
//
//****************************************************************************************
//  网络请求 管理类， 封装同步和异步的请求方法，做统一的异常处理，和请求头等通用编辑
//****************************************************************************************
//

typedef enum : NSUInteger {
    THRequstErrorCodeNoneError = 1,                             // 请求成功
    THRequstErrorCodeAPIError = 0,                              // 请求失败，API返回失败信息
    THRequstErrorCodeInvalidURL = 1000,                      // 请求失败， 无效的URL
    THRequstErrorCodeInvalidResponse = 1001,                // 请求失败， 无效的返回数据
    THRequstErrorCodeConnectionError = 1002,               // 请求失败， 链接错误
} THRequstErrorCode;

// 请求方法的回调Block类型
typedef void(^THURLResponseBlock)(id responseObject, THRequstErrorCode code, NSError *error);

#import <Foundation/Foundation.h>

@interface THRequstManager : NSObject

// 获取单例的方法
+ (instancetype)sharedManager;

// 异步GET请求
- (void)asynGET:(NSString *)url withCompeletBlock:(THURLResponseBlock)complete;
- (void)asynGET:(NSString *)url blockUserInteraction:(BOOL)block messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete;
// 异步POST请求(上传文件或图片可用)
- (void)asynPOST:(NSString *)url parameters:(NSDictionary *)parameters withCompeletBlock:(THURLResponseBlock)complete;
- (void)asynPOST:(NSString *)url parameters:(NSDictionary *)parameters blockUserInteraction:(BOOL)block messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete;

// 同步GET请求
- (void)syncGET:(NSString *)url messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete;
// 同步POST请求(上传文件或图片可用)
- (void)syncPOST:(NSString *)url parameters:(NSDictionary *)parameters messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete;

@end
