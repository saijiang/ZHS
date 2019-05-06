//
//  TNFormatUtil.h
//  TNAppLib
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNFormatUtil : NSObject

+ (NSString *)formatHTTPParams:(NSDictionary *)HTTPParams;
+ (NSDictionary *)parseHTTPParams:(NSString *)HTTPParamString;

@end
