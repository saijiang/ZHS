//
//  NSArray+MMExt.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
// Add some methods for NSArray.
// LAST UPDATE 2015-06-03 add format log description
//****************************************************************************************
//

#import <Foundation/Foundation.h>

@interface NSArray (MMExt)
/**
 *  Check there is some object in array is kind of class or not.
 *
 *  @param aClass check class
 *
 *  @return YES if find, otherwise NO.
 */
- (BOOL)containsObjectClass:(Class)aClass;
/**
 *  creat a new array with every object trasform in block
 *
 *  @param block object transformer, do something in block with each object and retrun a new object for array
 *
 *  @return a new array with every object transformed
 */
- (NSArray *)arrayTransformObjectWithBlock:(id (^)(id obj, NSInteger index, BOOL *stop))block;
/**
 *  creat a new array with objects in array satisfied the condition
 *
 *  @param block condition block, return YES if the obj satisfy the condition, otherwise return NO
 *
 *  @return a new array with objects satisfied the condition
 */
- (NSArray *)arrayWithConditionBlock:(BOOL (^)(id obj, NSInteger index, BOOL *stop))block;
/**
 *  creat a new array with all value of self except the value is NSNull class
 *
 *  @return a new array without NSNull value
 */
- (NSArray *)arrayWithCleanNSNullValue;
@end
