//
//  MMHandle.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  MMHandle. Do something to manager an object.
//****************************************************************************************
//

#import <Foundation/Foundation.h>
#import "MMConstants.h"

@protocol MMHandleDelegate <NSObject>

@end

@interface MMHandle : NSObject
@property (weak, nonatomic) id<MMHandleDelegate> delegate;
@end
