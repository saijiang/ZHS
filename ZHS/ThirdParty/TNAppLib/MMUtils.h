//
//  MMUtils.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  MMUtils.  Some util factory method in it
//****************************************************************************************
//


#import <UIKit/UIKit.h>
/**
 *  Get absolute value of the distance between two point
 *
 *  @param fromPoint a point
 *  @param toPoint   another point
 *
 *  @return absolute value of the distance
 */
CGFloat CGPointGetDistanceToPoint(CGPoint fromPoint, CGPoint toPoint);
/**
 *  Creat a new point with subtract a point from another point
 *
 *  @param original   minuend point
 *  @param subtrahend subtrahend point
 *
 *  @return a new point get from minuend subtract subtrahend
 */
CGPoint CGPointMakeWithSubPoint(CGPoint minuend, CGPoint subtrahend);
/**
 *  Creat a new point with a point add another point
 *
 *  @param original a point
 *  @param delta    another point
 *
 *  @return a new point with a point add another point
 */
CGPoint CGPointMakeWithAddPoint(CGPoint original, CGPoint delta);
/**
 *  Creat a new point with a point scale multiplier
 *
 *  @param original a point
 *  @param scale    multiplier
 *
 *  @return a new point
 */
CGPoint CGPointMakeByScale(CGPoint original, CGFloat scale);

/**
 *  Creat a new size  with a size scale multiplier
 *
 *  @param original a size
 *  @param scale    multiplier
 *
 *  @return a new size
 */
CGSize  CGSizeMakeByScale(CGSize original, CGFloat scale);
/**
 *  The ratio between the area of a size and it of another size
 *
 *  @param origin    a size
 *  @param scaleSize another size
 *
 *  @return the ratio
 */
CGFloat CGSizeGetScaleFromSzie(CGSize origin, CGSize scaleSize);

/**
 *  Get the center of a rect
 *
 *  @param rect a rect
 *
 *  @return the center of a rect
 */
CGPoint CGRectGetCenter(CGRect rect);
/**
 *  Creat a new rect with a rect scale multiplier
 *
 *  @param original  a rect
 *  @param scale multiplier
 *
 *  @return a new rect
 */
CGRect  CGRectMakeByScale(CGRect original, CGFloat scale);
/**
 *  Crest a new rect from a rect move to a new center
 *
 *  @param rect  a rect
 *  @param delta the center of new rect
 *
 *  @return a new rect
 */
CGRect  CGRectMakeByMoveToCenter(CGRect rect, CGPoint center);
/**
 *  Crest a new rect from a rect move  by vector
 *
 *  @param rect  a rect
 *  @param delta vector
 *
 *  @return a new rect
 */
CGRect  CGRectMakeByMoveByPoint(CGRect rect, CGPoint delta);
/**
 *  Creat a new rect with a origin and a size
 *
 *  @param origin rect origin
 *  @param size   rect size
 *
 *  @return a new rect
 */
CGRect  CGRectMakeWithOriginAndSize(CGPoint origin, CGSize size);
/**
 *  Creat a new rect with a center and a size
 *
 *  @param center rect center
 *  @param size   rect size
 *
 *  @return a new rect
 */
CGRect CGRectMakeWithCenterAndSize(CGPoint center, CGSize size);
/**
 *  Creat a new rect with a margin from a rect
 *
 *  @param rect   original rect
 *  @param margin margin
 *
 *  @return a new rect
 */
CGRect  CGRectMakeWithMargin(CGRect rect, CGFloat margin);
/**
 *  Creat a new rect with edge inset from a rect
 *
 *  @param rect original rect
 *  @param edge edge inset
 *
 *  @return a new rect
 */
CGRect  CGRectMakeWithEdgeInset(CGRect rect, UIEdgeInsets edge);


@interface MMUtils : NSObject
#pragma mark - Model methods
#pragma mark creat
/**
 *  Creat object for class with json dictionary.
 *
 *  @param json        json dictionary
 *  @param targetClass object class
 *
 *  @return object with assigned  by json dictionary
 */
+ (id)creatObjectWithJsonDic:(NSDictionary*)json forClass:(Class)targetClass;
/**
 *  copy model with all properties
 *
 *  @param model old model instance
 *
 *  @return new model instance with same properties
 */
+ (id)copyModel:(id)model;
/**
 *  Creat new class model with data of old model. In this method, new model properties will be assigned with old model properties if there name are same.
 *
 *  @param oldModel       old model
 *  @param targetClass new model class
 *
 *  @return new model with data of old model
 */
+ (id)transformModel:(id)oldModel toClass:(Class)targetClass;
/**
 *  Creat new class model with data of old model. In this method, new model properties will be assigned with old model properties if there name are mapping with map dictionary
 *
 *  @param oldModel       old model
 *  @param targetClass new model class
 *  @param map         map dictionary , {"old model property name" : "new model property name"}
 *
 *  @return new model with data of old model
 */
+ (id)transformModel:(id)oldModel toClass:(Class)targetClass withMap:(NSDictionary *)map;

#pragma mark utils
/**
 *  get class of a property of a class
 *
 *  @param targetClass property owner class
 *  @param aProperty   property name
 *
 *  @return class of the property
 */
+ (Class)getPropertyClassOfClass:(Class)targetClass withPropertyKey:(NSString *)aProperty;

#pragma mark set properties
/**
 *  init all property and subproperty
 *
 *  @param object object to init
 */
+ (void)initPropertiesForObject:(id)object;
/**
 *  set properties for object from a dictionary
 *
 *  @param data   data dictionary
 *  @param object target object
 */
+ (void)setValuesWithDictionary:(NSDictionary *)data forObject:(id)object;
/**
 * set properties for object from a dictionary with a Mapping
 *
 * @param data  data dictionary
 * @param object target object
 * @param map   map of data dictionary's keys to object's properties
 */
+ (void)setValuesWithDictionary:(NSDictionary *)data forObject:(id)object withMap:(NSDictionary *)map;

#pragma mark - ViewController methods
/**
 *  get current top view controller of current window
 *
 *  @return current top view controller
 */
+ (UIViewController *)getCurrentTopViewController;

@end
