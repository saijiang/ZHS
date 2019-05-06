//
//  TNTransferObject.h
//  TTX
//
//  Created by zhdong on 13-11-11.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNBean.h"

typedef NS_ENUM(NSInteger, TNTransferStatus) {
    TNTransferStatusNotSend = 0,
    TNTransferStatusSending,
    TNTransferStatusSendSuccess,
    TNTransferStatusSendFail
};

@interface TNTransferObject : TNBean

@property (nonatomic) TNTransferStatus status;
@property (nonatomic, strong) NSDate *lastSendTime;

@end
