//
//  TNBeanSupport.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 *  Check for serialization strategies
 */
typedef NS_OPTIONS(NSUInteger, TNBeanType) {
    TNBeanTypeJson = 1UL << 0,      //!< Bean conformed protocol TNJsonObject.
    TNBeanTypeNSCoding = 1UL << 1,  //!< Bean conformed protocol NSCoding.
    TNBeanTypeXML = 1UL << 2,  //!< Bean is from xml.
};

/*! The TNBeanSupport protocol groups methods that are extensional to beans. */
@protocol TNBeanSupport <NSObject>

@required
/*!
 *  Returns the Class for the property identified by a given key or its item. Default NULL.
 *
 *  @param key The name of one of the receiver's properties.
 *  @return The Class for the property identified by a given key or its item.
 */
- (Class)classForKey:(NSString *)key;

/*!
 *  Test weather the specified property is skipped in serialization. Default NO.
 *
 *  @param key The name of one of the receiver's properties.
 *  @param beanType The type in current test.
 *  @return Should skip the property identified by key in test type beanType.
 */
- (BOOL)isTransientForKey:(NSString *)key beanType:(TNBeanType)beanType;

/*!
 *  Test weather the property has different value from default getter/setter. Default NO.
 *  If return YES, must implement valueForKey:beanType: and setValue:forKey:beanType:
 *
 *  @param key The name of one of the receiver's properties.
 *  @param beanType The type in current test.
 *  @return Should customize getter or setter for key.
 */
- (BOOL)isCustomForKey:(NSString *)key beanType:(TNBeanType)beanType;

@optional
/*!
 *  Returns the value for the property identified by a given key and a given beanType. Default nil.
 *
 *  @param key The name of one of the receiver's properties.
 *  @param beanType The type in current test.
 *  @return The value for the property identified by a given key and a given beanType.
 */
- (id)valueForKey:(NSString *)key beanType:(TNBeanType)beanType;

/*!
 *  Set the value for the property identified by a given key and a given beanType. Default nil.
 *
 *  @param value The value for the property identified by key.
 *  @param key The name of one of the receiver's properties.
 *  @param beanType The type in current test.
 */
- (void)setValue:(id)value forKey:(NSString *)key beanType:(TNBeanType)beanType;

@end
