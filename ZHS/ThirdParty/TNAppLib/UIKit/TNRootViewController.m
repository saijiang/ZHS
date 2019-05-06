//
//  TNRootViewController.m
//  WeZone
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNRootViewController.h"
#import "TNViewUtil.h"
#import "TNSidebar.h"
#import "UIDevice+TNAppLib.h"
#import "TNAppLibMacros.h"
#import "UIView+TNAppLib.h"
#import "TNApplication.h"

@interface TNRootViewController ()
{
    BOOL sidebarAnimating;
}

//记录最后一次选中的Tab
@property (nonatomic, weak) UINavigationController *lastSelectedTab;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *statusBarMaskView;

@property (nonatomic) NSInteger forcedStatusBarStyle;
@property (nonatomic) NSInteger forcedStatusBarHidden;
@property (nonatomic) NSInteger forcedStatusBarAnimation;

@property (nonatomic) TNSideViewPosition shownSideViewPosition;
@property (nonatomic, weak) UIViewController *shownSideViewController;

@end

@implementation TNRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _leftSidebarHidden = YES;
    _rightSidebarHidden = YES;
    _leftSidebarTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.7, 0.7), CGAffineTransformMakeTranslation(180, 0));
    _rightSidebarTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.7, 0.7), CGAffineTransformMakeTranslation(-180, 0));
    _forcedStatusBarHidden = TNApplicationStatusBarHiddenNone;
    _forcedStatusBarStyle = TNApplicationStatusBarStyleNone;
    _forcedStatusBarAnimation = TNApplicationStatusBarAnimationNone;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setStatusBarHidden:(BOOL)hidden style:(UIStatusBarStyle)style withAnimation:(UIStatusBarAnimation)animation animationDuration:(NSTimeInterval)animationDuration
{
    self.forcedStatusBarHidden = hidden;
    self.forcedStatusBarStyle = style;
    self.forcedStatusBarAnimation = animation;
    
    if (animation == UIStatusBarAnimationNone) {
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:nil];
    }
}

- (void)resetStatusBarWithAnimated:(BOOL)animated animationDuration:(NSTimeInterval)animationDuration
{
    self.forcedStatusBarHidden = TNApplicationStatusBarHiddenNone;
    self.forcedStatusBarStyle = TNApplicationStatusBarStyleNone;
    self.forcedStatusBarAnimation = TNApplicationStatusBarAnimationNone;
    
    if (animated) {
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:nil];
    } else {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.forcedStatusBarStyle == TNApplicationStatusBarStyleNone) {
        if ([super respondsToSelector:@selector(preferredStatusBarStyle)]) {
            if (!self.leftSidebarHidden) {
                return self.leftSidebarViewController.preferredStatusBarStyle;
            }
            return self.presentedViewController ? self.presentedViewController.preferredStatusBarStyle : self.rootViewController ? self.rootViewController.preferredStatusBarStyle : UIStatusBarStyleDefault;
        } else {
            return UIStatusBarStyleDefault;
        }
    } else {
        return self.forcedStatusBarStyle;
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (self.forcedStatusBarHidden == TNApplicationStatusBarHiddenNone) {
        if ([super respondsToSelector:@selector(prefersStatusBarHidden)]) {
            if (!self.leftSidebarHidden) {
                return self.leftSidebarViewController.prefersStatusBarHidden;
            }
            return self.presentedViewController ? self.presentedViewController.prefersStatusBarHidden : self.rootViewController ? self.rootViewController.prefersStatusBarHidden : NO;
        } else {
            return NO;
        }
    } else {
        return self.forcedStatusBarHidden;
    }
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    if (self.forcedStatusBarAnimation == TNApplicationStatusBarAnimationNone) {
        if ([super respondsToSelector:@selector(preferredStatusBarUpdateAnimation)]) {
            return self.presentedViewController ? self.presentedViewController.preferredStatusBarUpdateAnimation : self.rootViewController ? self.rootViewController.preferredStatusBarUpdateAnimation : UIStatusBarAnimationSlide;
        } else {
            return UIStatusBarAnimationSlide;
        }
    } else {
        return self.forcedStatusBarAnimation;
    }
}

- (void)setNeedsStatusBarAppearanceUpdate
{
    if ([super respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [super setNeedsStatusBarAppearanceUpdate];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:self.preferredStatusBarStyle animated:self.preferredStatusBarUpdateAnimation != UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarHidden:self.prefersStatusBarHidden withAnimation:self.preferredStatusBarUpdateAnimation];
    }
}

