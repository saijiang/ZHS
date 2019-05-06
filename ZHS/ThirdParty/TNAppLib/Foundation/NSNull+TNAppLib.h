//
//  NSNull+TNAppLib.h
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSNull (TNAppLib)

- (char)charValue;
- (unsigned char)unsignedCharValue;
- (short)shortValue;
- (unsigned short)unsignedShortValue;
- (int)intValue;
- (unsigned int)unsignedIntValue;
- (long)longValue;
- (unsigned long)unsignedLongValue;
- (long long)longLongValue;
- (unsigned long long)unsignedLongLongValue;
- (float)floatValue;
- (double)doubleValue;
- (BOOL)boolValue;
- (NSInteger)integerValue;
- (NSUInteger)unsignedIntegerValue;

- (NSString *)stringValue;

- (void *)pointerValue;
- (NSRange)rangeValue;

// UIGeometry
- (CGPoint)CGPointValue;
- (CGSize)CGSizeValue;
- (CGRect)CGRectValue;
- (CGAffineTransform)CGAffineTransformValue;
- (UIEdgeInsets)UIEdgeInsetsValue;
- (UIOffset)UIOffsetValue NS_AVAILABLE_IOS(5_0);

- (NSComparisonResult)compare:(id)otherObject;

- (BOOL)isEqualToNumber:(id)otherObject;
- (BOOL)isEqualToString:(id)otherObject;

- (NSUInteger)count;
- (NSUInteger)length;

@end
