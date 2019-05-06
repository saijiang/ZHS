//
//  TNJsonUtil.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNJsonObject.h"

enum {
    TNJsonErrorInputNull = 2000,   //!< The inputted data is nil or length zero.
    TNJsonErrorUnsupportedClass,    //!< The inputted object is not JSON object.
};

/*!
 *  You use the TNJsonUtil class to convert JSON data/string to Foundation or TNJsonObject objects and convert JSON objects to JSON data/string.
 */
@interface TNJsonUtil : NSObject

/*! 
 *  Returns a Foundation object from given JSON data.
 *
 *  @discussion The data must be in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE. The data may or may not have a BOM. The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
 *
 *  @param jsonData A data object containing JSON data.
 *  @param error Output. If an error occurs, upon return contains an NSError object that describes the problem.
 *  @return A Foundation object from the JSON data in data, or nil if an error occurs.
 */
+ (id)objectWithData:(NSData *)jsonData error:(NSError **)error;

/*!
 *  Returns a Foundation object from given JSON string.
 *
 *  @param jsonString A string containing JSON data.
 *  @param error Output. If an error occurs, upon return contains an NSError object that describes the problem.
 *  @return A Foundation object from the JSON data in string, or nil if an error occurs.
 */
+ (id)objectWithString:(NSString *)jsonString error:(NSError **)error;

/*!
 *  Returns a TNJsonObject object from given JSON data and given Class.
 *
 *  @param jsonData A data object containing JSON data.
 *  @param objectClass The Class to parse.
 *  @param error Output. If an error occurs, upon return contains an NSError object that describes the problem.
 *  @return A TNJsonObject object from the JSON data in data, or nil if an error occurs.
 *
 *  @see objectWithData:error:
 */
+ (id)objectWithData:(NSData *)jsonData class:(Class)objectClass error:(NSError **)error;

/*!
 *  Returns a TNJsonObject object from given JSON string and given Class.
 *
 *  @param jsonData A string containing JSON data.
 *  @param objectClass The Class to parse.
 *  @param error Output. If an error occurs, upon return contains an NSError object that describes the problem.
 *  @return A TNJsonObject object from the JSON data in string, or nil if an error occurs.
 *
 *  @see objectWithString:error:
 */
+ (id)objectWithString:(NSString *)jsonString class:(Class)objectClass error:(NSError **)error;

/*!
 *  Parse a json object to NSData, using NSUTF8StringEncoding. If object is a container of TNJSONObject objects, will not parse deep-recursively.
 *  
 *  @param object The JSON object.
 *  @param isPrettyPrinted Specifies that the JSON data should be generated with whitespace designed to make the output more readable. If this option is not set, the most compact possible JSON representation is generated.
 *  @param error Output. If an error occurs, upon return contains an NSError object that describes the problem.
 *  @return A data parsed from The JSON object, or nil if an error occurs.
 */
+ (NSData *)dataWithObject:(id)object prettyPrinted:(BOOL)isPrettyPrinted error:(NSError **)error;

/*!
 *  Parse a json object to NSString, using NSUTF8StringEncoding. If object is a container of TNJSONObject objects, will not parse deep-recursively.
 *
 *  @param object The JSON object.
 *  @param isPrettyPrinted Specifies that the JSON data should be generated with whitespace designed to make the output more readable. If this option is not set, the most compact possible JSON representation is generated.
 *  @param error If an error occurs, upon return contains an NSError object that describes the problem.
 *  @return A string parsed from The JSON object, or nil if an error occurs.
 */
+ (NSString *)stringWithObject:(id)object;

/*!
 *  Parse a json object to NSString, using NSUTF8StringEncoding. If object is a container of TNJSONObject objects, will not parse deep-recursively.
 *
 *  @param object The JSON object.
 *  @param isPrettyPrinted Specifies that the JSON data should be generated with whitespace designed to make the output more readable. If this option is not set, the most compact possible JSON representation is generated.
 *  @param error If an error occurs, upon return contains an NSError object that describes the problem.
 *  @return A string parsed from The JSON object, or nil if an error occurs.
 */
+ (NSString *)stringWithObject:(id)object prettyPrinted:(BOOL)isPrettyPrinted error:(NSError **)error;

/*!
 *  Parse a NSArray or NSDictionary to a object.
 *
 *  @param jsonValue The Foundation object.
 *  @param objectClass The Class to generate for.
 *  @return A TNJsonObject or its container, or nil if an error occurs.
 */
+ (id)objectWithJsonValue:(id)jsonValue withClass:(Class)objectClass;

/*!
 *  Parse a NSArray or NSDictionary of TNJsonObject objects to a json value.
 *
 *  @param object The TNJsonObject object.
 *  @param error Output. If an error occurs, upon return contains an NSError object that describes the problem.
 *  @return A Foundation object, or nil if an error occurs.
 */
+ (id)jsonValueWithObject:(id)object error:(NSError **)error;

+ (id)copyJsonObject:(id)jsonObject;

@end
