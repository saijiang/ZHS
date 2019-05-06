//
//  TNNavigationController.m
//  WeZone
//
//  Created by kiri on 2013-10-16.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNNavigationController.h"

@interface TNNavigationController ()

@property (nonatomic, strong) UIImageView *leftBadgeView;
@property (nonatomic, strong) UIImageView *rightBadgeView;

@end

@implementation TNNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.leftBadgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_badge_right"]];
    self.leftBadgeView.frame = CGRectMake(25, 5, 15, 15);
    self.leftBadgeViewHidden = YES;
    [self.navigationBar addSubview:self.leftBadgeView];
    
    self.rightBadgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_badge_right"]];
    self.rightBadgeView.frame = CGRectMake(299, 5, 15, 15);
    self.rightBadgeViewHidden = YES;
    [self.navigationBar addSubview:self.rightBadgeView];
    
}

- (void)setLeftBadgeViewHidden:(BOOL)leftBadgeViewHidden
{
    self.leftBadgeView.hidden = leftBadgeViewHidden;
    [self.navigationBar bringSubviewToFront:self.leftBadgeView];
}

- (void)setRightBadgeViewHidden:(BOOL)rightBadgeViewHidden
{
    self.rightBadgeView.hidden = rightBadgeViewHidden;
    [self.navigationBar bringSubviewToFront:self.rightBadgeView];
}

- (BOOL)leftBadgeViewHidden
{
    return self.leftBadgeView.hidden;
}

- (BOOL)rightBadgeViewHidden
{
    return self.rightBadgeView.hidden;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return self.topViewController ? self.topViewController.shouldAutorotate : [super shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController ? self.topViewController.supportedInterfaceOrientations : [super supportedInterfaceOrientations];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.topViewController ? self.topViewController.preferredStatusBarStyle : [super preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return self.topViewController ? self.topViewController.prefersStatusBarHidden : [super prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return self.topViewController ? self.topViewController.preferredStatusBarUpdateAnimation : [super preferredStatusBarUpdateAnimation];
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:YES];
}


@end
