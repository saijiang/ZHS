//
//  TNWXPayManager.m
//  Tuhu
//
//  Created by DengQiang on 14/11/10.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import "TNWXPayManager.h"
#import "CommonUtil.h"

/**
 *  微信开放平台申请得到的 appid, 需要同时添加在 URL schema
 */
NSString * const WXAppId = @"wxc35fb65a4617b718";

/**
 * 微信开放平台和商户约定的支付密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
NSString * const WXAppKey = @"VkTdzVwIMqCra20vqk8XlUwsaWdJm9OzxlxTMFnI8He4SiqxHQbNy4EhSop3nG4nSzJHSBjiCJzQ1JSs5ljfk5WkadqnuWCCL9bQbKAUKmUCBwvZBdxOcHYSdUOm1OfF"; // wx439e9b8e23a6e90f 对应的支付密钥

/**
 * 微信开放平台和商户约定的密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
NSString * const WXAppSecret = @"0b6eb8c41ea551bb337f7a8ff8f5fa20";


/**
 * 微信开放平台和商户约定的支付密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
NSString * const WXPartnerKey = @"8888049e6dbb3aacfd9b0243aaa8e86d";


/**
 *  微信公众平台商户模块生成的ID
 */
NSString * const WXPartnerId = @"1219017401";

NSString *const TNWeChatpayDidReceiveResultNotification = @"TNWeChatpayDidReceiveResultNotification";
NSString *const TNWeChatPayErrorCodeKey = @"TNWeChatPayErrorCodeKey";
NSString *const TNWeChatPaySuccessKey = @"TNWeChatPaySuccessKey";


NSString *AccessTokenKey = @"access_token";
NSString *PrePayIdKey = @"prepayid";
NSString *errcodeKey = @"errcode";
NSString *errmsgKey = @"errmsg";
NSString *expiresInKey = @"expires_in";


@interface TNWXPayManager ()<WXApiDelegate>
{
    NSString *nunmer;
    NSString *titl;
    double pric;
    NSDictionary *json;
}
@property (nonatomic, copy) NSString *timeStamp;
@property (nonatomic, copy) NSString *nonceStr;
@property (nonatomic, copy) NSString *traceId;

@property (nonatomic, strong) NSDate *tokenTime;
@property (nonatomic, strong) NSString *accessToken;

@end

@implementation TNWXPayManager

+ (TNWXPayManager *)defaultManager
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (void)registerClients
{
    [WXApi registerApp:WXAppId];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
            case WXSuccess:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:TNWeChatpayDidReceiveResultNotification object:nil userInfo:@{TNWeChatPaySuccessKey: @YES, TNWeChatPayErrorCodeKey: @(response.errCode)}];
                break;
            }
            case WXErrCodeCommon:
            {
                [TNToast showWithText:@"网络有问题，请稍后再试！"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:TNWeChatpayDidReceiveResultNotification object:nil userInfo:@{ TNWeChatPayErrorCodeKey: @(response.errCode)}];
                [self payWithTradeNo:nunmer title:titl price:pric notifyURL:nil jsonDic:json completion:nil];
                break;
            }
            default:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:TNWeChatpayDidReceiveResultNotification object:nil userInfo:@{TNWeChatPaySuccessKey: @NO, TNWeChatPayErrorCodeKey: @(response.errCode)}];
                break;
            }
        }
        
        
    }
}

- (void)clear
{
    // TODO: clear
}

- (void)dealloc
{
    [self clear];
}

#pragma mark - 生成各种参数

- (NSString *)genTimeStamp
{
    return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
}

/**
 * 注意：商户系统内部的订单号,32个字符内、可包含字母,确保在商户系统唯一
 */
- (NSString *)genNonceStr
{
    return [CommonUtil md5:[NSString stringWithFormat:@"%d", arc4random() % 10000]];
}

/**
 * 建议 traceid 字段包含用户信息及订单信息，方便后续对订单状态的查询和跟踪
 */
- (NSString *)genTraceId
{
    return [NSString stringWithFormat:@"crestxu_%@", [self genTimeStamp]];
}

- (NSString *)genOutTradNo
{
    return [CommonUtil md5:[NSString stringWithFormat:@"%d", arc4random() % 10000]];
}

