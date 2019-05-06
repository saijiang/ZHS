//
//  TNWzUrlParse.h
//  WeZone
//
//  Created by Mr.Wang(Wang Zhao) on 14-1-6.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNWebViewController.h"

@interface TNWzUrlParser : NSObject

/*!
 * 只处理WZ协议的URL
 */
+ (BOOL)parseURL:(NSURL *)anURL withWebViewController:(TNWebViewController *)webViewController;

@end
