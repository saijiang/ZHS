//
//  NSString+MMExt.h
//  Mikoto
//
//  Created by xxd on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  Add some method for NSString.
//  UPDATE 2015-07-08 :  add md5 string method
//  LAST UPDATE 2015-07-13 :  hex nember value method
//****************************************************************************************
// 

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NSStringCheckPhoneNumberLevelAccurate, // 精确匹配手机号
    NSStringCheckPhoneNumberLevelRough, // 粗匹配手机号，满足 1xxxxxxxxxxxx即可
    NSStringCheckPhoneNumberLevelLandline, //匹配固定电话，
} NSStringCheckPhoneNumberLevel;

@interface NSString (MMExt)
/**
 *  Check self is a validate phone number or not.
 *
 *  @param level check level
 *
 *  @return YES if self is a validate phone number. otherwise retrun NO.
 */
- (BOOL)isValidatePhoneNumberWithLevel:(NSStringCheckPhoneNumberLevel)level;
/**
 *  Get MD5 encode string of self.
 *
 *  @return MD5 string.
 */
- (NSString *)md5String;
/**
 *  Get integer value of hexadecimal number string.
 *
 *  @return integer value.
 */
- (NSInteger)hexIntegerValue;
@end
