//
//  MMAutoCodingModel.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//   MMAutoCodingModel protocol. Model of AutoCoding required implement these methods.
//****************************************************************************************
//

#import <Foundation/Foundation.h>

@protocol MMAutoCodingModel <NSSecureCoding>
@required
/**
 *  Set uncode properties for NSCoder.
 *
 *  @return Array for current class uncode properties.
 */
+ (NSArray *)uncodeKeys;
/**
 *  Creat model instance with coded file.
 *
 *  @param filePath The location to which to write the receiver's bytes. If path contains a tilde (~) character, you must expand it with stringByExpandingTildeInPath before invoking this method.
 *
 *  @return decoded model instance
 */
+ (instancetype)modelAutoDecodeWithFile:(NSString *)filePath;
/**
 *  Coding model and write it to file.
 *
 *  @param filePath         The location to which to write the receiver's bytes. If path contains a tilde (~) character, you must expand it with stringByExpandingTildeInPath before invoking this method.
 *  @param useAuxiliaryFile If YES, the model is written to a backup file, and then—assuming no errors occur—the backup file is renamed to the name specified by path; otherwise, the data is written directly to path.
 *
 *  @return YES if the operation succeeds, otherwise NO.
 */
- (BOOL)writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile;
/**
 *  Check a property is codable or not.
 *
 *  @param key property name
 *
 *  @return YES if the property will be coded into NSCoder or File, otherwise NO.
 */
- (BOOL)isCodablePropertyForKey:(NSString *)key;
@end
