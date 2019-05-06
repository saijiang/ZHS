//
//  MMBaseModel.m
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "MMBaseModel.h"
#import "MMMacros.h"
#import "MMUtils.h"
#import "NSArray+MMExt.h"
#import "NSDictionary+MMExt.h"
#import <objc/runtime.h>

@implementation MMBaseModel
+ (instancetype)emptyModel
{
    return [[self alloc] init];
}

+ (instancetype)initializedModel
{
    MMBaseModel* model = [[self alloc] init];
    [MMUtils initPropertiesForObject:model];
    return model;
}

#pragma mark - MMAutoCodingModel
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init])
    {
        BOOL secureAvailable = [aDecoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)];
        NSDictionary *properties = [self codableProperties];
        for (NSString *key in properties)
        {
            id object = nil;
            Class propertyClass = properties[key];
            if (secureAvailable)
            {
                object = [aDecoder decodeObjectOfClass:propertyClass forKey:key];
            }
            else
            {
                object = [aDecoder decodeObjectForKey:key];
            }
            if (object)
            {
                [self setValue:object forKey:key];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    uint propertiseCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertiseCount);
    for (int i=0; i<propertiseCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString * key = @(propertyName);
        id value =  [self valueForKey:key];
        if (![[self class] uncodeKeys] && ![[[self class] uncodeKeys] containsObject:key] && value != nil)
        {
            [aCoder encodeObject:value forKey:key];
        }
    }
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

/**
 *  All codable properties for instance.
 *
 *  @return Codable properties dictionary.
 */
- (NSDictionary *)codableProperties
{
    NSDictionary *codableProperties = objc_getAssociatedObject([self class], _cmd);
    if (!codableProperties)
    {
        codableProperties = [NSMutableDictionary dictionary];
        Class class = [self class];
        while (class != [NSObject class])
        {
            [(NSMutableDictionary *)codableProperties addEntriesFromDictionary:[class codableProperties]];
            class = [class superclass];
        }
        codableProperties = [NSDictionary dictionaryWithDictionary:codableProperties];
        
        //make the association atomically so that we don't need to bother with an @synchronize
        objc_setAssociatedObject([self class], _cmd, codableProperties, OBJC_ASSOCIATION_RETAIN);
    }
    return codableProperties;
}

/**
 *  Codable properties in dictionary as {"property name" : "property class"} for current class.
 *
 *  @return Codable properties dictionary.
 */
+ (NSDictionary *)codableProperties
{
    NSMutableDictionary *codableProperties = [@{} mutableCopy];
    uint propertiseCount;
    objc_property_t *properties = class_copyPropertyList(self, &propertiseCount);
    for (int i=0; i<propertiseCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString * key = @(propertyName);
        if (![self uncodeKeys] || ![[self uncodeKeys] containsObject:key])
        {
            Class propertyClass = [MMUtils getPropertyClassOfClass:self withPropertyKey:key];
            if (propertyClass)
            {
                char *ivar = property_copyAttributeValue(property, "V");
                if (ivar)
                {
                    NSString *ivarName = @(ivar);
                    if ([ivarName isEqualToString:key] || [ivarName isEqualToString:[NSString stringWithFormat:@"_%@", key]])
                    {
                        codableProperties[key] = propertyClass;
                    }
                    else
                    {
                        //if no ivar but property is dynamic and not readonly, setValue method also work
                        char *dynamic = property_copyAttributeValue(property, "D");
                        char *readonly = property_copyAttributeValue(property, "R");
                        if (dynamic && !readonly)
                        {
                            codableProperties[key] = propertyClass;
                        }
                        free(dynamic);
                        free(readonly);
                    }
                    free(ivar);
                }
            }
        }
    }
    free(properties);
    return codableProperties;
}

+ (NSArray *)uncodeKeys
{
    if ([self class] != [MMBaseModel class])
    {
//        MMLog(@"WARNING: [MMBaseModle uncodeKeys] method must be reload in subclass if subclass invoke +[initWithCoder:] method. In %@.", [self class]);
    }
    return nil;
}

- (BOOL)isCodablePropertyForKey:(NSString *)key
{
    return [self codableProperties][key] != nil;
}

+ (instancetype)modelAutoDecodeWithFile:(NSString *)filePath
{
    //load the file
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    //attempt to deserialise data as a plist
    id model = nil;
    if (data)
    {
        NSPropertyListFormat format;
        model = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:NULL];
        if (model)
        {
            //check if object is an NSCoded unarchive
            if ([model respondsToSelector:@selector(objectForKey:)] && [(NSDictionary *)model objectForKey:@"$archiver"])
            {
                model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        }
        else
        {
            //return raw data
            model = data;
        }
    }
    return model;
}

- (BOOL)writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile
{
    //archive object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [data writeToFile:filePath atomically:useAuxiliaryFile];
}

#pragma mark - MMJsonModel
+ (instancetype)modelWithJsonDicWithoutMap:(NSDictionary *)data
{
    MMBaseModel *modelObjc = [[self alloc] init];
    if (data)
    {
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSMutableArray *propertyLevels = [[key componentsSeparatedByString:@"."] mutableCopy];
            if (![obj isKindOfClass:[NSNull class]])
            {
                [modelObjc _privateSetValue:obj withSelfClass:self forPropertyKeyLevels:propertyLevels ofKeyPath:@""];
            }
        }];
    }
    return modelObjc;
}

