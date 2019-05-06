//
//  THRequstManager.m
//  Tuhu
//
//  Created by 邢小迪 on 15/6/30.
//  Copyright (c) 2015年 telenav. All rights reserved.
//

#import "THRequstManager.h"
#import "AFNetworking.h"
#import "NSArray+MMExt.h"

@implementation THRequstManager

/**
 *  创建及获取单例对象的方法
 *
 *  @return 管理请求的单例对象
 */
+ (instancetype)sharedManager
{
    static THRequstManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[THRequstManager alloc] init];
    });
    return manager;
}

/**
 *  异步GET请求， 默认不阻断用户操作，返回信息显示0.8秒
 *
 *  @param url        请求的URL
 *  @param complete   请求完成后的回调Block，请求成功时，error为nil，responseObject为json对象，code为API返回的状态； 请求失败时，error不为nil，responseObject为nil，code为0
 */
- (void)asynGET:(NSString *)url withCompeletBlock:(THURLResponseBlock)complete
{
    [self asynGET:url blockUserInteraction:YES messageDuring:0.8 withCompeletBlock:complete];
}

/**
 *  异步GET请求，可设置是否阻断用户操作，以及返回的信息显示多长时间
 *
 *  @param url      请求的URL
 *  @param block    是否阻断用户操作
 *  @param duration 返回信息显示的时间, <= 0 时 不显示信息
 *  @param complete 请求完成后的回调Block，请求成功时，error为nil，responsObject为json对象，code为API返回的状态； 请求失败时，error不为nil，responseObject为nil，code为0
 */
- (void)asynGET:(NSString *)url blockUserInteraction:(BOOL)block messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete
{
    if (block)
    {
//        [TNToast showLoadingToast];
        [SVProgressHUD show];
        
    }
    [self asynAPIRequest:url params:nil method:@"GET" blockUserInteraction:block messageDuring:duration withCompeletBlock:complete];
}

/**
 *  异步POST请求， 默认不阻断用户操作，返回信息显示0.8秒
 *
 *  @param url        请求的URL(如果包含参数, 则自动编辑进parameters中，会覆盖parameter中的同名参数)
 *  @param parameters post的参数列表
 *  @param complete   请求完成后的回调Block，请求成功时，error为nil，responseObject为json对象，code为API返回的状态； 请求失败时，error不为nil，responseObject为nil，code为0
 */
- (void)asynPOST:(NSString *)url parameters:(NSDictionary *)parameters withCompeletBlock:(THURLResponseBlock)complete
{
    [self asynPOST:url parameters:parameters blockUserInteraction:YES messageDuring:0.8f withCompeletBlock:complete];
}

/**
 *  异步POST请求， 默认不阻断用户操作，返回信息显示0.8秒
 *
 *  @param url        请求的URL(如果包含参数, 则自动编辑进parameters中，会覆盖parameter中的同名参数)
 *  @param parameters post的参数列表
 *  @param block    是否阻断用户操作
 *  @param duration 返回信息显示的时间, <= 0 时 不显示信息
 *  @param complete   请求完成后的回调Block，请求成功时，error为nil，responseObject为json对象，code为API返回的状态； 请求失败时，error不为nil，responseObject为nil，code为0
 */
- (void)asynPOST:(NSString *)url parameters:(NSDictionary *)parameters blockUserInteraction:(BOOL)block messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete
{
    if (block)
    {
//        [TNToast showLoadingToast];
        [SVProgressHUD show];

    }
    [self asynAPIRequest:url params:parameters method:@"POST" blockUserInteraction:block messageDuring:duration withCompeletBlock:complete];
}

/**
 *  同步GET请求
 *
 *  @param url      请求的URL
 *  @param duration 返回信息显示的时间, <= 0 时 不显示信息
 *  @param complete   请求完成后的回调Block，请求成功时，error为nil，responseObject为json对象，code为API返回的状态； 请求失败时，error不为nil，responseObject为nil，code为0
 */
- (void)syncGET:(NSString *)url messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete
{
//    [TNToast showLoadingToast];
    [SVProgressHUD show];

    [self syncAPIRequest:url params:nil method:@"GET" messageDuring:duration withCompeletBlock:complete];
}

