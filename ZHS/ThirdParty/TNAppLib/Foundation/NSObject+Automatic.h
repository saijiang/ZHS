//
//  NSObject+Automatic.h
//  TNAppLib
//
//  Created by kiri on 2013-9-22.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNBeanSupport.h"

@interface NSObject (Automatic)

- (void)encodePropertiesWithCoder:(NSCoder *)aCoder class:(Class)clz;
- (void)decodePropertiesWithDecoder:(NSCoder *)aDecoder class:(Class)clz;
- (void)encodePropertiesWithJsonValueContainer:(NSMutableDictionary *)jsonValueContainer class:(Class)clz;
- (void)decodePropertiesWithJsonValue:(NSDictionary *)jsonValue class:(Class)clz;
- (void)copyPropertiesTo:(id)object withClass:(Class)clz zone:(NSZone *)zone;
- (void)deepCopyPropertiesTo:(id)object withClass:(Class)clz zone:(NSZone *)zone;

@end