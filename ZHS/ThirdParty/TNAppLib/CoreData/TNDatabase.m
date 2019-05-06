//
//  TNDatabase.m
//  TestChat
//
//  Created by DengQiang on 14-6-12.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import "TNDatabase.h"
#import "NSFileManager+TNAppLib.h"
#import "TNAppLibMacros.h"
#import "TNLogger.h"

NSString *const TNDatabaseOnlyUsedInMainThreadOption = @"OnlyUsedInMainThread";    // an NSNumber of BOOL, default is NO.
NSString *const TNDatabaseStoreURLOption = @"StoreURL";

@interface TNDatabase ()

@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation TNDatabase

- (id)init
{
    [[NSException exceptionWithName:NSInvalidArgumentException reason:@"Model name can't be null." userInfo:nil] raise];
    return nil;
}

- (id)initWithModelName:(NSString *)modelName options:(NSDictionary *)options
{
    if (self = [super init]) {
        self.modelName = modelName;
        self.options = options;
    }
    return self;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        BOOL mainthreadOnly = [self boolOptionForKey:TNDatabaseOnlyUsedInMainThreadOption defaultValue:NO];
        if (mainthreadOnly) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        } else {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        }
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self.options objectForKey:TNDatabaseStoreURLOption];
    if (storeURL == nil) {
        storeURL = [[[self directory] URLByAppendingPathComponent:self.modelName] URLByAppendingPathExtension:@"sqlite"];
    }
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
//        LogDebug(@"Unresolved error: %@, %@", error, [error userInfo]);
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
//            LogDebug(@"Unresolved error after removeItemAtURL: %@, %@", error, [error userInfo]);
//            abort();
            _persistentStoreCoordinator = nil;
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Database's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)directory
{
    NSURL *dir = [[NSFileManager applicationPrivateDirectory] URLByAppendingPathComponent:[@"/db/" stringByAppendingString:self.modelName] isDirectory:YES];
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir.path isDirectory:&isDir] || !isDir) {
        if (![[NSFileManager defaultManager] createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:nil]) {
            return nil;
        }
    }
    return dir;
}

#pragma mark - Options

- (BOOL)boolOptionForKey:(NSString *)key defaultValue:(BOOL)defaultValue
{
    id obj = [self.options objectForKey:key];
    return obj && [obj respondsToSelector:@selector(boolValue)] ? [obj boolValue] : defaultValue;
}

#pragma mark - Actions

- (NSEntityDescription *)entityDescriptionWithName:(NSString *)entityName
{
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
}

- (id)insertObjectWithEntityName:(NSString *)entityName
{
    __block id object = nil;
    [self performBlockAndWait:^{
        object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    }];
    return object;
}

- (void)deleteObject:(NSManagedObject *)object
{
    [self performBlockAndWait:^{
        [self.managedObjectContext deleteObject:object];
    }];
}

- (void)mergeObject:(NSManagedObject *)object
{
    [self performBlockAndWait:^{
        [self.managedObjectContext refreshObject:object mergeChanges:YES];
    }];
}

- (void)rollback
{
    [self.managedObjectContext performBlockAndWait:^{
        [self.managedObjectContext rollback];
    }];
}

- (BOOL)commit:(NSError *__autoreleasing *)error
{
    __block BOOL success = NO;
    [self performBlockAndWait:^{
        success = [self.managedObjectContext save:error];
    }];
//    LogDebug(@"commit finished: %d, error: %@", success, error == NULL ? @"" : *error);
    return success;
}

- (NSFetchRequest *)fetchRequestFromTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables error:(NSError *__autoreleasing *)error
{
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:name substitutionVariables:variables ? variables : @{}];
    if (request == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"TNDatabase" code:TNFetchRequestTemplateInvalidError userInfo:nil];
        }
        return nil;
    }
    return request;
}

- (id)objectWithID:(NSManagedObjectID *)objectID error:(NSError *__autoreleasing *)error
{
    __block id obj = nil;
    [self performBlockAndWait:^{
        obj = [self.managedObjectContext existingObjectWithID:objectID error:error];
    }];
    return obj;
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(NSError *__autoreleasing *)error
{
    if (request == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"TNDatabase" code:TNFetchRequestNullError userInfo:nil];
        }
        return nil;
    }
    
    __block NSArray *result = nil;
    [self performBlockAndWait:^{
        result = [self.managedObjectContext executeFetchRequest:request error:error];
    }];
    return result;
}

