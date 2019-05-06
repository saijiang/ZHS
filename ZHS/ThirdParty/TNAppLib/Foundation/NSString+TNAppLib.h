//
//  NSString+TNAppLib.h
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSGB2312StringEncoding (CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000))

@interface NSString (TNAppLib)

#pragma mark - URL Coding
- (NSString *)stringByURLEncoding;
- (NSString *)stringByURLDecoding;

#pragma mark - MD5 Encode
- (NSString *)stringByMD5Encoding;

#pragma mark - PinYin
- (NSString *)pinyin;
- (NSString *)pinyinFirstLetters:(BOOL)isAll;
- (BOOL)isPinyinMatch:(NSString *)aString;

#pragma mark - Utils
- (NSString *)stringByRemovingBlankCharacters;

+ (NSString *)UUIDString;

- (BOOL)containsEmoji;
- (NSString *)stringByTrimmingToLength:(NSUInteger)length usingEncoding:(NSStringEncoding)encoding;

+ (NSString *)hexStringWithData:(NSData *)data;

@end
