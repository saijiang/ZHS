//
//  ZHSBorrowLog.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/13.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSBorrowLog.h"

@implementation ZHSBorrowLog
+ (NSDictionary *)jsonMap
{
    static NSDictionary* map;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        map = @{
                @"ID":@"id",
                @"borrow_start":@"borrow_start",
                @"borrow_end":@"borrow_end",
                @"status":@"status",
                @"borrow_code":@"borrow_code",
                @"created_at":@"created_at",
                @"return_at":@"return_at",
                @"updated_at":@"updated_at"


                };
    });
    return map;
}

@end
