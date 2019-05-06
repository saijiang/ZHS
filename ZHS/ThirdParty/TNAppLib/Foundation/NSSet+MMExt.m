//
//  NSSet+MMExt.m
//  Mikoto
//
//  Created by xxd on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//


#import "NSSet+MMExt.h"
#import "NSArray+MMExt.h"
#import "NSDictionary+MMExt.h"

@implementation NSSet (MMExt)

- (NSSet *)setWithCleanNSNullValue
{
    NSMutableSet* newSet = [NSMutableSet set];
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSNull class]])
        {
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                [newSet addObject:[obj dictionaryWithCleanNSNullValue]];
            }
            else if ([obj isKindOfClass:[NSArray class]])
            {
                [newSet addObject:[obj arrayWithCleanNSNullValue]];
            }
            else if ([obj isKindOfClass:[NSArray class]])
            {
                [newSet addObject:[obj setWithCleanNSNullValue]];
            }
            else
            {
                [newSet addObject:obj];
            }
        }
    }];
    return newSet;
}

@end
