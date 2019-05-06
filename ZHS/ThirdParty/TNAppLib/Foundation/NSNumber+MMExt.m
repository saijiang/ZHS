//
//  NSNumber+MMExt.m
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//


#import "NSNumber+MMExt.h"

@implementation NSNumber (MMExt)

- (NSInteger)length
{
    if (!self) return 0;
    return [NSString stringWithFormat:@"%@",self].length;
}

@end
