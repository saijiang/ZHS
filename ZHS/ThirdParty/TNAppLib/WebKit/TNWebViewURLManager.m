//
//  TNWebViewURLManager.m
//  WeZone
//
//  Created by DengQiang on 14-8-4.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNWebViewURLManager.h"
#import "TNRequestManager.h"

@interface TNWebViewURLManager ()

@end

@implementation TNWebViewURLManager

+ (TNWebViewURLManager *)defaultManager
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

@end
