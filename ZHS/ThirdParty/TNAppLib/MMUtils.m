//
//  MMUtils.m
//  Mikoto
//
//  Created by xxd on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "MMUtils.h"
#import "MMMacros.h"
#import "NSDictionary+MMExt.h"
#import <objc/runtime.h>


CGFloat CGPointGetDistanceToPoint(CGPoint fromPoint, CGPoint toPoint)
{
    return sqrtf(powf(fromPoint.x-toPoint.x,2)+powf(fromPoint.y-toPoint.y, 2));
}
CGPoint CGPointMakeWithSubPoint(CGPoint minuend, CGPoint subtrahend)
{
    CGPoint delta = CGPointZero;
    delta.x = minuend.x - subtrahend.x;
    delta.y = minuend.y - subtrahend.y;
    return delta;
}
CGPoint CGPointMakeWithAddPoint(CGPoint original, CGPoint delta)
{
    CGPoint newPoint = CGPointZero;
    newPoint.x = original.x + delta.x;
    newPoint.y = original.y + delta.y;
    return newPoint;
}
CGPoint CGPointMakeByScale(CGPoint original, CGFloat scale)
{
    CGPoint newPoint = original;
    newPoint.x *= scale;
    newPoint.y *= scale;
    return newPoint;
}

CGSize  CGSizeMakeByScale(CGSize original, CGFloat scale)
{
    CGSize newSize = CGSizeZero;
    newSize.width = original.width*scale;
    newSize.height = original.height*scale;
    return newSize;
}
CGFloat CGSizeGetScaleFromSzie(CGSize origin, CGSize scaleSize)
{
    return powf((scaleSize.width*scaleSize.height)/(origin.width*origin.height), 0.5);
}

CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}
CGRect  CGRectMakeByScale(CGRect rect, CGFloat scale)
{
    CGRect newrect = CGRectZero;
    newrect.origin.x = scale*rect.origin.x;
    newrect.origin.y = scale*rect.origin.y;
    newrect.size.width = scale*rect.size.width;
    newrect.size.height = scale*rect.size.height;
    return newrect;
}
CGRect  CGRectMakeByMoveToCenter(CGRect rect, CGPoint center)
{
    CGRect newrect = CGRectZero;
    newrect.origin.x = center.x-CGRectGetWidth(rect)/2;
    newrect.origin.y = center.y-CGRectGetHeight(rect)/2;
    newrect.size = rect.size;
    return newrect;
}
CGRect  CGRectMakeByMoveByPoint(CGRect rect, CGPoint delta)
{
    CGRect newrect = rect;
    newrect.origin.x += delta.x;
    newrect.origin.y += delta.y;
    return newrect;
}
CGRect  CGRectMakeWithOriginAndSize(CGPoint origin, CGSize size)
{
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}
CGRect CGRectMakeWithCenterAndSize(CGPoint center, CGSize size)
{
    return CGRectMake(center.x-size.width/2, center.y-size.height/2, size.width, size.height);
}
CGRect  CGRectMakeWithMargin(CGRect rect, CGFloat margin)
{
    CGRect newrect = rect;
    newrect.origin.x += margin;
    newrect.origin.y += margin;
    newrect.size.width -= margin*2;
    newrect.size.height -= margin*2;
    return newrect;
}
CGRect  CGRectMakeWithEdgeInset(CGRect rect, UIEdgeInsets edge)
{
    CGRect newrect = rect;
    newrect.origin.x += edge.left;
    newrect.origin.y += edge.top;
    newrect.size.width -= edge.left+edge.right;
    newrect.size.height -= edge.top+edge.bottom;
    return newrect;
}

@implementation MMUtils
+ (id)creatObjectWithJsonDic:(NSDictionary*)data forClass:(Class)targetClass
{
    id target = [[targetClass alloc] init];
    uint propertiesCount;
    objc_property_t * properties = class_copyPropertyList(targetClass, &propertiesCount);
    for (int i=0; i<propertiesCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * key = @(property_getName(property));
        if ([data valueForKey:key] && [self isEnableKVCInClass:targetClass forProperty:key])
        {
            [target setValue:[data valueForKey:key] forKey:key];
        }
    }
    return target;
}

