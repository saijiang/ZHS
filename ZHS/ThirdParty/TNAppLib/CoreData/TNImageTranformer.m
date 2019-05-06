//
//  TNImageTranformer.m
//  TestChat
//
//  Created by DengQiang on 14-6-12.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import "TNImageTranformer.h"

@implementation TNImageTranformer

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
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value
{
    return [UIImage imageWithData:value];
}

@end
