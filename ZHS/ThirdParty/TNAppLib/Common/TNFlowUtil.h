//
//  TNFlowUtil.h
//  Tuhu
//
//  Created by DengQiang on 14/10/23.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNWebViewController.h"
#import "TNResponse.h"
#import "ZHSHomeViewController.h"
@class ZHSMyCenterViewController;
@class ZHSSchoolbagViewController;

@interface TNFlowUtil : NSObject
#pragma mark - Util
+ (UIViewController *)visibleViewController;
+ (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController;
+ (void)handleMainFlowWillLoadWithCompletion:(void (^)(void))completion;

#pragma mark - Common
+ (BOOL)startPhotoPickerWithPresentingViewController:(UIViewController *)presentingViewController defaultToFrontCamera:(BOOL)defaultToFrontCamera animated:(BOOL)animated completion:(void (^)(UIImagePickerController *picker,BOOL isCancel, UIImage *image))completion;
+ (BOOL)startPhotoPickerWithPresentingViewController:(UIViewController *)presentingViewController defaultToFrontCamera:(BOOL)defaultToFrontCamera animated:(BOOL)animated completionWithMediaInfo:(void (^)(UIImagePickerController *picker,BOOL isCancel, NSDictionary *mediaInfo))completion;
+ (BOOL)startAlbumPickerWithPresentingViewController:(UIViewController *)presentingViewController animated:(BOOL)animated completion:(void (^)(UIImagePickerController *picker, BOOL isCancel, UIImage *image))completion;


+ (void)showGuideWithView:(UIView *)guideView token:(NSString *)token;
+ (void)showGuideWithView:(UIView *)guideView maxCount:(int)maxCount token:(NSString *)token tapToHide:(BOOL)tapToHide;

#pragma mark - WebView
//+ (void)startWebViewFromSidebarWithURL:(NSURL *)url title:(NSString*)title position:(t)position;
+ (void)startWebViewWithURL:(NSURL *)url title:(NSString*)title backType:(TNWebViewBackType)backType navigationController:(UINavigationController*)navigationController animated:(BOOL)animated;
+ (void)presentWebViewWithURL:(NSURL *)url title:(NSString *)title presentingViewController:(UIViewController *)presentingViewController animated:(BOOL)animated;

#pragma mark - Flow
+ (void)startApplicationEntry;
+ (void)handleSplashDidLoad;
+ (void)startMainFlow;
+ (ZHSMyCenterViewController *)startPersonCenter;
+ (ZHSSchoolbagViewController *)startGoSchoolbag;
+ (ZHSHomeViewController *)startGoHome;

#pragma mark - Alert
+ (void)showNetworkErrorWithResponse:(TNResponse *)response;
+ (void)showNetworkErrorWithResponse:(TNResponse *)response retryBlock:(void (^)(void))retryBlock;
+ (void)showNetworkErrorWithResponse:(TNResponse *)response retryBlock:(void (^)(void))retryBlock cancelBlock:(void (^)(void))cancelBlock;

#pragma mark - Car

#pragma mark - Login
+ (void)presentLoginWithCompletion:(void (^)(UIViewController *vc))completion presentingViewController:(UIViewController *)presentingViewController animated:(BOOL)animated;

#pragma mark - Settings
+ (void)startAboutWithNavigationController:(UINavigationController *)nav animated:(BOOL)animated;
@end