+ (instancetype)modelWithJsonDicUseSelfMap:(NSDictionary *)data
{
    if ([self jsonMap])
    {
        return [self modelWithJsonDicWithoutMap:[data dictionaryWithMapKeysWithMap:[self jsonMap]]];
    }
    else
    {
        return [self modelWithJsonDicWithoutMap:data];
    }
}

+ (instancetype)modelWithJsonDic:(NSDictionary *)data withMap:(NSDictionary *)map
{
    return [self modelWithJsonDicWithoutMap:[data dictionaryWithMapKeysWithMap:map]];
}

- (NSString *)jsonString
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self jsonObject] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

- (NSString *)jsonStringWithSelfMap
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self jsonObjectWithSelfMap] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

- (NSString *)jsonStringWithMap:(NSDictionary *)map
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self jsonObjectWithMap:map] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)jsonObject
{
    return [self _privateFormatJsonObjectWithMap:nil];
}

- (NSDictionary *)jsonObjectWithSelfMap
{
    return [self jsonObjectWithMap:[[self class] jsonMap]];
}

- (NSDictionary *)jsonObjectWithMap:(NSDictionary *)map
{
    return [self _privateFormatJsonObjectWithMap:map];
}

+ (NSDictionary *)jsonMap
{
//    MMLog(@"WARNING: [MMBaseModle jsonMap] method must be reload in subclass if subclass invoke +[modelWithJsonDicUseSelMap:] method.");
    return nil;
}

#pragma mark - Properties operation methods
- (void)addPropertiesWithModel:(id)add withProperiesList:(NSArray *)properties
{
    if (add && properties)
    {
        [properties enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            if ([add valueForKey:key] && class_getProperty([self class], key.UTF8String))
            {
                [self setValue:[add valueForKey:key] forKey:key];
            }
        }];
    }
}

- (void)addPropertiesWithModel:(id)add withProperiesMapping:(NSDictionary *)map
{
    if (add && map)
    {
        [map enumerateKeysAndObjectsUsingBlock:^(NSString *addKey, NSString *selfKey, BOOL *stop) {
            if ([add valueForKey:addKey] && class_getProperty([self class], selfKey.UTF8String))
            {
                [self setValue:[add valueForKey:addKey] forKey:selfKey];
            }
        }];
    }
}