+ (id)copyModel:(id)model
{
    Class class = [model class];
    id newModel = [[class alloc] init];
    uint propertiesCount;
    objc_property_t * properties = class_copyPropertyList(class, &propertiesCount);
    for (int i=0; i<propertiesCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * key = @(property_getName(property));
        if ([model valueForKey:key] && [self isEnableKVCInClass:class forProperty:key])
        {
            if ([[model valueForKey:key] conformsToProtocol:@protocol(NSMutableCopying)])
            {
                [newModel setValue:[[model valueForKey:key] mutableCopy] forKey:key];
            }
            if ([[model valueForKey:key] conformsToProtocol:@protocol(NSCopying)])
            {
                [newModel setValue:[[model valueForKey:key] copy] forKey:key];
            }
            else
            {
                [newModel setValue:[MMUtils copyModel:[model valueForKey:key]] forKey:key];
            }
        }
    }
    return newModel;
}

+ (id)transformModel:(id)oldModel toClass:(Class)targetClass
{
    id newModel = [[targetClass alloc] init];
    uint propertiesCount;
    objc_property_t * properties = class_copyPropertyList(targetClass, &propertiesCount);
    for (int i=0; i<propertiesCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * key = @(property_getName(property));
        if (class_getProperty([oldModel class], property_getName(property)) && [self isEnableKVCInClass:targetClass forProperty:key])
        {
            [newModel setValue:[oldModel valueForKey:key] forKey:key];
        }
    }
    return newModel;
}

+ (id)transformModel:(id)oldModel toClass:(Class)targetClass withMap:(NSDictionary *)map
{
    id newModel = [[targetClass alloc] init];
    [map enumerateKeysAndObjectsUsingBlock:^(NSString *oldKey, NSString *newKey, BOOL *stop) {
        if (class_getProperty([oldModel class], oldKey.UTF8String) && class_getProperty(targetClass, newKey.UTF8String) && [self isEnableKVCInClass:targetClass forProperty:newKey])
        {
            [newModel setValue:[oldModel valueForKey:oldKey] forKey:newKey];
        }
    }];
    return newModel;
}

+ (Class)getPropertyClassOfClass:(Class)targetClass withPropertyKey:(NSString *)aProperty
{
    Class propertyClass = nil;
    objc_property_t property = class_getProperty(targetClass, aProperty.UTF8String);
    if (property)
    {
        char *typeEncoding = property_copyAttributeValue(property, "T");
        switch (typeEncoding[0])
        {
            case '@':
            {
                if (strlen(typeEncoding) > 3)
                {
                    char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                    NSString *name = @(className);
                    NSRange range = [name rangeOfString:@"<"];
                    if (range.location != NSNotFound)
                    {
                        name = [name substringToIndex:range.location];
                    }
                    propertyClass = NSClassFromString(name) ?: [NSObject class];
                    free(className);
                }
                break;
            }
            case 'c': // Numeric types
            case 'i':
            case 's':
            case 'l':
            case 'q':
            case 'C':
            case 'I':
            case 'S':
            case 'L':
            case 'Q':
            case 'f':
            case 'd':
            case 'B':
            {
                propertyClass = [NSNumber class];
                break;
            }
            case '{': // Struct type
            {
                propertyClass = [NSValue class];
                break;
            }
            case '[': // C-Array
            case '(': // Enum
            case '#': // Class
            case ':': // Selector
            case '^': // Pointer
            case 'b': // Bitfield
            case '?': // Unknown type
            default:
                break; // These typies are not supported by KVC
        }
        free(typeEncoding);
    }
    return propertyClass;
}

+ (void)initPropertiesForObject:(id)object
{
    uint count = 0;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    for (int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *key = @(property_getName(property));
        Class propertyClass = [MMUtils getPropertyClassOfClass:object withPropertyKey:key];
        if (![object valueForKey:key] && [self isEnableKVCInClass:[object class] forProperty:key])
        {
            id propertyInstance = [[propertyClass alloc] init];
            [MMUtils initPropertiesForObject:propertyInstance];
            [object setValue:propertyInstance forKey:key];
        }
    }
}

