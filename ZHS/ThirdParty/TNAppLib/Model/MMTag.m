//
//  MMTag.m
//  Mikoto
//
//  Created by xxd on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "MMTag.h"

@implementation MMTag
+ (instancetype)tagWithTag:(NSInteger)tag
{
    MMTag* object = [[self alloc] init];
    object.tag = tag;
    return object;
}
@end
