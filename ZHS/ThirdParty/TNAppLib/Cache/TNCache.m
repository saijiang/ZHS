//
//  TNCache.m
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNCache.h"
#import "TNCacheEntity.h"
#import "TNJsonUtil.h"
#import "TNDatabase.h"

#define CACHE_LOG_ENABLED   1

#define kTNCacheMemoryMaxSize (20 * 1024 * 1024)
#define kTNCacheDiskMaxSize (200 * 1024 * 1024)
#define kTNCacheDiskPath   @"TNCache"

#define FetchByKeyTemplateName @"FetchCacheByKeyRequest"
#define FetchByKeysTemplateName @"FetchCacheByKeysRequest"
#define TNCacheEntityName @"TNCacheEntity"

NSString * const TNCacheErrorDomain = @"TNCacheErrorDomain";

NSString * const TNCacheURLKey = @"TNCacheURLKey";   // a NSURL.
NSString * const TNCacheModificationTimeKey = @"TNCacheModificationTimeKey";  // a NSDate.
NSString * const TNCacheCreationTimeKey = @"TNCacheCreationTimeKey";  // a NSDate.

@interface TNCache ()

@property (nonatomic) NSUInteger memoryCapacity;
@property (nonatomic) NSUInteger diskCapacity;
@property (nonatomic, strong) NSString *diskPath;
@property (nonatomic, strong) NSURL *cacheDirectory;
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, strong) TNDatabase *db;

@end

@implementation TNCache

