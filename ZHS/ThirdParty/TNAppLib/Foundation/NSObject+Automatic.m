//
//  NSObject+Automatic.m
//  TNAppLib
//
//  Created by kiri on 2013-9-22.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "NSObject+Automatic.h"
#import <objc/runtime.h>
#import "TNBeanSupport.h"
#import "TNJsonUtil.h"
#import "NSDate+TNAppLib.h"
#import "NSDictionary+TNAppLib.h"
#import "TNAppLibMacros.h"

@implementation NSObject (Automatic)

- (void)encodePropertiesWithCoder:(NSCoder *)aCoder class:(__unsafe_unretained Class)clz
{
    [self codePropertiesWithEncodeBlock:^(BOOL isCustom, char typeEncoding, NSString *className, NSString *key, id value) {
        if (value) {
            if ([value isKindOfClass:[NSMutableArray class]] || [value isKindOfClass:[NSMutableDictionary class]]) {
                [aCoder encodeObject:[value mutableCopy] forKey:key];
            } else if ([value conformsToProtocol:@protocol(NSCoding)]) {
                [aCoder encodeObject:value forKey:key];
            }
        }
    } decodeBlock:nil class:clz beanType:TNBeanTypeNSCoding];
}

- (void)decodePropertiesWithDecoder:(NSCoder *)aDecoder class:(__unsafe_unretained Class)clz
{
    [self codePropertiesWithEncodeBlock:nil decodeBlock:^id(BOOL isCustom, char typeEncoding, NSString *className, NSString *key) {
        return [aDecoder decodeObjectForKey:key];
    } class:clz beanType:TNBeanTypeNSCoding];
}

- (void)encodePropertiesWithJsonValueContainer:(NSMutableDictionary *)jsonValueContainer class:(__unsafe_unretained Class)clz
{
    [self codePropertiesWithEncodeBlock:^(BOOL isCustom, char typeEncoding, NSString *className, NSString *key, id value) {
        if (value) {
            if ([value isKindOfClass:[NSDate class]]) {
                [jsonValueContainer setObject:[NSNumber numberWithLongLong:[value timeMillisSince1970]] forKey:key];
            } else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                [jsonValueContainer setObject:value forKey:key];
            } else {
                id jsonValue = [TNJsonUtil jsonValueWithObject:value error:nil];
                if (jsonValue) {
                    [jsonValueContainer setObject:jsonValue forKey:key];
                }
            }
        }
    } decodeBlock:nil class:clz beanType:TNBeanTypeJson];
}