/**
 *  同步POST请求
 *
 *  @param url        请求的URL(如果包含参数, 则自动编辑进parameters中，会覆盖parameter中的同名参数)
 *  @param parameters post的参数列表
 *  @param duration 返回信息显示的时间, <= 0 时 不显示信息
 *  @param complete   请求完成后的回调Block，请求成功时，error为nil，responseObject为json对象，code为API返回的状态； 请求失败时，error不为nil，responseObject为nil，code为0
 */
- (void)syncPOST:(NSString *)url parameters:(NSDictionary *)parameters messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete
{
//    [TNToast showLoadingToast];
    [SVProgressHUD show];

    [self syncAPIRequest:url params:parameters method:@"POST" messageDuring:duration withCompeletBlock:complete];
}


#pragma mark - Private Methods
/**
 *  异步请求服务器接口，私有方法
 *
 *  @param url      请求的URL(如果包含参数, 则自动编辑进parameters中，会覆盖parameter中的同名参数)
 *  @param params   请求的参数列表
 *  @param method   请求方式：  ‘GET’ or ‘POST’
 *  @param duration 返回信息显示的时间, <= 0 时 不显示信息
 *  @param complete 请求完成后的回调
 */
- (void)asynAPIRequest:(NSString *)url params:(NSDictionary *)params method:(NSString *)method blockUserInteraction:(BOOL)block messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete
{
//    创建请求操作对象
    __block NSError *error = nil;
    AFHTTPRequestOperation *operation = [self creatHTTPRequestOperation:url params:params withMethod:method error:&error];
    if (!error && operation) // 若创建成功，设置请求完成的回调，并发起请求（将操作对象加入操作队列中，并执行）
    {
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (block) [SVProgressHUD dismiss];
//                [TNToast hideLoadingToast];
            NSInteger code = [responseObject[@"status"] integerValue];
            
            MMLog(@"\n-----THRequestManager LOG: -----\n-- RequestUrl: %@\n-- Method: %@\n-- ResponseData: %@\n",
                  CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)operation.request.URL.absoluteString, CFSTR(""),kCFStringEncodingUTF8)),
                  [method isEqualToString:@"GET"]? @"GET": [NSString stringWithFormat:@"POST\n-- Params: %@", [self formatParametersForURL:url withParams:params]],
                  responseObject);
            
            if (!responseObject || (![responseObject isKindOfClass:[NSDictionary class]] && ![responseObject isKindOfClass:[NSArray class]])) // 若解析数据格式异常，返回错误
            {
                if (duration > 0)
                {
                    [TNToast showWithText:@"数据异常，请稍后重试或重启应用" duration:duration];
                }
                error = [NSError errorWithDomain:@"TH_API_RequestErrorDomain"
                                            code:THRequstErrorCodeInvalidResponse
                                        userInfo:@{
                                                   @"api": url?:@"",
                                                   @"param": params?:@"null",
                                                   @"description": @"invalid response"
                                                   }];
                if (complete)
                {
                    complete(responseObject, THRequstErrorCodeInvalidResponse, error);
                }
            }
            else // 若解析数据正常，判断API返回的code，
            {
                if (code == 0)
                {
                    NSString *message = responseObject[@"message"];
                    if (message.length && duration > 0)
                    {
                        [TNToast showWithText:message duration:duration];
                    }
                    error = [NSError errorWithDomain:@"TH_API_RequestErrorDomain"
                                                code:THRequstErrorCodeAPIError
                                            userInfo:@{
                                                       @"api": url?:@"",
                                                       @"param": params?:@"null",
                                                       @"description": message?:@"no message"
                                                       }];
                }
                if (complete)
                {
                    complete(responseObject, code, error);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block) [SVProgressHUD dismiss];
//                [TNToast hideLoadingToast];
            if (duration > 0)
            {
                [TNToast showWithText:@"网络异常，请稍后重试" duration:duration];
            }
            
            MMLog(@"\n-----THRequestManager ERROR: -----\n-- RequestUrl: %@\n-- Method: %@\n-- ErrorDomain: %@\n-- Error: %@\n",
                  CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)operation.request.URL.absoluteString, CFSTR(""),kCFStringEncodingUTF8)),
                  [method isEqualToString:@"GET"]? @"GET": [NSString stringWithFormat:@"POST\n-- Params: %@", [self formatParametersForURL:url withParams:params]],
                  error.domain,
                  error);
            
            if (complete)
            {
                complete(nil, THRequstErrorCodeConnectionError, error);
            }
        }];
        [operation start];
    }
    else // 若创建不成功， 返回错误，url 无效
    {
        if (block) [SVProgressHUD dismiss];
//        [TNToast hideLoadingToast];
        [TNToast showWithText:@"无效的网络请求，请稍后重试或重启应用" duration:0.8];
        if (complete)
        {
            complete(nil, THRequstErrorCodeInvalidURL, error);
        }
    }
}

