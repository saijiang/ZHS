//
//  ZHSSchoolbag.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/22.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSSchoolbag.h"

@implementation ZHSSchoolbag
+ (NSDictionary *)jsonMap
{
    static NSDictionary* map;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        map = @{
                @"ID":@"id",
                @"code":@"code",
                @"title":@"title",
                @"descriptions":@"description",
                @"ranking":@"ranking",
                @"books_list":@"books_list",
                @"images":@"images",
                @"tags":@"tags",
                @"class_level":@"class_level",
                @"status":@"status",
                @"qty_borrow":@"qty_borrow",
                
                };
    });
    return map;
}
@end
