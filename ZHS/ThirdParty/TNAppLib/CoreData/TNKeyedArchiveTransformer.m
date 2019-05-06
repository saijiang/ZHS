//
//  TNKeyedArchiveTransformer.m
//  TestChat
//
//  Created by DengQiang on 14-6-12.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import "TNKeyedArchiveTransformer.h"

@implementation TNKeyedArchiveTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