/**
 *  同步请求服务器接口，私有方法
 *
 *  @param url      请求的URL(如果包含参数, 则自动编辑进parameters中，会覆盖parameter中的同名参数)
 *  @param params   请求的参数列表
 *  @param method   请求方式：  ‘GET’ or ‘POST’
 *  @param duration 返回信息显示的时间, <= 0 时 不显示信息
 *  @param complete 请求完成后的回调
 */
- (void)syncAPIRequest:(NSString *)url params:(NSDictionary *)params method:(NSString *)method messageDuring:(NSTimeInterval)duration withCompeletBlock:(THURLResponseBlock)complete
{
//    创建请求对象
    NSError *error = nil;
    NSURLRequest *request = [self creatURLRequest:url params:params synchronous:YES withMethod:method error:&error];
    if (request) // 若创建成功，发起同步请求
    {
        NSURLResponse *response = nil;
//        发起同步请求
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//        [TNToast hideLoadingToast];
        [SVProgressHUD dismiss];
        if (!error && responseData) // 若无错误返回
        {
//            解析返回数据
            id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            MMLog(@"\n-----THRequestManager LOG: -----\n-- RequestUrl: %@\n-- Method: %@\n-- ResponseData: %@\n",
                  CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)request.URL.absoluteString, CFSTR(""),kCFStringEncodingUTF8)),
                  [method isEqualToString:@"GET"]? @"GET": [NSString stringWithFormat:@"POST\n-- Params: %@", [self formatParametersForURL:url withParams:params]],
                  responseObject);
            
            if (!error && responseObject) // 若解析成功， 判断API返回的code
            {
//                清理NSNull对象
                if ([responseObject isKindOfClass:[NSArray class]])
                {
                    responseObject = [responseObject arrayWithCleanNSNullValue];
                }
                else if ([responseObject isKindOfClass:[NSDictionary class]])
                {
                    responseObject = [responseObject dictionaryWithCleanNSNullValue];
                }
                
                NSInteger code = [responseObject[@"status"] integerValue];
                if (code == 0)
                {
                    NSString *message = responseObject[@"message"];
                    if (message.length && duration > 0)
                    {
                        [TNToast showWithText:message duration:duration];
                    }
                    error = [NSError errorWithDomain:@"TH_API_RequestErrorDomain"
                                                code:THRequstErrorCodeAPIError
                                            userInfo:@{
                                                       @"api": url?:@"",
                                                       @"param": params?:@"null",
                                                       @"description": message?:@"no message"
                                                       }];
                }
                if (complete)
                {
                    complete(responseObject, code, error);
                }
            }
            else // 若解析数据失败， 返回错误信息
            {
                [TNToast showWithText:@"数据异常，请稍后重试或重启应用" duration:0.8];
                error = [NSError errorWithDomain:@"TH_API_RequestErrorDomain"
                                            code:THRequstErrorCodeInvalidResponse
                                        userInfo:error.userInfo];
                if (complete)
                {
                    complete(responseData, THRequstErrorCodeInvalidResponse, error);
                }
            }
        }
        else // 若请求失败， 返回错误信息
        {
            if (duration > 0)
            {
                [TNToast showWithText:@"网络异常，请稍后重试" duration:duration];
            }
            MMLog(@"\n-----THRequestManager ERROR: -----\n-- RequestUrl: %@\n-- Method: %@\n-- ErrorDomain: %@\n-- Error: %@\n",
                  CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)request.URL.absoluteString, CFSTR(""),kCFStringEncodingUTF8)),
                  [method isEqualToString:@"GET"]? @"GET": [NSString stringWithFormat:@"POST\n-- Params: %@", [self formatParametersForURL:url withParams:params]],
                  error.domain,
                  error);
            
            if (complete)
            {
                complete(nil, THRequstErrorCodeConnectionError, error);
            }
        }
    }
    else // 若创建不成功， 返回错误，url 无效
    {
//        [TNToast hideLoadingToast];
        [SVProgressHUD dismiss];
        if (duration > 0)
        {
            [TNToast showWithText:@"无效的网络请求，请稍后重试或重启应用" duration:duration];
        }
        if (complete)
        {
            complete(nil, THRequstErrorCodeInvalidURL, error);
        }
    }
}