- (NSString *)genPackageWithTitle:(NSString *)title orderNo:(NSString *)orderNo price:(double)price
{
    // 构造参数列表
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"WX" forKey:@"bank_type"];
    //    [params setObject:title forKey:@"body"];
    [params setObject:title forKey:@"body"];
    [params setObject:@"1" forKey:@"fee_type"];
    [params setObject:@"UTF-8" forKey:@"input_charset"];
    [params setObject:@"http://wx.tuhu.cn/apppayback.aspx" forKey:@"notify_url"];
    [params setObject:orderNo forKey:@"out_trade_no"];
    //    [params setObject:[self genOutTradNo] forKey:@"out_trade_no"];
    [params setObject:WXPartnerId forKey:@"partner"];
    [params setObject:[CommonUtil getIPAddress:YES] forKey:@"spbill_create_ip"];
    [params setObject:[NSString stringWithFormat:@"%.0f", price] forKey:@"total_fee"];    // 1 =＝ ¥0.01
//        [params setObject:@"1" forKey:@"total_fee"];    // 1 =＝ ¥0.01
    
    
    NSArray *keys = [params allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    // 生成 packageSign
    NSMutableString *package = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [package appendString:key];
        [package appendString:@"="];
        [package appendString:[params objectForKey:key]];
        [package appendString:@"&"];
    }
    
    [package appendString:@"key="];
    [package appendString:WXPartnerKey]; // 注意:不能hardcode在客户端,建议genPackage这个过程都由服务器端完成
    
    // 进行md5摘要前,params内容为原始内容,未经过url encode处理
    NSString *packageSign = [[CommonUtil md5:[package copy]] uppercaseString];
    package = nil;
    
    // 生成 packageParamsString
    NSString *value = nil;
    package = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [package appendString:key];
        [package appendString:@"="];
        value = [params objectForKey:key];
        
        // 对所有键值对中的 value 进行 urlencode 转码
        value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)value, nil, (CFStringRef)@"!*'&=();:@+$,/?%#[]", kCFStringEncodingUTF8));
        
        [package appendString:value];
        [package appendString:@"&"];
    }
    NSString *packageParamsString = [package substringWithRange:NSMakeRange(0, package.length - 1)];
    
    NSString *result = [NSString stringWithFormat:@"%@&sign=%@", packageParamsString, packageSign];
    
    MMLog(@"--- Package: %@", result);
    
    return result;
}

- (NSString *)genSign:(NSDictionary *)signParams
{
    // 排序
    NSArray *keys = [signParams allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    // 生成
    NSMutableString *sign = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [sign appendString:key];
        [sign appendString:@"="];
        [sign appendString:[signParams objectForKey:key]];
        [sign appendString:@"&"];
    }
    NSString *signString = [[sign copy] substringWithRange:NSMakeRange(0, sign.length - 1)];
    
    NSString *result = [CommonUtil sha1:signString];
//    NSLog(@"--- Gen sign: %@", result);
    return result;
}

- (NSMutableData *)getProductArgsWithTitle:(NSString *)title orderNo:(NSString *)orderNo price:(double)price
{
    self.timeStamp = [self genTimeStamp];
    self.nonceStr = [self genNonceStr]; // traceId 由开发者自定义，可用于订单的查询与跟踪，建议根据支付用户信息生成此id
    self.traceId = [self genTraceId];
//    NSString *package = [self genPackageWithTitle:title orderNo:orderNo price:price];
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setObject:WXAppId forKey:@"appid"];
//    [params setObject:WXAppKey forKey:@"appkey"];
//    [params setObject:self.nonceStr forKey:@"noncestr"];
//    [params setObject:self.timeStamp forKey:@"timestamp"];
//    [params setObject:self.traceId forKey:@"traceid"];
//    [params setObject:package forKey:@"package"];
//    [params setObject:[self genSign:params] forKey:@"app_signature"];
//    [params setObject:@"sha1" forKey:@"sign_method"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error: &error];
//    NSLog(@"--- ProductArgs: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    return [NSMutableData dataWithData:jsonData];
}

#pragma mark - Requests

- (void)queryAccessTokenCompletion:(void (^)(BOOL succeeded, NSError *error))completion;
{
    NSString *getAccessTokenUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%@&secret=%@", WXAppId, WXAppSecret];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:getAccessTokenUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        NSError *error = nil;
        if (httpResp.statusCode == 200 && data.length > 0) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            self.accessToken = dict[AccessTokenKey];
            self.tokenTime = [NSDate date];
            completion(YES, error);
        } else {
            completion(NO, error);
        }
    }];
    
    
}

#pragma mark - 主体流程

