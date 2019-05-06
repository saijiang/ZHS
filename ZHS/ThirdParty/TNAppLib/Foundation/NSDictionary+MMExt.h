//
//  NSDictionary+MMExt.h
//  Mikoto
//
//  Created by xxd on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  Add some methods for NSDictionary.
// LAST UPDATE 2015-06-03 add format log description
//****************************************************************************************
//

#import <Foundation/Foundation.h>

@interface NSDictionary (MMExt)
/**
 *  mapping keys of this dictionary. such as:  self(key -> value) with map(mapkey -> key)  -> return dic(mapkey -> value)
 *
 *  @param map mapping dictionary
 *
 *  @return new dictionary with all keys mapped for map, or new dictionary with self if map dictionary is nil.
 */
- (NSDictionary *)dictionaryWithMapKeysWithMap:(NSDictionary *)map;

/**
 *  mapping two dictionaries keys for same value. such as: self(key -> value) with aDic(otherKey -> value) -> return dic(key -> otherKey)
 *
 *  @param aDic another dictionary for map with self
 *
 *  @return new dictionary with keys mapping. or empty dictionary if aDic is nil.
 */
- (NSDictionary *)dictionaryWithMapKeysWithSameValue:(NSDictionary *)aDic;
/**
 *  creat a new dictionary with all value of self except the value is NSNull class
 *
 *  @return a new dictionary without NSNull value
 */
- (NSDictionary *)dictionaryWithCleanNSNullValue;
@end
