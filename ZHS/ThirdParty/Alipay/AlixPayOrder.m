//
//  AlixPayOrder.m
//  AliPay
//
//  Created by 邢小迪 on 15-1-06.
//  Copyright 2015 Alipay. All rights reserved.
//

#import "AlixPayOrder.h"

#pragma mark -
#pragma mark AlixPayOrder
@implementation AlixPayOrder





- (NSString *)description {
    NSMutableString * discription = [NSMutableString string];
    [discription appendFormat:@"partner=\"%@\"", self.partner ? self.partner : @""];
    [discription appendFormat:@"&seller_id=\"%@\"", self.seller ? self.seller : @""];
    [discription appendFormat:@"&out_trade_no=\"%@\"", self.tradeNO ? self.tradeNO : @""];
    [discription appendFormat:@"&subject=\"%@\"", self.productName ? self.productName : @""];
    [discription appendFormat:@"&body=\"%@\"", self.productDescription ? self.productDescription : @""];
    [discription appendFormat:@"&total_fee=\"%@\"", self.amount ? self.amount : @""];
    [discription appendFormat:@"&notify_url=\"%@\"", self.notifyURL ? self.notifyURL : @""];
    
    [discription appendFormat:@"&service=\"%@\"", self.serviceName ? self.serviceName : @"mobile.securitypay.pay"];
    [discription appendFormat:@"&_input_charset=\"%@\"", self.inputCharset ? self.inputCharset : @"utf-8"];
    [discription appendFormat:@"&payment_type=\"%@\"", self.paymentType ? self.paymentType : @"1"];
    
    //下面的这些参数，如果没有必要（value为空），则无需添加
    //	[discription appendFormat:@"&return_url=\"%@\"", self.returnUrl ? self.returnUrl : @"www.xxx.com"];
    //	[discription appendFormat:@"&it_b_pay=\"%@\"", self.itBPay ? self.itBPay : @"1d"];
    //	[discription appendFormat:@"&show_url=\"%@\"", self.showUrl ? self.showUrl : @"www.xxx.com"];
    
    
    for (NSString * key in [self.extraParams allKeys]) {
        [discription appendFormat:@"&%@=\"%@\"", key, [self.extraParams objectForKey:key]];
    }
    return discription;

}


@end
