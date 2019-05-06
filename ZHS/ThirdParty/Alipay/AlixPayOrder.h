//
//  AlixPayOrder.h
//  AliPay
//
//  Created by 邢小迪 on 15-1-06.
//  Copyright 2015 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlixPayOrder : NSObject

@property(nonatomic,copy) NSString *appName;
@property (nonatomic,copy) NSString *bizType;
@property(nonatomic, copy) NSString * partner;
@property(nonatomic, copy) NSString * seller;
@property(nonatomic, copy) NSString * tradeNO;
@property(nonatomic, copy) NSString * productName;
@property(nonatomic, copy) NSString * productDescription;
@property(nonatomic, copy) NSString * amount;
@property(nonatomic, copy) NSString * notifyURL;
@property(nonatomic, copy) NSString * serviceName;
@property(nonatomic, copy) NSString * inputCharset;
@property(nonatomic, copy) NSString * returnUrl;
@property(nonatomic, copy) NSString * paymentType;
@property(nonatomic, copy) NSString * itBPay;
@property(nonatomic, copy) NSString * showUrl;

@property(nonatomic, readonly) NSMutableDictionary * extraParams;

@end
