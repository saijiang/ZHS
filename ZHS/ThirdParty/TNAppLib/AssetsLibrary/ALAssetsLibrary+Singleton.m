//
//  ALAssetsLibrary+Singleton.m
//  TTXClient
//
//  Created by kiri on 13-5-28.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "ALAssetsLibrary+Singleton.h"

@implementation ALAssetsLibrary (Singleton)

+ (id)sharedLibrary
{
    static dispatch_once_t onceToken;
    static ALAssetsLibrary *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ALAssetsLibrary alloc] init];
    });
    return instance;
}

@end