#pragma mark creat request methods
- (AFHTTPRequestOperation *)creatHTTPRequestOperation:(NSString *)url params:(NSDictionary *)params withMethod:(NSString *)method error:(NSError *__autoreleasing *)error
{
//    创建请求对象
    NSURLRequest *request = [self creatURLRequest:url params:params synchronous:NO withMethod:method error:error];
    if (!*error && request) // 若创建成功，创建请求操作对象，并返回
    {
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers]; // 设置请求返回的json解析对象
        responseSerializer.removesKeysWithNullValues = YES; // 清除返回数据的 NSNull
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/x-javascript", @"application/json", @"text/json", @"text/javascript", @"text/html", nil]; // 设置接受数据的格式
        operation.responseSerializer = responseSerializer;
        operation.securityPolicy = [self creatCustomPolicy]; // 设置请求操作对象的 安全策略， https 请求时使用
        return operation;
    }
    else // 若创建不成功， 返回nil
    {
        return nil;
    }
}

- (AFSecurityPolicy *)creatCustomPolicy
{
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    policy.allowInvalidCertificates = YES;
    return policy;
}

- (NSDictionary *)formatParametersForURL:(NSString *)url withParams:(NSDictionary *)params
{
//    清除参数中的NSNull对象
    NSMutableDictionary *fixedParams = [(params? [params dictionaryWithCleanNSNullValue]: @{}) mutableCopy];
    
//    分离URL中的参数信息
    NSArray *urlComponents = [url componentsSeparatedByString:@"?"];
    NSArray *paramsComponets = urlComponents.count>=2 ? [urlComponents[1] componentsSeparatedByString:@"&"] : nil;
    [paramsComponets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *paramComponets = [obj componentsSeparatedByString:@"="];
        if (!fixedParams[paramsComponets[0]])
        {
            [fixedParams setObject:(paramComponets.count>=2 ? paramComponets[1] : @"") forKey:paramComponets[0]];
        }
    }];
    
//    检查param的个数，为0时，置为nil
    fixedParams = fixedParams.allKeys.count ? fixedParams : nil;
    return fixedParams;
}

- (NSURLRequest *)creatURLRequest:(NSString *)url params:(NSDictionary *)params synchronous:(BOOL)sync withMethod:(NSString *)method error:(NSError *__autoreleasing *)error
{
//  URL为空或空字符串时，直接返回nil
    if (!url.length)
    {
        MMLog(@"\n-----THRequestManager ERROR: -----\n-- RequestUrl: %@\n-- Method: %@\n-- ErrorDomain: Creat Request Error\n-- Error: request url is nil\n", url, [method isEqualToString:@"GET"]? @"GET": [NSString stringWithFormat:@"POST\n-- Params: %@", params]);
        *error = [NSError errorWithDomain:@"TH_API_RequestErrorDomain"
                                     code:THRequstErrorCodeInvalidURL
                                 userInfo:@{
                                            @"api": url?:@"",
                                            @"param": params?:@"null",
                                            @"description": @"invalid url"
                                            }];
        return nil;
    }
    
//    如果是POST请求，分离URL中的参数信息, 重建参数列表
    if ([method isEqualToString:@"POST"])
    {
        params = [self formatParametersForURL:url withParams:params];
        url = [url componentsSeparatedByString:@"?"][0];
    }
    
//    创建同步或异步请求
    NSMutableURLRequest *request = sync ? [self creatSyncRequest:url params:params withMethod:method error:error] : [self creatAsynRequest:url params:params withMethod:method error:error];
    
    if (*error)
    {
        MMLog(@"\n-----THRequestManager ERROR: -----\n-- RequestUrl: %@\n-- Method: %@\n-- ErrorDomain: Creat Request Error\n-- Error: %@\n",
              CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)request.URL.absoluteString, CFSTR(""),kCFStringEncodingUTF8)),
              [method isEqualToString:@"GET"]? @"GET": [NSString stringWithFormat:@"POST\n-- Params: %@", params],
              *error);
    }
    else
    {
        MMLog(@"\n-----THRequestManager LOG: -----\n-- RequestUrl: %@\n-- Method: %@\n",
              CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)request.URL.absoluteString, CFSTR(""),kCFStringEncodingUTF8)),
              [method isEqualToString:@"GET"]? @"GET": [NSString stringWithFormat:@"POST\n-- Params: %@", params]);
    }
