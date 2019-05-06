//
//  TNNibUtil.m
//  TNAppLib
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNNibUtil.h"

@implementation TNNibUtil

+ (id)loadMainObjectFromNib:(NSString *)nibName
{
    Class clazz = NSClassFromString(nibName);
    if (clazz) {
        return [self loadObjectWithClass:clazz fromNib:nibName];
    }
    return nil;
}

+ (id)loadObjectWithClass:(Class)clazz fromNib:(NSString *)nibName
{
    NSArray *objList = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    id tmpObj = nil;
    for (id obj in objList) {
        if ([obj isMemberOfClass:clazz]) {
            return obj;
        } else if ([obj isKindOfClass:clazz]) {
            tmpObj = obj;
        }
    }
    return tmpObj;
}

@end
