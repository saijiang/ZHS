//
//  MMBaseModel.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  MMBaseModel. Base model, definition some base methods and regulations.
//  MMBaseModel implement json decode and NSCoder autoCoing, subclass just need defintion it onw properties and implement +[uncodeKeys] and +[jsonMap] methods for some necessary information
// UPDATE 2015-06-03 add format log description
// LAST UPDATE 2015-07-06 add jsonString methods
//****************************************************************************************
//


#import <Foundation/Foundation.h>
#import "MMJsonModel.h"
#import "MMAutoCodingModel.h"

@interface MMBaseModel : NSObject<MMJsonModel, MMAutoCodingModel>
/**
 *  Creat a new model with all properties is nil.
 *
 *  @return New model instance.
 */
+ (instancetype)emptyModel;
/**
 *  Creat a new model with all properties initialized.
 *
 *  @return New model instance.
 */
+ (instancetype)initializedModel;

/**
 *  Add some properties in array of another model instance to self.
 *
 *  @param add        another model instance
 *  @param properties an array of property names that decide which property to assign
 */
- (void)addPropertiesWithModel:(id)add withProperiesList:(NSArray *)properties;
/**
 *  Add some properties in map of another model instance to self.
 *
 *  @param add another model instance
 *  @param map a map of property names mapping that decide which property to assign, mapping as (add property name -> self property name)
 */
- (void)addPropertiesWithModel:(id)add withProperiesMapping:(NSDictionary *)map;
@end
