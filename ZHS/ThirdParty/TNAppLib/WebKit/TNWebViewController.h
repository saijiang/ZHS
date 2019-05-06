//
//  TNWebViewController.h
//  TTXClient
//
//  Created by Heng Fan on 12-8-28.
//  Copyright (c) 2012年 Telenav. All rights reserved.
//

#import "TNViewController.h"

typedef NS_ENUM(NSUInteger, TNWebViewBackType) {
    TNWebViewBackTypeNone,
    TNWebViewBackTypeBack,
    TNWebViewBackTypeSidebar,
};

@interface TNWebViewController : TNViewController <UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *webView;

- (void)prepareWithURL:(NSURL *)anURL title:(NSString*)title backType:(TNWebViewBackType)backType;

@end