- (void)queryPrepayIdWithTitle:(NSString *)title orderNo:(NSString *)orderNo price:(double)price completion:(void (^)(NSDictionary *prePayIdResponse, NSError *error))completion
{
    NSString *baseurl = [NSString stringWithFormat:@"https://api.weixin.qq.com/pay/genprepay?access_token=%@", self.accessToken];
    NSMutableData *postData = [self getProductArgsWithTitle:title orderNo:orderNo price:price];
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:60];
    [request setHTTPMethod: @"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        NSError *error = nil;
        if (httpResp.statusCode == 200 && data.length > 0) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            MMLog(@"-- prepayIdResponse:%@", dict);
            completion(dict, error);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)requestWithPrepayIdResponse:(NSDictionary *)prePayIdResponse
{
    NSString *prePayId = prePayIdResponse[PrePayIdKey];
    if (prePayId) {
//        NSLog(@"--- PrePayId: %@", prePayId);
        
        // 调起微信支付
        PayReq *request   = [[PayReq alloc] init];
        request.partnerId = WXPartnerId;
        request.prepayId  = prePayId;
        request.package   = @"Sign=WXPay";      // 文档为 `Request.package = _package;` , 但如果填写上面生成的 `package` 将不能支付成功
        request.nonceStr  = self.nonceStr;
        request.timeStamp = [[NSDate date] timeIntervalSince1970];
        
        // 构造参数列表
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:WXAppId forKey:@"appid"];
        [params setObject:WXAppKey forKey:@"appkey"];
        [params setObject:request.nonceStr forKey:@"noncestr"];
        [params setObject:request.package forKey:@"package"];
        [params setObject:request.partnerId forKey:@"partnerid"];
        [params setObject:request.prepayId forKey:@"prepayid"];
        [params setObject:self.timeStamp forKey:@"timestamp"];
        request.sign = [self genSign:params];
        
        // 在支付之前，如果应用没有注册到微信，应该先调用 [WXApi registerApp:appId] 将应用注册到微信
        [self registerClients];
        
        MMLog(@"%@", request.prepayId);
        
//        [WXApi safeSendReq:request];
        
    } else {
        NSString *strMsg = [NSString stringWithFormat:@"errcode: %@, errmsg:%@", prePayIdResponse[errcodeKey], prePayIdResponse[errmsgKey]];
        [self showAlertWithTitle:@"错误" msg:strMsg];
    }
}

#pragma mark - Pay

- (void)payWithTradeNo:(NSString *)tradeNo title:(NSString *)title price:(double)price notifyURL:(NSString *)notifyURL jsonDic:(NSDictionary*)jsonDic completion:(void (^)(BOOL success, NSError *error))completion
{
    nunmer = tradeNo;
    titl = title;
    pric = price;
    json = jsonDic;
    if (![WXApi isWXAppInstalled]) {
        [TNToast showWithText:@"您还没有安装微信，无法继续微信支付哦～"];
        if (completion) {
            completion(NO, nil);
        }
        return;
    }
    
    
    PayReq *request = [[PayReq alloc] init];
    
    request.partnerId = jsonDic[@"partnerid"];
    
    request.prepayId= jsonDic[@"prepayid"];
    
    request.package = jsonDic[@"package"];
    
    request.nonceStr= jsonDic[@"noncestr"];
    
    request.timeStamp= [jsonDic[@"timestamp"] intValue];
    
    request.sign= jsonDic[@"sign"];
    
    [WXApi sendReq:request];

//    if ([self isAccessTokenValid]) {
//        [TNToast showLoadingToastWithStyle:UIActivityIndicatorViewStyleGray blockUserInteraction:NO];
//        [self queryPrepayIdWithTitle:title orderNo:tradeNo price:price completion:^(NSDictionary *prePayIdResponse, NSError *error) {
//            [TNToast hideLoadingToast];
//            if (prePayIdResponse != nil) {
//                [self requestWithPrepayIdResponse:prePayIdResponse];
//            }
//        }];
//    } else {
//        [TNToast showLoadingToastWithStyle:UIActivityIndicatorViewStyleGray blockUserInteraction:NO];
//        [self queryAccessTokenCompletion:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                [self queryPrepayIdWithTitle:title orderNo:tradeNo price:price completion:^(NSDictionary *prePayIdResponse, NSError *error) {
//                    [TNToast hideLoadingToast];
//                    if (prePayIdResponse != nil) {
//                        [self requestWithPrepayIdResponse:prePayIdResponse];
//                    }
//                }];
//            } else {
//                [TNToast hideLoadingToast];
//                [TNToast showWithText:@"支付失败，请稍候再试~"];
//            }
//        }];
//    }
    
}

- (BOOL)isAccessTokenValid
{
    if (self.tokenTime == nil) {
          NO;
    }
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:self.tokenTime];
    return duration > 0 && duration < 7200;
}

#pragma mark - Alert

- (void)showAlertWithTitle:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end
