//
//  TNToast.h
//  WeZone
//
//  Created by kiri on 2013-11-20.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNToast : NSObject

@property (nonatomic) BOOL blockUserInteraction;
@property (nonatomic) CGSize contentSize;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, readonly, strong) UIView *view;

- (void)show;
- (void)hide;

+ (id)toastWithText:(NSString *)text;
+ (id)toastWithText:(NSString *)text duration:(NSTimeInterval)duration blockUserInteraction:(BOOL)blockUserInteraction;

+ (void)showLoadingToast;
+ (void)showLoadingToastWithTransparentBackground;
+ (void)showLoadingToastWithStyle:(UIActivityIndicatorViewStyle)style blockUserInteraction:(BOOL)blockUserInteraction;
+ (void)showLoadingToastWithText:(NSString *)text;
+ (void)hideLoadingToast;

+ (void)showNetworkError;
+ (void)showWithText:(NSString *)text;
+ (void)showWithText:(NSString *)text duration:(NSTimeInterval)duration;
+ (void)showWithText:(NSString *)text duration:(NSTimeInterval)duration blockUserInteraction:(BOOL)blockUserInteraction;

@end