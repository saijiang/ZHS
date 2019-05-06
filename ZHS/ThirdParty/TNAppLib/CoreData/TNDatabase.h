//
//  TNDatabase.h
//  TestChat
//
//  Created by DengQiang on 14-6-12.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const TNDatabaseOnlyUsedInMainThreadOption;    // an NSNumber of BOOL, default is NO.
extern NSString *const TNDatabaseStoreURLOption;    // an NSURL of custom db file path, default is nil.

enum {
    TNFetchRequestTemplateInvalidError = 231000,
    TNFetchRequestNullError,
};

@interface TNDatabase : NSObject

@property (readonly) NSString *modelName;

- (id)initWithModelName:(NSString *)modelName options:(NSDictionary *)options;

- (NSEntityDescription *)entityDescriptionWithName:(NSString *)entityName;
- (id)insertObjectWithEntityName:(NSString *)entityName;
- (void)deleteObject:(NSManagedObject *)object;
- (void)mergeObject:(NSManagedObject *)object;
- (void)rollback;
- (BOOL)commit:(NSError **)error;

- (NSFetchRequest *)fetchRequestFromTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables error:(NSError **)error;

- (id)objectWithID:(NSManagedObjectID *)objectID error:(NSError **)error;
- (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(NSError **)error;
- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request error:(NSError **)error;

/**
 *  Returns a copy of the fetch request template with the variables substituted by values from the substitutions dictionary.
 *
 *  @discussion The variables dictionary must provide values for all the variables. If you want to test for a nil value, use [NSNull null].
 *
 *  @discussion This method provides the usual way to bind an “abstractly” defined fetch request template to a concrete fetch. For more details on using this method, see Creating Predicates.
 *  
 *  @param name         A string containing the name of a fetch request template.
 *  @param variables    A dictionary containing key-value pairs where the keys are the names of variables specified in the template; the corresponding values are substituted before the fetch request is returned. The dictionary must provide values for all the variables in the template.
 *  
 *  @return A copy of the fetch request template with the variables substituted by values from variables.
 */
- (NSUInteger)countForTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables error:(NSError **)error;
- (NSArray *)fetchFromTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables error:(NSError **)error;

- (void)executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *result, NSError *error))completion;
- (void)countForFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSUInteger count, NSError *error))completion;

- (void)countForTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables completion:(void (^)(NSUInteger count, NSError *error))completion;
- (void)fetchFromTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables completion:(void (^)(NSArray *result, NSError *error))completion;

- (BOOL)clearObjectsWithEntityName:(NSString *)entityName error:(NSError **)error;

/* asynchronously performs the block on the context's queue.  Encapsulates an autorelease pool and a call to processPendingChanges */
- (void)performBlock:(void (^)())block NS_AVAILABLE(10_7,  5_0);

/* synchronously performs the block on the context's queue.  May safely be called reentrantly.  */
- (void)performBlockAndWait:(void (^)())block NS_AVAILABLE(10_7,  5_0);

- (void)reset;

@end