+ (TNCache *)sharedCache
{
    static TNCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithMemoryCapacity:kTNCacheMemoryMaxSize diskCapacity:kTNCacheDiskMaxSize diskPath:kTNCacheDiskPath];
    });
    return instance;
}

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path
{
    if (self = [super init]) {
        self.memoryCapacity = memoryCapacity;
        self.diskCapacity = diskCapacity;
        self.diskPath = path;
        
        self.cacheDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:path isDirectory:YES];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;
        if (![fm fileExistsAtPath:self.cacheDirectory.path isDirectory:&isDir] || !isDir) {
            [fm createDirectoryAtURL:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        self.memoryCache = [[NSCache alloc] init];
        self.memoryCache.name = @"TNCache";
        
        NSURL *url = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"TNCache.sqlite"];
        self.db = [[TNDatabase alloc] initWithModelName:@"TNCache" options:@{TNDatabaseStoreURLOption: url, TNDatabaseOnlyUsedInMainThreadOption: @YES}];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning:(NSNotification *)noti
{
    [self.memoryCache removeAllObjects];
}

- (void)storeString:(NSString *)string forKey:(NSString *)key completion:(void (^)(BOOL, NSError *))completion
{
    if (string == nil) {
        [self removeCachedObjectForKey:key completion:completion];
    } else {
        [self storeWithBlock:nil data:string dataType:TNCacheDataTypeString class:NULL forKey:key completion:completion];
    }
}

- (void)storeNSCodingObject:(id)obj forKey:(NSString *)key completion:(void (^)(BOOL, NSError *))completion
{
    [self storeNSCodingObject:obj forKey:key checkMutable:YES completion:completion];
}

- (void)storeNSCodingObject:(id)obj forKey:(NSString *)key checkMutable:(BOOL)isCheckMutable completion:(void (^)(BOOL, NSError *))completion
{
    if (obj == nil) {
        [self removeCachedObjectForKey:key completion:completion];
        return;
    }
    
    if (isCheckMutable) {
        if ([obj isKindOfClass:[NSMutableArray class]] || [obj isKindOfClass:[NSMutableDictionary class]] || [obj isKindOfClass:[NSMutableSet class]]) {
            id temp = [obj mutableCopy];
            [self storeNSCodingObject:temp forKey:key checkMutable:NO completion:completion];
            return;
        }
    }
    
    [self storeWithBlock:^BOOL(NSURL *fileURL, NSError *__autoreleasing *error) {
        id wrappedObj = [obj conformsToProtocol:@protocol(NSMutableCopying)] ? [obj mutableCopy] : obj;
        NSData *archivedData = wrappedObj ? [NSKeyedArchiver archivedDataWithRootObject:wrappedObj] : [NSData data];
        if (archivedData && [archivedData writeToURL:fileURL options:NSDataWritingAtomic error:error]) {
            return YES;
        }
        return NO;
    } data:nil dataType:TNCacheDataTypeNSCoding class:NULL forKey:key completion:completion];
}

- (void)storeJsonObject:(id)obj forKey:(NSString *)key class:(Class)cls completion:(void (^)(BOOL, NSError *))completion
{
    [self storeJsonObject:obj forKey:key class:cls checkMutable:YES completion:completion];
}

- (void)storeJsonObject:(id)obj forKey:(NSString *)key class:(Class)cls checkMutable:(BOOL)isCheckMutable completion:(void (^)(BOOL, NSError *))completion
{
    if (obj == nil) {
        [self removeCachedObjectForKey:key completion:completion];
        return;
    }
    
    if (isCheckMutable) {
        if ([obj isKindOfClass:[NSMutableArray class]] || [obj isKindOfClass:[NSMutableDictionary class]] || [obj isKindOfClass:[NSMutableSet class]]) {
            id temp = [obj mutableCopy];
            [self storeJsonObject:temp forKey:key class:cls checkMutable:NO completion:completion];
            return;
        }
    }
    
    [self storeWithBlock:^BOOL(NSURL *fileURL, NSError *__autoreleasing *error) {
        id wrappedObj = [obj conformsToProtocol:@protocol(NSMutableCopying)] ? [obj mutableCopy] : obj;
        NSData *archivedData = wrappedObj ? [TNJsonUtil dataWithObject:wrappedObj prettyPrinted:NO error:error] : [NSData data];
        if (archivedData && [archivedData writeToURL:fileURL options:NSDataWritingAtomic error:error]) {
            return YES;
        }
        return NO;
    } data:nil dataType:TNCacheDataTypeJSON class:cls == NULL ? [obj class] : cls forKey:key completion:completion];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key completion:(void (^)(BOOL, NSError *))completion
{
    if (data == nil) {
        [self removeCachedObjectForKey:key completion:completion];
        return;
    }
    
    [self storeWithBlock:^BOOL(NSURL *fileURL, NSError *__autoreleasing *error) {
        return [data ? data : [NSData data] writeToURL:fileURL options:NSDataWritingAtomic error:error];
    } data:nil dataType:TNCacheDataTypeBinary class:NULL forKey:key completion:completion];
}

- (void)storeObject:(id)obj forKey:(NSString *)key domain:(TNCacheDomain)domain type:(TNCacheDataType)type class:(Class)cls completion:(void (^)(BOOL, NSError *))completion
{
    if (obj == nil) {
        [self removeCachedObjectForKey:key domain:domain completion:completion];
    }
    
    BOOL (^action)(NSURL *fileURL, NSError **error) = nil;
    switch (type) {
        case TNCacheDataTypeNSCoding:
        {
            action = ^BOOL(NSURL *fileURL, NSError **error) {
                id wrappedObj = [obj conformsToProtocol:@protocol(NSMutableCopying)] ? [obj mutableCopy] : obj;
                NSData *archivedData = wrappedObj ? [NSKeyedArchiver archivedDataWithRootObject:wrappedObj] : [NSData data];
                if (archivedData && [archivedData writeToURL:fileURL options:NSDataWritingAtomic error:error]) {
                    return YES;
                }
                return NO;
            };
            break;
        }
        case TNCacheDataTypeJSON:
        {
            action = ^BOOL(NSURL *fileURL, NSError **error) {
                id wrappedObj = [obj conformsToProtocol:@protocol(NSMutableCopying)] ? [obj mutableCopy] : obj;
                NSData *archivedData = wrappedObj ? [TNJsonUtil dataWithObject:wrappedObj prettyPrinted:NO error:error] : [NSData data];
                if (archivedData && [archivedData writeToURL:fileURL options:NSDataWritingAtomic error:error]) {
                    return YES;
                }
                return NO;
            };
            cls = cls == NULL ? [obj class] : cls;
            break;
        }
        case TNCacheDataTypeBinary:
        {
            action = ^BOOL(NSURL *fileURL, NSError **error) {
                if ([obj isKindOfClass:[NSData class]]) {
                    return [obj ? obj : [NSData data] writeToURL:fileURL options:NSDataWritingAtomic error:error];
                }
                if (error) {
                    *error = [NSError errorWithDomain:TNCacheErrorDomain code:TNCacheErrorDataTypeNotMatch userInfo:nil];
                }
                return NO;
            };
            break;
        }
        default:
            break;
    }
    
    [self storeWithBlock:action data:type == TNCacheDataTypeString ? obj : nil dataType:type class:cls forKey:key domain:domain completion:completion];
}

- (void)storeWithBlock:(BOOL (^)(NSURL *fileURL, NSError **error))block data:(NSString *)data dataType:(TNCacheDataType)dataType class:(Class)cls forKey:(NSString *)key
            completion:(void (^)(BOOL, NSError *))completion
{
    [self storeWithBlock:block data:data dataType:dataType class:cls forKey:key domain:0 completion:completion];
}

- (void)storeWithBlock:(BOOL (^)(NSURL *fileURL, NSError **error))block data:(NSString *)data dataType:(TNCacheDataType)dataType class:(Class)cls forKey:(NSString *)key domain:(NSInteger)domain
            completion:(void (^)(BOOL, NSError *))completion
{
    void (^wrappedHandler)(BOOL success, NSError *error) = ^(BOOL success, NSError *error){
        if (completion) {
            if ([NSThread isMainThread]) {
                completion(success, error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success, error);
                });
            }
        }
    };
    
    if (key.length == 0) {
        wrappedHandler(NO, [NSError errorWithDomain:TNCacheErrorDomain code:TNCacheErrorKeyNull userInfo:nil]);
        return;
    }
    
    [self.db fetchFromTemplateWithName:FetchByKeyTemplateName substitutionVariables:@{@"KEY": key, @"DOMAIN": @(domain)} completion:^(NSArray *result, NSError *e1) {
        TNCacheEntity *entity = [result lastObject];
        if (!entity) {
            entity = [self.db insertObjectWithEntityName:TNCacheEntityName];
            entity.key = key;
            entity.domain = [NSNumber numberWithInteger:domain];
        }
        
        if (dataType == TNCacheDataTypeString) {
            if (entity.dataType && entity.dataType.integerValue != TNCacheDataTypeString && entity.data.length > 0) {
                // remove old file.
                NSString *filePath = [self.cacheDirectory URLByAppendingPathComponent:entity.data].path;
                NSFileManager *fm = [NSFileManager defaultManager];
                if (filePath.length > 0 && [fm fileExistsAtPath:filePath]) {
                    NSError *e2 = nil;
                    if (![fm removeItemAtPath:filePath error:&e2]) {
                        wrappedHandler(NO, e2);
                        return;
                    }
                }
            }
            entity.data = data;
        } else {
            if (entity.data.length == 0 || entity.dataType.integerValue == TNCacheDataTypeString) {
                entity.data = [[NSUUID UUID] UUIDString];
            }
        }
        entity.dataType = [NSNumber numberWithInteger:dataType];
        if (cls != NULL) {
            entity.dataClass = NSStringFromClass(cls);
        }
        
        __block NSError *e2 = e1;
        __block BOOL success = YES;
        void (^commit)(void) = ^{
            if (success) {
                entity.modificationDate = [NSDate date];
                success = [self.db commit:&e2];
            } else {
#if CACHE_LOG_ENABLED
                LogDebug(@"store error:%@, dataType: %@, key: %@", e2, @(dataType), key);
#endif
            }
            wrappedHandler(success, e2);
        };
        
        if (block) {
            NSURL *fileURL = [self.cacheDirectory URLByAppendingPathComponent:entity.data];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                success = block(fileURL, &e2);
                dispatch_async(dispatch_get_main_queue(), ^{
                    commit();
                });
            });
        } else {
            commit();
        }
    }];
}