#pragma mark - Private methods
- (void)_privateSetValue:(id)value withSelfClass:(Class)selfClass forPropertyKeyLevels:(NSMutableArray *)properties ofKeyPath:(NSString *)keyPath
{
    objc_property_t property = class_getProperty(selfClass, [properties[0] UTF8String]);
    Class propertyClass = [MMUtils getPropertyClassOfClass:selfClass withPropertyKey:properties[0]];
    if (!propertyClass) return;
    
    keyPath = [keyPath stringByAppendingFormat:@"%@%@", [keyPath isEqualToString:@""]?@"":@".", properties[0]];
    [properties removeObjectAtIndex:0];
    
    if (property)
    {
        if (properties.count == 0)
        {
            if (![value isKindOfClass:[NSNull class]])
            {
                [self setValue:value forKeyPath:keyPath];
            }
        }
        else
        {
            if (![self valueForKeyPath:keyPath])
            {
                [self setValue:[[propertyClass alloc] init] forKeyPath:keyPath];
            }
            [self _privateSetValue:value withSelfClass:propertyClass forPropertyKeyLevels:properties ofKeyPath:keyPath];
        }
    }
}

- (NSDictionary *)_privateFormatJsonObjectWithMap:(NSDictionary *)map
{
    NSMutableDictionary *codingProperties = [@{} mutableCopy];
    if (map)
    {
        [map enumerateKeysAndObjectsUsingBlock:^(NSString *propertyKeyPath, NSString *jsonKey, BOOL *stop) {
            id value = [self valueForKeyPath:propertyKeyPath];
            if (value)
            {
                [codingProperties setObject:value forKey:jsonKey];
            }
        }];
    }
    else
    {
        uint propertiseCount;
        objc_property_t *properties = class_copyPropertyList([self class], &propertiseCount);
        for (int i=0; i<propertiseCount; i++)
        {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString * key = @(propertyName);
            Class propertyClass = [MMUtils getPropertyClassOfClass:[self class] withPropertyKey:key];
            id value = [self valueForKey:key];
            if (value && propertyClass)
            {
                if ([value isKindOfClass:[MMBaseModel class]])
                {
                    [codingProperties setObject:[value _privateFormatJsonObjectWithMap:nil] forKey:key];
                }
                else
                {
                    [codingProperties setObject:value forKey:key];
                }
            }
        }
    }
    return codingProperties;
}

#pragma mark formatter log
- (NSString *)description
{
    return [self customDescription:0];
}

- (NSString *)debugDescription
{
    return [self customDescription:0];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale indent:(NSUInteger)level
{
    return [self customDescription:level];
}

- (NSString *)customDescription:(NSUInteger)indent
{
    NSMutableString* desc = [[NSString stringWithFormat:@"<%@: %p> \n", self.class, self] mutableCopy];
    for (int i=0; i<=indent; i++)
    {
        [desc appendString:@"\t"];
    }
    [desc appendString:@" (\n"];
    
    uint propertiseCount;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertiseCount);
    for (int i=0; i<propertiseCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * key = @(property_getName(property));
        Class propertyClass = [MMUtils getPropertyClassOfClass:self.class withPropertyKey:key];
        id obj = [self valueForKey:key];
        if (!propertyClass || !obj || [obj isKindOfClass:[NSNull class]] ||
            ([obj isKindOfClass:[NSString class]] && [obj isEqualToString:@""]) ||
            ([obj isKindOfClass:[NSArray class]] && [(NSArray *)obj count] == 0) ||
            ([obj isKindOfClass:[NSDictionary class]] && [[obj allKeys] count] == 0))
        {
            continue;
        }
        else
        {
            for (int i=0; i<=indent; i++)
            {
                [desc appendString:@"\t"];
            }
            if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[MMBaseModel class]])
            {
                [desc appendFormat:@"\t\"%@\" : %@,\n", key, [obj descriptionWithLocale:nil indent:indent+1]];
            }
            else if ([obj isKindOfClass:[NSString class]])
            {
                [desc appendFormat:@"\t\"%@\" : \"%@\",\n", key, obj];
            }
            else
            {
                [desc appendFormat:@"\t\"%@\" : %@,\n", key, obj];
            }
        }
    }
    for (int i=0; i<=indent; i++)
    {
        [desc appendString:@"\t"];
    }
    [desc appendString:@" )"];
    return desc;
}
@end