//    添加请求头验证信息
    [self formatRequestHeader:request];
    
    return request;
}

- (NSMutableURLRequest *)creatAsynRequest:(NSString *)url params:(NSDictionary *)params withMethod:(NSString *)method error:(NSError *__autoreleasing *)error
{
    //    创建URL请求对象
    NSMutableURLRequest *request;
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
    {
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if ([method isEqualToString:@"GET"])
    {
        request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:params error:error];
    }
    else if ([method isEqualToString:@"POST"])
    {
        //        POST请求时，分离参数中的字符串参数和文件数据
        NSMutableDictionary *values = [params mutableCopy]; // 保存 字符串参数
        NSMutableDictionary *files = [@{} mutableCopy]; // 保存 文件数据
        [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            // 类型为 NSData 或者 UIImage 时，从参数列表中删除，添加至文件列表，并将UIImage对象转化为NSData类型
            if ([obj isKindOfClass:[NSData class]] || [obj isKindOfClass:[UIImage class]])
            {
                [values removeObjectForKey:key];
                [files setObject:[obj isKindOfClass:[UIImage class]]? UIImageJPEGRepresentation(obj, 0.1): obj forKey:key];
            }
        }];
        request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                             URLString:url
                                                                            parameters:values
                                                             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                 // 将文件列表中的数据逐个添加到请求对象中
                                                                 [files enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSData *obj, BOOL *stop) {
                                                                     [formData appendPartWithFileData:obj name:key fileName:[NSString stringWithFormat:@"%@.jpeg", key] mimeType:@"image/jpeg"];
                                                                 }];
                                                             } error:error];
    }
    return request;
}

- (NSMutableURLRequest *)creatSyncRequest: (NSString *)url params:(NSDictionary *)params withMethod:(NSString *)method error:(NSError *__autoreleasing *)error
{
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
    {
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
      if ([method isEqualToString:@"GET"])
    {
        request.HTTPMethod = @"GET";
    }
    else if ([method isEqualToString:@"POST"])
    {
        request.HTTPMethod = @"POST";
        
        NSMutableString *formatParams = [NSMutableString string];
        NSArray *keys = params.allKeys;
        [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            [formatParams appendFormat:@"%@=%@", key, params[key]];
            if (idx < keys.count - 1)
            {
                [formatParams appendString:@"&"];
            }
        }];
        request.HTTPBody = [formatParams dataUsingEncoding:NSUTF8StringEncoding];
    }
    return request;
}


- (void)formatRequestHeader:(NSMutableURLRequest *)request
{
//    NSString *usersession = [[NSUserDefaults standardUserDefaults] valueForKey:@"usersession"];
//    NSString* tmpVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [request addValue:usersession?:@"0" forHTTPHeaderField:@"usersession"];
//    [request addValue:[NSString stringWithFormat:@"iOS %@", tmpVersion] forHTTPHeaderField:@"version"];
    NSString *token = [NSString stringWithFormat:@"Bearer %@",[TNAppContext currentContext].user.token?:@""];
    MMLog(@"+++++++++%@",token);
    [request addValue:token forHTTPHeaderField:@"Authorization"];
}

@end