- (void)setRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated
{
    if (_rootViewController != rootViewController) {
        // clear window
        UIWindow *window = self.view.window;
        NSMutableArray *subviews = [window.subviews mutableCopy];
        [subviews removeObject:self.view];
        [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // change root
        UIViewController *currentRoot = _rootViewController;
        UIViewController *newRoot = rootViewController;
        
        _rootViewController = rootViewController;
        if (newRoot) {
            newRoot.view.frame = self.view.bounds;
            
            [self addChildViewController:newRoot];
         
            if (currentRoot) {
                if (animated) {
                    window.userInteractionEnabled = NO;
                    [self.view insertSubview:newRoot.view belowSubview:currentRoot.view];
                    self.forcedStatusBarAnimation = UIStatusBarAnimationFade;
                    [UIView animateWithDuration:TNAnimateDurationNormal delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        currentRoot.view.alpha = 0.f;
//                        currentRoot.view.transform = CGAffineTransformMakeScale(3.0, 3.0);
                        [self setNeedsStatusBarAppearanceUpdate];
                    } completion:^(BOOL finished) {
                        [currentRoot.view removeFromSuperview];
                        [currentRoot removeFromParentViewController];
                        window.userInteractionEnabled = YES;
                        self.forcedStatusBarAnimation = TNApplicationStatusBarAnimationNone;
                    }];
                } else {
                    [currentRoot.view removeFromSuperview];
                    [currentRoot removeFromParentViewController];
                    [self.view addSubview:newRoot.view];
                }
            } else {
                [self.view addSubview:newRoot.view];
            }
        }
    }
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
    [self setRootViewController:rootViewController animated:NO];
}

- (void)addChildViewController:(UIViewController *)childController
{
    [super addChildViewController:childController];
    childController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self adjustChildPostion:childController];
}

- (void)updateStatusBarStyle
{
    if ([[UIDevice currentDevice] majorSystemVersion] < 7) {
        [[UIApplication sharedApplication] setStatusBarStyle:self.preferredStatusBarStyle animated:YES];
    } else {
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
}

- (void)adjustAllChildrenPostion
{
    for (UIViewController *vc in self.childViewControllers) {
        [self adjustChildPostion:vc];
    }
}

- (void)adjustChildPostion:(UIViewController *)childController
{
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.rootViewController.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate
{
    return self.rootViewController.shouldAutorotate;
}

#pragma mark - Sidebars
- (void)setLeftSidebarViewController:(UIViewController *)leftSidebarViewController
{
    if (_leftSidebarViewController != leftSidebarViewController) {
        if (_leftSidebarViewController) {
            [_leftSidebarViewController.view removeFromSuperview];
            [_leftSidebarViewController removeFromParentViewController];
        }
        
        _leftSidebarViewController = leftSidebarViewController;
        
        [self addChildViewController:_leftSidebarViewController];
        [self.view insertSubview:_leftSidebarViewController.view atIndex:0];
        _leftSidebarViewController.view.hidden = self.leftSidebarHidden;
    }
}

- (void)setLeftSidebarHidden:(BOOL)leftSidebarHidden
{
    [self setLeftSidebarHidden:leftSidebarHidden animated:NO];
}

- (void)setLeftSidebarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self setLeftSidebarHidden:hidden animated:animated maskStatusBar:NO];
}