- (void)removeCachedObjectForKey:(NSString *)key completion:(void (^)(BOOL, NSError *))completion
{
    [self removeCachedObjectForKey:key domain:TNCacheDomainDefault completion:completion];
}

- (void)removeCachedObjectForKey:(NSString *)key domain:(TNCacheDomain)domain completion:(void (^)(BOOL, NSError *))completion
{
    void (^wrappedHandler)(BOOL success, NSError *error) = ^(BOOL success, NSError *error){
        if (completion) {
            completion(success, error);
        }
    };
    
    if (key.length == 0) {
        wrappedHandler(NO, [NSError errorWithDomain:TNCacheErrorDomain code:TNCacheErrorKeyNull userInfo:nil]);
        return;
    }
    
    [self.db fetchFromTemplateWithName:FetchByKeyTemplateName substitutionVariables:@{@"KEY": key, @"DOMAIN": @(domain)} completion:^(NSArray *result, NSError *e1) {
        if (!result) {
            wrappedHandler(NO, e1);
            return;
        }
        
        TNCacheEntity *entity = [result lastObject];
        if (!entity) {
            wrappedHandler(YES, nil);
            return;
        }
        
        if (entity.data.length > 0 && entity.dataType.integerValue != TNCacheDataTypeString) {
            NSString *filePath = [self.cacheDirectory URLByAppendingPathComponent:entity.data].path;
            NSFileManager *fm = [NSFileManager defaultManager];
            if (filePath.length > 0 && [fm fileExistsAtPath:filePath]) {
                NSError *e2 = nil;
                if (![fm removeItemAtPath:filePath error:&e2]) {
                    wrappedHandler(NO, e2);
                    return;
                }
            }
        }
        
        NSError *e2 = nil;
        [self.db deleteObject:entity];
        BOOL success = [self.db commit:&e2];
        wrappedHandler(success, e2);
    }];
}

