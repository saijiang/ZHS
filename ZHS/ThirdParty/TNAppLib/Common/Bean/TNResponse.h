//
//  TNResponse.h
//  WeZone
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNBean.h"

extern NSString *const TNResponseCodeFailure;
extern NSString *const TNResponseCodeSuccess;
extern NSString *const TNResponseCodeAgain;
extern NSString *const TNResponseCodeExpiresTimeout;
extern NSString *const TNResponseCodeCodeExpiresTimeout;

@interface TNResponse : TNBean

@property (nonatomic, strong) NSString *code;

@property (nonatomic, readonly) BOOL isSuccess;

@end