- (void)setLeftSidebarHidden:(BOOL)hidden animated:(BOOL)animated maskStatusBar:(BOOL)maskStatusBar
{
    if (self.leftSidebarViewController == nil) {
        return;
    }
    
    if (hidden == _leftSidebarHidden) {
        return;
    }
    
    if (sidebarAnimating) {
        return;
    }
    
    sidebarAnimating = YES;
    if (self.rightSidebarViewController.view.superview == self.view) {
        [self.view sendSubviewToBack:self.rightSidebarViewController.view];
    }
    
    BasicBlock preparation = nil;
    BasicBlock animation = nil;
    BasicBlock completion = nil;
    
    BasicBlock commonPreparation = ^{
        if (hidden) {
            if ([self.leftSidebarViewController respondsToSelector:@selector(sidebarWillDisappear:)]) {
                [(id<TNSidebar>)self.leftSidebarViewController sidebarWillDisappear:animated];
            }
            self.rootViewController.view.layer.cornerRadius = 0.f;
            self.rootViewController.view.layer.masksToBounds = NO;
        } else {
            if ([self.leftSidebarViewController respondsToSelector:@selector(sidebarWillAppear:)]) {
                [(id<TNSidebar>)self.leftSidebarViewController sidebarWillAppear:animated];
            }
            self.rootViewController.view.layer.cornerRadius = 4.f;
            self.rootViewController.view.layer.masksToBounds = YES;
        }
    };
    
    BasicBlock commonCompletion = ^{
        sidebarAnimating = NO;
        _leftSidebarHidden = hidden;
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
        
        if (!hidden && [self.leftSidebarViewController respondsToSelector:@selector(sidebarDidAppear:)]) {
            [(id<TNSidebar>)self.leftSidebarViewController sidebarDidAppear:animated];
        } else if (hidden && [self.leftSidebarViewController respondsToSelector:@selector(sidebarDidDisappear:)]) {
            [(id<TNSidebar>)self.leftSidebarViewController sidebarDidDisappear:animated];
        }
    };
    
    if (hidden) {
        animation = ^{
            self.maskView.alpha = 0.f;
            CGAffineTransform trans = CGAffineTransformIdentity;
            self.maskView.transform = trans;
            self.rootViewController.view.transform = trans;
        };
        
        completion = ^{
            self.maskView.hidden = YES;
            self.leftSidebarViewController.view.hidden = YES;
        };
    } else {
        preparation = ^{
            if (maskStatusBar) {
                self.statusBarMaskView.backgroundColor = self.leftSidebarViewController.view.backgroundColor;
            }
            self.maskView.alpha = 0.f;
            self.maskView.hidden = NO;
            self.leftSidebarViewController.view.hidden = NO;
            [self.view bringSubviewToFront:self.maskView];
        };
        
        animation = ^{
            self.maskView.alpha = 1.f;
            CGAffineTransform trans = self.leftSidebarTransform;
            self.maskView.transform = trans;
            self.rootViewController.view.transform = trans;
        };
    }
    
    commonPreparation();
    
    if (preparation != nil) {
        preparation();
    }
    
    if (animated && animation) {
        [UIView animateWithDuration:TNAnimateDurationNormal delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:^(BOOL finished) {
            commonCompletion();
            
            if (completion) {
                completion();
            }
        }];
    } else {
        if (animation) {
            animation();
        }
        
        commonCompletion();
        
        if (completion) {
            completion();
        }
    }
}

- (void)setRightSidebarViewController:(UIViewController *)rightSidebarViewController
{
    if (_rightSidebarViewController != rightSidebarViewController) {
        if (_rightSidebarViewController) {
            [_rightSidebarViewController.view removeFromSuperview];
            [_rightSidebarViewController removeFromParentViewController];
        }
        
        _rightSidebarViewController = rightSidebarViewController;
        
        [self addChildViewController:_rightSidebarViewController];
        [self.view insertSubview:_rightSidebarViewController.view atIndex:0];
        _rightSidebarViewController.view.hidden = self.rightSidebarHidden;
    }
}

- (void)setRightSidebarHidden:(BOOL)rightSidebarHidden
{
    [self setRightSidebarHidden:rightSidebarHidden animated:NO];
}

- (void)setRightSidebarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self setRightSidebarHidden:hidden animated:animated maskStatusBar:NO];
}