- (id)cachedObjectWithMeta:(TNCacheEntity *)entity error:(NSError **)error
{
    if ([entity.dataType integerValue] == TNCacheDataTypeString) {
        [self.memoryCache setObject:entity.data forKey:entity.key];
        return entity.data;
    }
    id data = nil;
    if (entity.data) {
        NSURL *fileURL = [self.cacheDirectory URLByAppendingPathComponent:entity.data];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:fileURL.path]) {
            switch ([entity.dataType integerValue]) {
                case TNCacheDataTypeNSCoding:
                {
                    data = [NSKeyedUnarchiver unarchiveObjectWithFile:fileURL.path];
                    break;
                }
                case TNCacheDataTypeJSON:
                {
                    Class cls = NULL;
                    if (entity.dataClass.length > 0) {
                        cls = NSClassFromString(entity.dataClass);
                    }
                    data = [TNJsonUtil objectWithData:[NSData dataWithContentsOfURL:fileURL] class:cls error:error];
                    break;
                }
                case TNCacheDataTypeBinary:
                {
                    data = [NSData dataWithContentsOfURL:fileURL options:0 error:error];
                    break;
                }
                default:
                    break;
            }
            
            if (data) {
                unsigned long long fileSize = [[fm attributesOfItemAtPath:fileURL.path error:error] fileSize];
                if (fileSize < self.memoryCapacity / 3) {
                    [self.memoryCache setObject:data forKey:entity.key cost:(NSUInteger)fileSize];
                }
            }
        } else {
            if (error) {
                *error = [NSError errorWithDomain:TNCacheErrorDomain code:TNCacheErrorFileNotFound userInfo:nil];
            }
        }
    }
    return data;
}

- (id)cachedObjectForKey:(NSString *)key
{
    return [self cachedObjectForKey:key domain:TNCacheDomainDefault];
}

- (id)cachedObjectForKey:(NSString *)key domain:(TNCacheDomain)domain
{
    if (key.length == 0) {
        return nil;
    }
    
    id data = [self.memoryCache objectForKey:key];
    if (!data) {
        NSError *error = nil;
        TNCacheEntity *entity = [[self.db fetchFromTemplateWithName:FetchByKeyTemplateName substitutionVariables:@{@"KEY": key, @"DOMAIN": @(domain)} error:&error] lastObject];
        if (entity) {
            data = [self cachedObjectWithMeta:entity error:&error];
        } else {
#if CACHE_LOG_ENABLED
            LogDebug(@"key = %@, error = %@", key, error);
#endif
        }
    }
    return data;
}