- (void)decodePropertiesWithJsonValue:(NSDictionary *)jsonValue class:(__unsafe_unretained Class)clz
{
    id bean = [self conformsToProtocol:@protocol(TNBeanSupport)] ? self : nil;
    [self codePropertiesWithEncodeBlock:nil decodeBlock:^id(BOOL isCustom, char typeEncoding, NSString *className, NSString *key) {
        NSString *upperKey = key.length > 1 ? [NSString stringWithFormat:@"%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]] : [key uppercaseString];
        id obj = [jsonValue objectForKey:upperKey];
        if (obj == nil) {
            obj = [jsonValue objectForKey:key];
        }
        if ([obj isKindOfClass:[NSNull class]]) {
            obj = nil;
        }
        Class tmp = className ? NSClassFromString(className) : NULL;
        if (tmp != NULL && [tmp isSubclassOfClass:[NSDate class]]) {
            long long timestamp = [obj longLongValue];
            return [NSDate dateWithTimeMillisSince1970:timestamp];
        } else if (bean && [bean classForKey:key] != NULL) {
            return [TNJsonUtil objectWithJsonValue:obj withClass:[bean classForKey:key]];
        } else if ([tmp conformsToProtocol:@protocol(TNJsonObject)]) {
            if ([obj isKindOfClass:[NSString class]]) {
                obj = [TNJsonUtil objectWithString:obj error:nil];
            }
            return [TNJsonUtil objectWithJsonValue:obj withClass:tmp];
        } else {
            return obj;
        }
    } class:clz beanType:TNBeanTypeJson];
}

- (void)codePropertiesWithEncodeBlock:(void (^)(BOOL isCustom, char typeEncoding, NSString *className, NSString *key, id value))encodeBlock
                          decodeBlock:(id (^)(BOOL isCustom, char typeEncoding, NSString *className, NSString *key))decodeBlock class:(Class)clz beanType:(TNBeanType)beanType
{
    id bean = [self conformsToProtocol:@protocol(TNBeanSupport)] ? self : nil;
    
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList(clz, &outCount);
    
    if (props == NULL) {
        return;
    }
    
    for (int i = 0; i < outCount; i++) {
        objc_property_t prop = props[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(prop)];
        
        if (bean && [bean isTransientForKey:name beanType:beanType]) {
            continue;
        }
        
        char *chAttrR = property_copyAttributeValue(prop, "R");
        if (chAttrR != NULL) {
            TNFree(chAttrR);
            continue;
        }
        
        char *chAttrT = property_copyAttributeValue(prop, "T");
        char typeEncoding = chAttrT[0];
        if (typeEncoding == _C_CONST) {
            typeEncoding = chAttrT[1];
        }
        NSString *className = nil;
        if (typeEncoding == _C_ID) {
            char *chAttrStrong = property_copyAttributeValue(prop, "&");
            char *chAttrCopy = property_copyAttributeValue(prop, "C");
            if (chAttrStrong == NULL && chAttrCopy == NULL) {
                TNFree(chAttrT);
                TNFree(chAttrStrong);
                TNFree(chAttrCopy);
                continue;
            }
            
            TNFree(chAttrStrong);
            TNFree(chAttrCopy);
            
            className = [NSString stringWithUTF8String:chAttrT];
            NSUInteger index = [className rangeOfString:@"\""].location;
            if (index != NSNotFound) {
                index = index + 1;
                className = [className substringWithRange:NSMakeRange(index, className.length - index - 1)];
            } else {
                className = nil;
            }
        }
        
        if (bean && [bean isCustomForKey:name beanType:beanType]) {
            if (encodeBlock) {
                id obj = [bean valueForKey:name beanType:beanType];
                encodeBlock(YES, typeEncoding, className, name, obj);
            } else if (decodeBlock) {
                id obj = decodeBlock(YES, typeEncoding, className, name);
                [bean setValue:obj forKey:name beanType:beanType];
            }
        } else {
            if (typeEncoding == _C_ID
                || typeEncoding == _C_CLASS
                || typeEncoding == _C_CHR
                || typeEncoding == _C_UCHR
                || typeEncoding == _C_SHT
                || typeEncoding == _C_USHT
                || typeEncoding == _C_INT
                || typeEncoding == _C_UINT
                || typeEncoding == _C_LNG
                || typeEncoding == _C_ULNG
                || typeEncoding == _C_LNG_LNG
                || typeEncoding == _C_ULNG_LNG
                || typeEncoding == _C_FLT
                || typeEncoding == _C_DBL
                || typeEncoding == _C_BOOL) {
                
                if (encodeBlock) {
                    id obj = [self valueForKey:name];
                    encodeBlock(NO, typeEncoding, className, name, obj);
                } else if (decodeBlock) {
                    id obj = decodeBlock(NO, typeEncoding, className, name);
                    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
                        if (typeEncoding == _C_CHR
                            || typeEncoding == _C_UCHR
                            || typeEncoding == _C_SHT
                            || typeEncoding == _C_USHT
                            || typeEncoding == _C_INT
                            || typeEncoding == _C_UINT
                            || typeEncoding == _C_LNG
                            || typeEncoding == _C_ULNG
                            || typeEncoding == _C_LNG_LNG
                            || typeEncoding == _C_ULNG_LNG
                            || typeEncoding == _C_FLT
                            || typeEncoding == _C_DBL
                            || typeEncoding == _C_BOOL) {
                            obj = @0;
                        }
                    }
                    [self setValue:obj forKey:name];
                }
            }
        }
        TNFree(chAttrT);
    }
    TNFree(props);
}

- (void)copyPropertiesTo:(id)object withClass:(Class)clz zone:(NSZone *)zone
{
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList(clz, &outCount);
    if (props == NULL) {
        return;
    }
    
    for (int i = 0; i < outCount; i++) {
        objc_property_t prop = props[i];
        
        char *chAttrR = property_copyAttributeValue(prop, "R");
        if (chAttrR != NULL) {
            TNFree(chAttrR);
            continue;
        }
        
        NSString *key = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [self valueForKey:key];
        [object setValue:value forKey:key];
    }
    TNFree(props);
}

- (void)deepCopyPropertiesTo:(id)object withClass:(Class)clz zone:(NSZone *)zone
{
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList(clz, &outCount);
    if (props == NULL) {
        return;
    }
    
    for (int i = 0; i < outCount; i++) {
        objc_property_t prop = props[i];
        
        char *chAttrR = property_copyAttributeValue(prop, "R");
        if (chAttrR != NULL) {
            TNFree(chAttrR);
            continue;
        }
        
        NSString *key = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [self valueForKey:key];
        
        // copy weak reference.
        char *chAttrT = property_copyAttributeValue(prop, "T");
        char typeEncoding = chAttrT[0];
        if (typeEncoding == _C_CONST) {
            typeEncoding = chAttrT[1];
        }
        if (typeEncoding == _C_ID) {
            char *chAttrStrong = property_copyAttributeValue(prop, "&");
            if (chAttrStrong == NULL) {
                TNFree(chAttrT);
                TNFree(chAttrStrong);
                [object setValue:value forKey:key];
                continue;
            }
            
            TNFree(chAttrT);
            TNFree(chAttrStrong);
        }
        
        // copy strong reference
        if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            [object setValue:[value mutableCopyWithZone:zone] forKey:key];
        } else if ([value conformsToProtocol:@protocol(NSCopying)]) {
            [object setValue:[value copyWithZone:zone] forKey:key];
        }
    }
    TNFree(props);
}

@end