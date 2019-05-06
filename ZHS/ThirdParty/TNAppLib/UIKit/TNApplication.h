//
//  TNApplication.h
//  WeZone
//
//  Created by DengQiang on 14-6-30.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TNHomeViewController;

typedef NS_ENUM(NSUInteger, TNApplicationLaunchType) {
    TNApplicationLaunchTypeUnknown,
    TNApplicationLaunchTypeNormal,
    TNApplicationLaunchTypeRemoteNotification,
    TNApplicationLaunchTypeLocalNotification,
    TNApplicationLaunchTypeOpenURL,
};

enum {
    TNApplicationStatusBarHiddenNone = -1,
};

enum {
    TNApplicationStatusBarStyleNone = -1,
};

enum {
    TNApplicationStatusBarAnimationNone = -1,
};

enum {
    TNSideViewPositionLeft,
    TNSideViewPositionRight,
};
typedef NSUInteger TNSideViewPosition;

typedef NSUInteger TNRetryTaskIdentifier;

@interface TNApplication : NSObject

+ (TNApplication *)sharedApplication;

@property (nonatomic, strong) NSDictionary *launchOptions;
@property (nonatomic) TNApplicationLaunchType launchType;

@property (nonatomic, strong, readonly) NSDate *launchTime;
@property (nonatomic, strong, readonly) NSDate *lastActiveTime;
@property (nonatomic, strong, readonly) NSDate *lastDeactiveTime;

- (CGFloat)keyboardTop;

- (void)startWithLaunchOptions:(NSDictionary *)launchOptions;

#pragma mark - Sidebar
- (UIViewController *)leftSidebarViewController;
- (void)setLeftSidebarViewController:(UIViewController *)leftSidebarViewController;
- (void)setLeftSidebarHidden:(BOOL)hidden animated:(BOOL)animated;
- (BOOL)isLeftSidebarHidden;

- (UIViewController *)rightSidebarViewController;
- (void)setRightSidebarViewController:(UIViewController *)rightSidebarViewController;
- (void)setRightSidebarHidden:(BOOL)hidden animated:(BOOL)animated;
- (BOOL)isRightSidebarHidden;

- (UIViewController *)shownSideViewController;
- (void)showSideViewController:(UIViewController *)viewController fromPosition:(TNSideViewPosition)position;
- (void)hideSideViewController;

#pragma mark - Root
- (id)rootViewController;
- (void)setRootViewController:(UIViewController *)controller animated:(BOOL)animated;

#pragma mark - Statusbar
- (void)setStatusBarHidden:(BOOL)hidden style:(UIStatusBarStyle)style withAnimation:(UIStatusBarAnimation)animation animationDuration:(NSTimeInterval)animationDuration;
- (void)resetStatusBarWithAnimated:(BOOL)animated animationDuration:(NSTimeInterval)animationDuration;
- (void)refreshStatusBar;

#pragma mark - Utils
- (BOOL)openURL:(NSURL *)url;
- (void)callPhoneNumber:(NSString *)phoneNumber;

@end
