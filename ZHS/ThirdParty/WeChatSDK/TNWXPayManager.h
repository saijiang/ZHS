//
//  TNWXPayManager.h
//  Tuhu
//
//  Created by DengQiang on 14/11/10.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"


extern NSString *const TNWeChatpayDidReceiveResultNotification;
extern NSString *const TNWeChatPayErrorCodeKey;
extern NSString *const TNWeChatPaySuccessKey;

@interface TNWXPayManager : NSObject
{
    NSMutableDictionary *dic;
    PayReq *payReq;
}
+ (TNWXPayManager *)defaultManager;

- (void)registerClients;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)payWithTradeNo:(NSString *)tradeNo title:(NSString *)title price:(double)price notifyURL:(NSString *)notifyURL jsonDic:(NSDictionary*)jsonDic completion:(void (^)(BOOL success, NSError *error))completion;

@end
