//
//  TNRootViewController.h
//  WeZone
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSUInteger TNSideViewPosition;

/**
 *  @class TNRootViewController
 *  It's a wrapper for the root window.
 */
@interface TNRootViewController : UIViewController

@property (nonatomic, weak) UIViewController *rootViewController;
- (void)setRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated;

@property (nonatomic) CGAffineTransform leftSidebarTransform;
@property (nonatomic, weak) UIViewController *leftSidebarViewController;
@property (nonatomic) BOOL leftSidebarHidden;
- (void)setLeftSidebarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic) CGAffineTransform rightSidebarTransform;
@property (nonatomic, weak) UIViewController *rightSidebarViewController;
@property (nonatomic) BOOL rightSidebarHidden;
- (void)setRightSidebarHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)setStatusBarHidden:(BOOL)hidden style:(UIStatusBarStyle)style withAnimation:(UIStatusBarAnimation)animation animationDuration:(NSTimeInterval)animationDuration;
- (void)resetStatusBarWithAnimated:(BOOL)animated animationDuration:(NSTimeInterval)animationDuration;

- (UIViewController *)shownSideViewController;
- (void)showSideViewController:(UIViewController *)viewController fromPosition:(TNSideViewPosition)position;
- (void)hideSideViewController;

@end