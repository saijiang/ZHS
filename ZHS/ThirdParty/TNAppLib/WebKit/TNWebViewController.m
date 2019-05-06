//
//  TNWebViewController.m
//
//  Created by Heng Fan on 12-8-28.
//  Copyright (c) 2012年 Telenav. All rights reserved.
//

#import "TNWebViewController.h"
#import "TNFlowUtil.h"
#import "TNWzUrlParser.h"
#import "TNToast.h"
#import "NSString+TNAppLib.h"
#import "TNJSBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define APP_STORE_PROTOCAL_SCHEME @"itms-appss"
#define APP_STORE_HTTP_PREFIX @"http://itunes.apple.com/cn/app/"
#define HTTP_PROTOCAL_SCHEME @"http"
#define HTTPS_PROTOCAL_SCHEME @"https"

@interface TNWebViewController ()

@property (nonatomic, strong) NSString *initialUrl;
@property (nonatomic, strong) NSString *initialTitle;
@property (nonatomic) TNWebViewBackType backType;

@property (nonatomic, strong) TNJSBridge *bridge;

@end

@implementation TNWebViewController

- (void)prepareWithURL:(NSURL *)anURL title:(NSString *)title backType:(TNWebViewBackType)backType
{
    self.initialUrl = [self getFixedUrlString:anURL.absoluteString];
    self.initialTitle = title;

    self.backType = backType;
    switch (backType) {
        case TNWebViewBackTypeNone:
        {
            self.navigationItem.leftBarButtonItem = nil;
            break;
        }
        case TNWebViewBackTypeBack:
        {
            self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"navbar_back"];
            self.navigationItem.leftBarButtonItem.action = @selector(backButtonDidClick:);
            break;
        }
        case TNWebViewBackTypeSidebar:
        {
            self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"navbar_back"];
            self.navigationItem.leftBarButtonItem.action = @selector(leftSidebarButtonDidClick:);
            break;
        }
        default:
            break;
    }
    if (self.webView) {
        [self updateJSContext];
        
        if([_initialUrl hasPrefix:@"<html>"]) {
            [self.webView loadHTMLString:_initialUrl baseURL:nil];
        } else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_initialUrl]]];
        }
        self.title = self.initialTitle;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (NSString*)getFixedUrlString:(NSString*)urlString
{
    return urlString;
}

- (void)updateJSContext
{
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    if (!self.bridge) {
        self.bridge = [[TNJSBridge alloc] initWithViewController:self];
    }
    
    context[@"TNJSBridge"] = self.bridge;
}

#pragma mark - IBActions
- (IBAction)onBtnRefreshClicked:(id)sender
{
    [self.webView reload];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    LogDebug(@"webview webViewDidFinishLoad: request = %@", webView.request);
    if (self.navigationItem.title.length == 0) {
        self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self updateJSContext];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    LogDebug(@"webview didFailLoadWithError: request = %@ error = %@", webView.request, error);
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [TNToast showNetworkError];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    LogDebug(@"webview start load: request = %@, navigationType = %@", request, @(navigationType));
    if([TNWzUrlParser parseURL:request.URL withWebViewController:self]) {
        return NO;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL* url = request.URL;
    NSString* scheme = url.scheme;
    if((scheme && [scheme compare:APP_STORE_PROTOCAL_SCHEME] == NSOrderedSame) || [url.absoluteString hasPrefix:APP_STORE_HTTP_PREFIX]) {
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
        
    if(scheme && ([scheme compare:HTTP_PROTOCAL_SCHEME options:NSCaseInsensitiveSearch] == NSOrderedSame || [scheme compare:HTTPS_PROTOCAL_SCHEME options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
        return YES;
    }
    return NO;
}

@end
