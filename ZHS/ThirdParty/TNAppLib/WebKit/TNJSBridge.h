//
//  TNJSBridge.h
//  WeZone
//
//  Created by Frank on 14-9-16.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNAppJS.h"
#import "TNWebViewController.h"

@interface TNJSBridge : NSObject<TNAppJS>

@property (nonatomic, weak) TNWebViewController *controller;

- (id)initWithViewController:(TNWebViewController *)controller;

@end
