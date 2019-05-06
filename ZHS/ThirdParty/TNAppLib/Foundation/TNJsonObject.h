//
//  TNJsonObject.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TNJsonObject <NSObject>

@required
- (id)initWithJsonValue:(NSDictionary *)jsonValue;
- (void)encodeWithJsonValueContainer:(NSMutableDictionary *)jsonValueContainer;
- (NSDictionary *)jsonValue;

@end
