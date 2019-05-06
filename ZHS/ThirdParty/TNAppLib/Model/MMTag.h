//
//  MMTag.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  MMTag.  Base object with tag, be used to manager something.
//****************************************************************************************
//

#import <Foundation/Foundation.h>

@interface MMTag : NSObject
@property (nonatomic) NSInteger tag;
+ (instancetype)tagWithTag:(NSInteger)tag;

@end
