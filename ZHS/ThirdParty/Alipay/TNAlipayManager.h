//
//  TNAlipayManager.h
//  WeZone
//
//  Created by 邢小迪 on 15-1-06.
//  Copyright (c) 2015年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TNAlipayDidReceiveResultNotification;
extern NSString *const TNAlipaySuccessKey;
extern NSString *const TNAlipayErrorCodeKey;
extern NSString *const TNAlipayErrorMessageKey;
extern NSString *const TNAlipayOrderIdKey;

@interface TNAlipayManager : NSObject

+ (TNAlipayManager *)defaultManager;

@property (nonatomic, strong) NSString *currentOrderId;
@property (nonatomic, strong) NSString *currentserialNumbers;

- (void)sendOrderWithTradeNO:(NSString *)tradeNO serialNumbers:(NSString *)serialNumbers productName:(NSString *)productName desc:(NSString *)desc price:(double)price orderString:(NSString *)orderString;
- (void)didReceiveResult:(NSDictionary *)result;

@end
