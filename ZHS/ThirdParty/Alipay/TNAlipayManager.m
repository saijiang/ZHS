//
//  TNAlipayManager.m
//  WeZone
//
//  Created by 邢小迪 on 15-1-06.
//  Copyright (c) 2015年 Telenav. All rights reserved.
//

#import "TNAlipayManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AlixPayOrder.h"
#import "AlixPayResult.h"
#import "PartnerConfig.h"
#import "DataSigner.h"
#import "DataVerifier.h"
//#import "TNAppContext.h"
//#import "TNRequestManager.h"
NSString *const TNAlipayDidReceiveResultNotification = @"TNAlipayDidReceiveResultNotification";
NSString *const TNAlipaySuccessKey = @"TNAlipaySuccessKey";
NSString *const TNAlipayErrorCodeKey = @"TNAlipayErrorCodeKey";
NSString *const TNAlipayErrorMessageKey = @"TNAlipayErrorMessageKey";
NSString *const TNAlipayOrderIdKey = @"TNAlipayOrderIdKey";

@interface TNAlipayManager ()

@property (nonatomic, strong) AlixPayResult *result;

@end

@implementation TNAlipayManager

+ (TNAlipayManager *)defaultManager
{
    static dispatch_once_t onceToken;
    static TNAlipayManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    
    return instance;
}

-(NSString*)doRsa:(NSString*)orderInfo
{
    
    id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderInfo];
    return signedString;
}

- (void)sendOrderWithTradeNO:(NSString *)tradeNO  serialNumbers:(NSString *)serialNumbers productName:(NSString *)productName desc:(NSString *)desc price:(double)price orderString:(NSString *)orderString
{
//    AlixPayOrder *order = [[AlixPayOrder alloc] init];
//    order.partner = PartnerID;
//    order.seller = SellerID;
//    order.tradeNO = tradeNO; //订单ID（由商家自行制定）
//	order.productName = productName; //商品标题
//	order.productDescription = desc; //商品描述
////     replace price with 0.01
////	order.amount = [NSString stringWithFormat:@"%@", @(0.01)]; //商品价格
//    order.amount = [NSString stringWithFormat:@"%.2f", price]; //商品价格
////#warning 订单流水号
//    self.currentOrderId = order.tradeNO;
//    self.currentserialNumbers = serialNumbers;
//    NSString *url = @"http://api.wudiniao.com/alipay/notify_url/recharge";
//    order.notifyURL = url;
    NSString *appScheme = @"zhihuishu";
//    NSString* orderInfo = [order description];
//    NSString* signedStr = [self doRsa:orderInfo];
//    
//    //将签名成功字符串格式化为订单字符串,请严格按照该格式
//    NSString *orderString = nil;
//    if (signedStr != nil) {
//    orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
//                             orderInfo, signedStr, @"RSA"];
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            [self didReceiveResult:resultDic];
        }];
//    }
    
}

- (void)didReceiveResult:(NSDictionary *)resultString
{
//    NSString *orderId = self.currentserialNumbers;
//    self.currentserialNumbers = nil;
    //结果处理
//    LogDebug(@"didReceiveResult: %@", resultString);
//    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultString];
//	if (result)
//    {
//		
//		if (result.statusCode == 9000)
//        {
//            
//			/*
//			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
//			 */
//            
//            //交易成功
//            NSString* key = AlipayPubKey;//签约帐户后获取到的支付宝公钥
//			id<DataVerifier> verifier;
//            verifier = CreateRSADataVerifier(key);
//            
//			if ([verifier verifyString:result.resultString withSign:result.signString])
//            {
//                //验证签名成功，交易结果无篡改
                [[NSNotificationCenter defaultCenter] postNotificationName:TNAlipayDidReceiveResultNotification object:self userInfo:@{TNAlipaySuccessKey: @YES, TNAlipayOrderIdKey: @""}];
//			}
//        }
//        else
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:TNAlipayDidReceiveResultNotification object:self userInfo:@{TNAlipaySuccessKey: @NO, TNAlipayOrderIdKey: @"", TNAlipayErrorCodeKey: @(result.statusCode), TNAlipayErrorMessageKey: (result.statusMessage ? result.statusMessage : @"")}];
//        }
//    }
//    else
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:TNAlipayDidReceiveResultNotification object:self userInfo:@{TNAlipaySuccessKey: @NO, TNAlipayOrderIdKey: @""}];
//    }
}

@end