+ (void)setValuesWithDictionary:(NSDictionary *)data forObject:(id)object
{
    if (object && data)
    {
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (class_getProperty([object class], [[key componentsSeparatedByString:@"."][0] UTF8String]))
            {
                NSMutableArray *propertyLevels = [[key componentsSeparatedByString:@"."] mutableCopy];
                if (![obj isKindOfClass:[NSNull class]])
                {
                    [self privateSetValue:obj toObject:object withSelfClass:[object class] forPropertyKeyLevels:propertyLevels ofKeyPath:@""];
                }
            }
        }];
    }
}

+ (void)setValuesWithDictionary:(NSDictionary *)data forObject:(id)object withMap:(NSDictionary *)map
{
    if (object && data)
    {
        data = [data dictionaryWithMapKeysWithMap:map];
        [self setValuesWithDictionary:data forObject:object];
    }
}

+ (UIViewController *)getCurrentTopViewController
{
    
    UIViewController *result;
    
   	UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = ((int)(([[UIDevice currentDevice].systemVersion doubleValue])*1000) >= 8000) ? [[topWindow subviews][0] subviews][0] : [topWindow subviews][0];
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
    {
        result = topWindow.rootViewController;
    }
    else
    {
        MMLog(@"MMLib WARNING: can not find root viewcontroller.");
        return nil;
    }
    
    while (([result respondsToSelector:@selector(rootViewController)] && [result valueForKey:@"rootViewController"] != nil) ||
           [result respondsToSelector:@selector(topViewController)] ||
           [result respondsToSelector:@selector(selectedViewController)] )
    {
        if ([result respondsToSelector:@selector(rootViewController)] && [result valueForKey:@"rootViewController"] != nil)
        {
            result = [result valueForKey:@"rootViewController"];
        }
        else if ([result respondsToSelector:@selector(topViewController)])
        {
            result = [result valueForKey:@"topViewController"];
        }
        else if ([result respondsToSelector:@selector(selectedViewController)])
        {
            result = [result valueForKey:@"selectedViewController"];
        }
    }
    return result;
}

#pragma mark - private methods
+ (void)privateSetValue:(id)value toObject:(id)object withSelfClass:(Class)selfClass forPropertyKeyLevels:(NSMutableArray *)properties ofKeyPath:(NSString *)keyPath
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
            if (![value isKindOfClass:[NSNull class]] && !(([value isKindOfClass:[NSString class]] && [value isEqualToString:@""]) && propertyClass != [NSString class]))
            {
                [object setValue:value forKeyPath:keyPath];
            }
        }
        else
        {
            if (![object valueForKeyPath:keyPath])
            {
                [object setValue:[[propertyClass alloc] init] forKeyPath:keyPath];
            }
            [self privateSetValue:value toObject:object withSelfClass:propertyClass forPropertyKeyLevels:properties ofKeyPath:keyPath];
        }
    }
}

+ (BOOL)isEnableKVCInClass:(Class)targetClass forProperty:(NSString *)propertyKey
{
    objc_property_t property = class_getProperty(targetClass, propertyKey.UTF8String);
    Class propertyClass = [self getPropertyClassOfClass:targetClass withPropertyKey:propertyKey];
    if (propertyClass)
    {
        char *ivar = property_copyAttributeValue(property, "V");
        if (ivar)
        {
            NSString *ivarName = @(ivar);
            if ([ivarName isEqualToString:propertyKey] || [ivarName isEqualToString:[NSString stringWithFormat:@"_%@", propertyKey]])
            {
                return YES;
            }
            else
            {
                //if no ivar but property is dynamic and not readonly, setValue method also work
                char *dynamic = property_copyAttributeValue(property, "D");
                char *readonly = property_copyAttributeValue(property, "R");
                if (dynamic && !readonly)
                {
                    return YES;
                }
                free(dynamic);
                free(readonly);
            }
            free(ivar);
        }
    }
    return NO;
}
@end