- (void)cachedObjectForKey:(NSString *)key completion:(void (^)(id, NSError *))completion
{
    [self cachedObjectForKey:key domain:TNCacheDomainDefault completion:completion];
}

- (void)cachedObjectForKey:(NSString *)key domain:(TNCacheDomain)domain completion:(void (^)(id, NSError *))completion
{
    if (!completion) {
        return;
    }
    
    [self cachedObjectsForKeys:@[key] domain:domain completion:^(NSDictionary *cachedObjects, NSError *error) {
        completion([cachedObjects objectForKey:key], error);
    }];
}

- (void)cachedObjectsForKeys:(NSArray *)keys completion:(void (^)(NSDictionary *, NSError *))completion
{
    [self cachedObjectsForKeys:keys domain:TNCacheDomainDefault completion:completion];
}

- (void)cachedObjectsForKeys:(NSArray *)keys domain:(TNCacheDomain)domain completion:(void (^)(NSDictionary *, NSError *))completion
{
    if (!completion) {
        return;
    }
    
    void (^wrappedHandler)(id cachedObj, NSError *error) = ^(id cachedObj, NSError *error){
        if ([NSThread isMainThread]) {
            completion(cachedObj, error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(cachedObj, error);
            });
        }
    };
    
    if (keys.count == 0) {
        wrappedHandler(keys ? [NSDictionary dictionary] : nil, [NSError errorWithDomain:TNCacheErrorDomain code:TNCacheErrorKeyNull userInfo:nil]);
        return;
    }
    
    NSMutableArray *tempKeys = [NSMutableArray array];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [keys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        id value = [self.memoryCache objectForKey:key];
        if (value) {
            [result setObject:value forKey:key];
        } else {
            [tempKeys addObject:key];
        }
    }];
    
    if (tempKeys.count == 0) {
        wrappedHandler(result, nil);
    } else {
        void (^action)(NSArray *metas, NSError *error) = ^(NSArray *metas, NSError *error){
            if (!metas) {
                wrappedHandler(result, error);
                return;
            }
            
            NSMutableArray *unmanagedObjects = [NSMutableArray array];
            [metas enumerateObjectsUsingBlock:^(TNCacheEntity *entity, NSUInteger idx, BOOL *stop) {
                TNCacheEntity *obj = [[TNCacheEntity alloc] initWithEntity:entity.entity insertIntoManagedObjectContext:nil];
                obj.key = entity.key;
                obj.data = entity.data;
                obj.dataType = entity.dataType;
                obj.dataClass = entity.dataClass;
                [unmanagedObjects addObject:obj];
            }];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __block NSError *e1 = nil;
                [unmanagedObjects enumerateObjectsUsingBlock:^(TNCacheEntity *entity, NSUInteger idx, BOOL *stop) {
                    NSError *e2 = nil;
                    id data = [self cachedObjectWithMeta:entity error:&e2];
                    if (data) {
                        [result setObject:data forKey:entity.key];
                    } else {
                        e1 = e2;
                    }
                }];
                
                wrappedHandler(result, e1);
            });
        };
        
        if (tempKeys.count == 1) {
            [self.db fetchFromTemplateWithName:FetchByKeyTemplateName substitutionVariables:@{@"KEY": [tempKeys lastObject], @"DOMAIN": @(domain)} completion:action];
        } else {
            [self.db fetchFromTemplateWithName:FetchByKeysTemplateName substitutionVariables:@{@"KEYS": tempKeys, @"DOMAIN": @(domain)} completion:action];
        }
    }
}

- (NSDictionary *)cachedObjectInfoForKey:(NSString *)key
{
    return [self cachedObjectInfoForKey:key domain:TNCacheDomainDefault];
}

