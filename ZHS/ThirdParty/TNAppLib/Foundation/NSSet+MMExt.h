//
//  NSSet+MMExt.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
// Add some methods for NSSet.
//****************************************************************************************
//

#import <Foundation/Foundation.h>

@interface NSSet (MMExt)
/**
 *  creat a new set with all value of self except the value is NSNull class
 *
 *  @return a new set without NSNull value
 */
- (NSSet *)setWithCleanNSNullValue;

@end
