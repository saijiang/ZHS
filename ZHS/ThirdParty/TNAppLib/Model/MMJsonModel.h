//
//  MMJsonModel.h
//  Mikoto
//
//  Created by xxd on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
// MMJsonModel protocol. Model with json data required implement these methods.
// LAST UPDATE 2015-07-06： add jsonString methods
//****************************************************************************************
//

#import <Foundation/Foundation.h>

@protocol MMJsonModel <NSObject>

@required
/**
 *  Creat model instance for data. Assign model properties with data value if the property name is same as key of the value in data dictionary.
 *
 *  @param data json data dictionary
 *
 *  @return model instance
 */
+ (instancetype)modelWithJsonDicWithoutMap:(NSDictionary*)data;
/**
 *  Creat model instance for data with self map in +[jsonMap] method. Assign model properties with data value if the property name is same as mapping key in map dictionary.
 *
 *  @param data json data dictionary
 *
 *  @return model instance
 */
+ (instancetype)modelWithJsonDicUseSelfMap:(NSDictionary *)data;
/**
 *  Creat model instance for data with map. Assign model properties with data value if the property name is same as mapping key in map dictionary.
 *
 *  @param data json data dictionary
 *  @param map  map dictionary for key mapping with data, mapping as (properties keyPaths -> Json dictionary keys).
 *
 *  @return model instance
 */
+ (instancetype)modelWithJsonDic:(NSDictionary *)data withMap:(NSDictionary *)map;

/**
 *  Get JSON format string of object for all NONULL propertise.
 *
 *  @return json string
 */
- (NSString *)jsonString;
/**
 *  Get JSON format string for object for all NONULL propertise with map in +[jsonMap] method.
 *
 *  @return json string
 */
- (NSString *)jsonStringWithSelfMap;
/**
 *  Get JSON format string for object for all NONULL propertise with map.
 *
 *  @param map  map dictionary for key mapping with properties, mapping as (properties keyPaths -> Json dictionary keys).
 *
 *  @return json string
 */
- (NSString *)jsonStringWithMap:(NSDictionary *)map;
/**
 *  Get JSON dictionary for all NONULL propertise.
 *
 *  @return json dictionary
 */
- (NSDictionary *)jsonObject;
/**
 *  Get JSON dictionary for all NONULL propertise with map in +[jsonMap] method.
 *
 *  @return json dictionary
 */
- (NSDictionary *)jsonObjectWithSelfMap;
/**
 *  Get JSON dictionary for all NONULL propertise with map.
 *
 *  @param map map dictionary for key mapping with properties, mapping as (properties keyPaths -> Json dictionary keys).
 *
 *  @return json dictionary
 */
- (NSDictionary *)jsonObjectWithMap:(NSDictionary *)map;

/**
 *  mapping between model properties names and json dictionary keys
 *  @return mapping dictionary, mapping as ( properties keyPaths -> Json dictionary keys ). Or nil if no mapping
 */
+ (NSDictionary*)jsonMap;

@end