- (void)setRightSidebarHidden:(BOOL)hidden animated:(BOOL)animated maskStatusBar:(BOOL)maskStatusBar
{
    if (self.rightSidebarViewController == nil) {
        return;
    }
    
    if (hidden == _rightSidebarHidden) {
        return;
    }
    
    if (sidebarAnimating) {
        return;
    }
    
    sidebarAnimating = YES;
    
    if (self.leftSidebarViewController.view.superview == self.view) {
        [self.view sendSubviewToBack:self.leftSidebarViewController.view];
    }
    
    BasicBlock preparation = nil;
    BasicBlock animation = nil;
    BasicBlock completion = nil;
    
    BasicBlock commonPreparation = ^{
        if (!hidden && [self.rightSidebarViewController respondsToSelector:@selector(sidebarWillAppear:)]) {
            [(id<TNSidebar>)self.rightSidebarViewController sidebarWillAppear:animated];
        } else if (hidden && [self.rightSidebarViewController respondsToSelector:@selector(sidebarWillDisappear:)]) {
            [(id<TNSidebar>)self.rightSidebarViewController sidebarWillDisappear:animated];
        }
    };
    
    BasicBlock commonCompletion = ^{
        sidebarAnimating = NO;
        _rightSidebarHidden = hidden;
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
        
        if (!hidden && [self.rightSidebarViewController respondsToSelector:@selector(sidebarDidAppear:)]) {
            [(id<TNSidebar>)self.rightSidebarViewController sidebarDidAppear:animated];
        } else if (hidden && [self.rightSidebarViewController respondsToSelector:@selector(sidebarDidDisappear:)]) {
            [(id<TNSidebar>)self.rightSidebarViewController sidebarDidDisappear:animated];
        }
    };
    
    if (hidden) {
        animation = ^{
            self.maskView.alpha = 0.f;
            self.maskView.transform = CGAffineTransformIdentity;
            self.rootViewController.view.transform = CGAffineTransformIdentity;
        };
        
        completion = ^{
            self.maskView.hidden = YES;
            self.rightSidebarViewController.view.hidden = YES;
        };
    } else {
        preparation = ^{
            if (maskStatusBar) {
                self.statusBarMaskView.backgroundColor = self.rightSidebarViewController.view.backgroundColor;
            }
            self.maskView.alpha = 0.f;
            self.maskView.hidden = NO;
            self.rightSidebarViewController.view.hidden = NO;
            [self.view bringSubviewToFront:self.maskView];
        };
        
        animation = ^{
            self.maskView.alpha = 1.f;
            self.maskView.transform = self.rightSidebarTransform;
            self.rootViewController.view.transform = self.rightSidebarTransform;
        };
    }
    
    commonPreparation();
    
    if (preparation != nil) {
        preparation();
    }
    
    if (animated && animation) {
        [UIView animateWithDuration:TNAnimateDurationShort delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:^(BOOL finished) {
            
            commonCompletion();
            
            if (completion) {
                completion();
            }
        }];
    } else {
        if (animation) {
            animation();
        }
        
        commonCompletion();
        
        if (completion) {
            completion();
        }
    }
}

- (IBAction)didTapMaskView:(id)sender {
    [self setLeftSidebarHidden:YES animated:YES];
    [self setRightSidebarHidden:YES animated:YES];
}

- (void)showSideViewController:(UIViewController *)viewController fromPosition:(TNSideViewPosition)position
{
    if (viewController == self.shownSideViewController) {
        return;
    }
    
    [self addChildViewController:viewController];
    CGFloat moveDistance = position == TNSideViewPositionLeft ? viewController.view.width : - viewController.view.width;
    viewController.view.left = position == TNSideViewPositionLeft ? -viewController.view.width : self.view.width;
    [self.view addSubview:viewController.view];
    
    BOOL isMove = self.shownSideViewController == nil;
    [UIView animateWithDuration:TNAnimateDurationShort delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        viewController.view.left = 0;
        if (isMove) {
            self.rootViewController.view.left += moveDistance;
            self.leftSidebarViewController.view.left += moveDistance / 2;
            self.rightSidebarViewController.view.left += moveDistance / 2;
        }
        if (self.shownSideViewController) {
            self.shownSideViewController.view.left += moveDistance;
        }
    } completion:^(BOOL finished) {
        if (self.shownSideViewController) {
            [self hideSideViewControllerAnimated:NO];
        }
        
        self.shownSideViewController = viewController;
        self.shownSideViewPosition = position;
    }];
}

- (void)hideSideViewController
{
    [self hideSideViewControllerAnimated:YES];
}

- (void)hideSideViewControllerAnimated:(BOOL)animated
{
    if (self.shownSideViewController == nil) {
        return;
    }
    
    void (^animation)(void) = ^{
        self.shownSideViewController.view.left = self.shownSideViewPosition == TNSideViewPositionLeft ? -self.shownSideViewController.view.width : self.view.width;
        CGFloat moveDistance = self.shownSideViewPosition == TNSideViewPositionLeft ? -self.shownSideViewController.view.width : self.shownSideViewController.view.width;
        
        self.rootViewController.view.left += moveDistance;
        self.leftSidebarViewController.view.left += moveDistance / 2;
        self.rightSidebarViewController.view.left += moveDistance / 2;
    };
    
    void (^completion)(void) = ^{
        [self.shownSideViewController.view removeFromSuperview];
        [self.shownSideViewController removeFromParentViewController];
        self.shownSideViewController = nil;
    };
    
    if (animated) {
        [UIView animateWithDuration:TNAnimateDurationShort delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:^(BOOL finished) {
            completion();
        }];
    } else {
        animation();
        completion();
    }
}

@end
