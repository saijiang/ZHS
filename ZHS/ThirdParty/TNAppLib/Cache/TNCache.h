//
//  TNCache.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    TNCacheErrorKeyNull = 4000,   //!< The inputted cache key is nil.
    TNCacheErrorFileNotFound,   //!< Can't find file that stores data.
    TNCacheErrorDataTypeNotMatch,   //!< The value not match the required type.
};

typedef NS_ENUM(NSInteger, TNCacheDataType) {
    TNCacheDataTypeNSCoding = 1,
    TNCacheDataTypeJSON = 2,
    TNCacheDataTypeBinary = 3,
    TNCacheDataTypeString = 4
};

enum {
    TNCacheDomainDefault = 0,
};
typedef NSInteger TNCacheDomain;

extern NSString * const TNCacheURLKey;   // a NSURL.
extern NSString * const TNCacheModificationTimeKey;  // a NSDate.
extern NSString * const TNCacheCreationTimeKey;  // a NSDate.

extern NSString * const TNCacheErrorDomain;

@interface TNCache : NSObject

@property (nonatomic, readonly) NSUInteger memoryCapacity;
@property (nonatomic, readonly) NSUInteger diskCapacity;
@property (nonatomic, readonly, strong) NSString *diskPath;

/*!
 *  @return The singleton.
 */
+ (TNCache *)sharedCache;

/*!
 *  Store a NSString object. This method stores string to database directly, not in a separate file.
 *  @param obj The object for storing.
 *  @param key The key for object.
 *  @param completion Always call completion block in main queue.
 */
- (void)storeString:(NSString *)string forKey:(NSString *)key completion:(void (^)(BOOL success, NSError *error))completion;

/*!
 *  Store a id<NSCoding> object.
 *  @param obj The object for storing.
 *  @param key The key for object.
 *  @param completion Always call completion block in main queue.
 */
- (void)storeNSCodingObject:(id)obj forKey:(NSString *)key completion:(void (^)(BOOL success, NSError *error))completion;

/*!
 *  Store a or an Array of id<TTXJsonObject> object.
 *  @param obj The object for storing.
 *  @param key The key for object.
 *  @param cls Class of object or object's item.
 *  @param completion Always call completion block in main queue.
 */
- (void)storeJsonObject:(id)obj forKey:(NSString *)key class:(Class)cls completion:(void (^)(BOOL success, NSError *error))completion;

/*!
 *  Store a NSData object.
 *  @param obj The object for storing.
 *  @param key The key for object.
 *  @param completion Always call completion block in main queue.
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key completion:(void (^)(BOOL success, NSError *error))completion;

/*!
 *  Get a cached object synchronously.
 *  @param key The key for object.
 */
- (id)cachedObjectForKey:(NSString *)key;

/*!
 *  Get a cached object asynchronously.
 *  @param key The key for object.
 *  @param completion Always call completion block in main queue.
 */
- (void)cachedObjectForKey:(NSString *)key completion:(void (^)(id cachedObj, NSError *error))completion;

/*!
 *  Get multi cached objects asynchronously.
 *  @param keys The keys to load.
 *  @param completion Always call completion block in main queue.
 */
- (void)cachedObjectsForKeys:(NSArray *)keys completion:(void (^)(NSDictionary *, NSError *))completion;

/*!
 *  Remove a cached object asynchronously.
 *  @param key The key for object.
 */
- (void)removeCachedObjectForKey:(NSString *)key completion:(void (^)(BOOL success, NSError *error))completion;

/*!
 *  Get a cached object info synchronously.
 *  @param key The key for object.
 */
- (NSDictionary *)cachedObjectInfoForKey:(NSString *)key;

- (void)clearMemory;

- (void)clearDisk;

#pragma mark - Extension for domain
/*!
 *  Store a object asynchronously.
 *  @param obj The object for storing.
 *  @param key The key for storing.
 *  @param domain The domain for storing.
 *  @param type The type of the storing object.
 *  @param cls Class of object or object's item. If not a container of json objects, it can be NULL.
 *  @param completion Always call completion block in main queue.
 */
- (void)storeObject:(id)obj forKey:(NSString *)key domain:(TNCacheDomain)domain type:(TNCacheDataType)type class:(Class)cls completion:(void (^)(BOOL success, NSError *error))completion;

- (NSDictionary *)cachedObjectInfoForKey:(NSString *)key domain:(TNCacheDomain)domain;

- (id)cachedObjectForKey:(NSString *)key domain:(TNCacheDomain)domain;

- (void)cachedObjectForKey:(NSString *)key domain:(TNCacheDomain)domain completion:(void (^)(id cachedObj, NSError *error))completion;

- (void)cachedObjectsForKeys:(NSArray *)keys domain:(TNCacheDomain)domain completion:(void (^)(NSDictionary *cachedObjects, NSError *error))completion;

- (void)removeCachedObjectForKey:(NSString *)key domain:(TNCacheDomain)domain completion:(void (^)(BOOL success, NSError *error))completion;

- (void)removeCachedObjectsWithoutKeys:(NSArray *)remainedKeys domain:(TNCacheDomain)domain completion:(void (^)(BOOL success, NSArray *failedKeys, NSError *error))completion;

- (void)removeCachedObjectsWithKeys:(NSArray *)removedKeys domain:(TNCacheDomain)domain completion:(void (^)(BOOL success, NSArray *failedKeys, NSError *error))completion;

@end