- (void)executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *result, NSError *error))completion
{
    if (request == nil) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"TNDatabase" code:TNFetchRequestNullError userInfo:nil]);
        }
        return;
    }
    
    [self performBlock:^{
        NSError *error = nil;
        NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (completion) {
            if ([NSThread isMainThread]) {
                completion(result, error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(result, error);
                });
            }
        }
    }];
}

- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request error:(NSError *__autoreleasing *)error
{
    if (request == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"TNDatabase" code:TNFetchRequestNullError userInfo:nil];
        }
        return NSNotFound;
    }
    
    __block NSUInteger count = 0;
    [self performBlockAndWait:^{
        count = [self.managedObjectContext countForFetchRequest:request error:error];
    }];
    return count;
}

- (void)countForFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSUInteger, NSError *))completion
{
    if (request == nil) {
        if (completion) {
            completion(NSNotFound, [NSError errorWithDomain:@"TNDatabase" code:TNFetchRequestNullError userInfo:nil]);
        }
        return;
    }
    
    [self performBlock:^{
        NSError *error = nil;
        NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
        if (completion) {
            if ([NSThread isMainThread]) {
                completion(count, error);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(count, error);
                });
            }
        }
    }];
}

- (NSUInteger)countForTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables error:(NSError *__autoreleasing *)error
{
    NSFetchRequest *request = [self fetchRequestFromTemplateWithName:name substitutionVariables:variables error:error];
    if (request == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"TNDatabase" code:TNFetchRequestTemplateInvalidError userInfo:nil];
        }
        return NSNotFound;
    }
    return [self countForFetchRequest:request error:error];
}

- (void)countForTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables completion:(void (^)(NSUInteger, NSError *))completion
{
    NSError *error = nil;
    NSFetchRequest *request = [self fetchRequestFromTemplateWithName:name substitutionVariables:variables error:&error];
    if (request == nil) {
        if (completion) {
            completion(NSNotFound, error);
        }
        return;
    }
    
    return [self countForFetchRequest:request completion:completion];
}

- (NSArray *)fetchFromTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables error:(NSError *__autoreleasing *)error
{
    NSFetchRequest *request = [self fetchRequestFromTemplateWithName:name substitutionVariables:variables error:error];
    if (request == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"TNDatabase" code:TNFetchRequestTemplateInvalidError userInfo:nil];
        }
        return nil;
    }
    return [self executeFetchRequest:request error:error];
}

- (void)fetchFromTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables completion:(void (^)(NSArray *, NSError *))completion
{
    NSError *error = nil;
    NSFetchRequest *request = [self fetchRequestFromTemplateWithName:name substitutionVariables:variables error:&error];
    if (request == nil) {
        if (completion) {
            completion(nil, error);
        }
        return;
    }
    
    [self executeFetchRequest:request completion:completion];
}

- (BOOL)clearObjectsWithEntityName:(NSString *)entityName error:(NSError *__autoreleasing *)error
{
    __block BOOL success = NO;
    [self performBlockAndWait:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [request setIncludesPropertyValues:NO];
        [request setIncludesSubentities:NO];
        NSArray *result = [self.managedObjectContext executeFetchRequest:request error:error];
        if (result == nil) {
            return;
        }
        
        success = YES;
        if (result.count > 0) {
            [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.managedObjectContext deleteObject:obj];
            }];
            success = [self.managedObjectContext save:error];
        }
    }];
//    LogDebug(@"clear %@ finished: %d, error: %@", entityName, success, error == NULL ? @"" : *error);
    return success;
}

- (void)performBlock:(void (^)())block
{
    [self.managedObjectContext performBlock:block];
}

- (void)performBlockAndWait:(void (^)())block
{
    [self.managedObjectContext performBlockAndWait:block];
}

- (void)reset
{
    [self performBlockAndWait:^{
        [self.managedObjectContext reset];
    }];
}

@end
