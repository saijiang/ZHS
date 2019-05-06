//
//  TNDataUtil.h
//  TNAppLib
//
//  Created by Frank on 13-11-25.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNDataUtil : NSObject

+ (BOOL)isValidEmail:(NSString*)inputString;
+ (BOOL)isValidPhone:(NSString*)phone;
+ (BOOL)isValidPassword:(NSString*)password;

+ (int)getUnifyNickLength:(NSString*)inputString;
+ (NSString *)generateUnifyFileName:(NSString*) extension;

+ (NSString*)timeTillNow:(NSDate*)date;
+ (NSString*)timeTillNow:(NSDate*)date isShortFormat:(BOOL)isShortFormat;

+ (long long)currentTimeMillis;
+(NSDate *) dateFromString:(NSString*) dateString;
+(NSString *) dateToString:(NSDate*) date format:(NSString*) format;
+(NSString *) dateToString:(NSDate*) date;
+(long long) dateToTimeStampSeconds:(NSDate*) date;
+(NSDate *) dateFromTimeStamp:(long long) secondsSince1970;
+(NSString *) formatBizHourString:(NSString*) bizHour;

+ (BOOL)isEqualWithNumber:(NSNumber *)number1 number:(NSNumber *)number2;

+ (NSString*)formatPhoneNumber:(NSString*)phoneNum;

+ (NSNumber *)stringToNumber:(NSString *)str;

+ (NSString*)intToChinese:(NSUInteger)num;

@end