- (NSDictionary *)cachedObjectInfoForKey:(NSString *)key domain:(TNCacheDomain)domain
{
    if (key.length == 0) {
        return nil;
    }
    
    NSError *error = nil;
    TNCacheEntity *entity = [[self.db fetchFromTemplateWithName:FetchByKeyTemplateName substitutionVariables:@{@"KEY": key, @"DOMAIN": @(domain)} error:&error] lastObject];
    if (entity.dataType.integerValue != TNCacheDataTypeString && entity.data.length > 0) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        NSURL *url = [self.cacheDirectory URLByAppendingPathComponent:entity.data];
        if (url) {
            [info setObject:url forKey:TNCacheURLKey];
        }
        if (entity.creationDate) {
            [info setObject:entity.creationDate forKey:TNCacheCreationTimeKey];
        }
        if (entity.modificationDate) {
            [info setObject:entity.modificationDate forKey:TNCacheModificationTimeKey];
        }
        return info;
    }
    return nil;
}

- (void)clearMemory
{
    [self.memoryCache removeAllObjects];
}

- (void)clearDisk
{
    [[NSFileManager defaultManager] removeItemAtURL:self.cacheDirectory error:nil];
    [[NSFileManager defaultManager] createDirectoryAtURL:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    
    [self.db clearObjectsWithEntityName:TNCacheEntityName error:nil];
}

#pragma mark - Partial Clear
- (void)removeCachedObjectsWithMetas:(NSArray *)metas completion:(void (^)(BOOL, NSArray *, NSError *))completion
{
    NSMutableArray *failedKeys = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    __block NSError *e1 = nil;
    __block NSError *e2 = nil;
    __block BOOL changed = NO;
    [metas enumerateObjectsUsingBlock:^(TNCacheEntity *obj, NSUInteger idx, BOOL *stop) {
        if (obj.dataType.integerValue == TNCacheDataTypeString) {
            [self.db deleteObject:obj];
            changed = YES;
        } else {
            NSURL *fileURL = [self.cacheDirectory URLByAppendingPathComponent:obj.data];
            if (![fm fileExistsAtPath:fileURL.path] || [fm removeItemAtURL:fileURL error:&e2]) {
                [self.db deleteObject:obj];
                changed = YES;
            } else {
                [failedKeys addObject:obj.key];
                e1 = e2;
            }
        }
    }];
    
    BOOL dbSuccess = YES;
    if (changed) {
        dbSuccess = [self.db commit:&e2];
        if (!dbSuccess) {
            e1 = e2;
        }
    }
    
    if (completion) {
        completion(dbSuccess && failedKeys.count == 0, failedKeys.count > 0 ? failedKeys : nil, e1);
    }
}

- (void)removeCachedObjectsWithoutKeys:(NSArray *)remainedKeys domain:(TNCacheDomain)domain completion:(void (^)(BOOL, NSArray *, NSError *))completion
{
    [self.db fetchFromTemplateWithName:FetchByKeysTemplateName substitutionVariables:@{@"KEYS": remainedKeys, @"DOMAIN": @(domain)} completion:^(NSArray *result, NSError *error) {
        if (!result) {
            if (completion) {
                completion(NO, nil, error);
            }
            return;
        }
        
        [self removeCachedObjectsWithMetas:result completion:completion];
    }];
}

- (void)removeCachedObjectsWithKeys:(NSArray *)removedKeys domain:(TNCacheDomain)domain completion:(void (^)(BOOL, NSArray *, NSError *))completion
{
    if (removedKeys.count == 0) {
        if (completion) {
            completion(YES, nil, [NSError errorWithDomain:TNCacheErrorDomain code:TNCacheErrorKeyNull userInfo:nil]);
        }
        return;
    }
    
    [self.db fetchFromTemplateWithName:FetchByKeysTemplateName substitutionVariables:@{@"KEYS": removedKeys, @"DOMAIN": @(domain)} completion:^(NSArray *result, NSError *error) {
        if (!result) {
            if (completion) {
                completion(NO, nil, error);
            }
            return;
        }
        
        [self removeCachedObjectsWithMetas:result completion:completion];
    }];
}

@end
