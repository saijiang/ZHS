//
//  TNJSBridge.m
//  WeZone
//
//  Created by Frank on 14-9-16.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNJSBridge.h"

@implementation TNJSBridge

- (id)initWithViewController:(TNWebViewController *)controller
{
    if (self = [super init]) {
        self.controller = controller;
    }
    return self;
}

- (BOOL)isWzone
{
    return YES;
}

- (void)setTitle:(NSString *)title
{
    self.controller.title = title;
}

@end
