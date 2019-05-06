
//
//  TNTabBarController.m
//  WeZone
//
//  Created by kiri on 2013-12-06.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNTabBarController.h"
#import "DWTabBar.h"

@interface TNTabBarController ()

@end

@implementation TNTabBarController
-(void)viewDidLoad{
    [super viewDidLoad];
    // 处理tabBar，使用自定义 tabBar 添加 发布按钮
    [self setUpTabBar];
    
//    [[UITabBar appearance] setBackgroundImage:[self imageWithColor:[UIColor whiteColor]]];
    
    //去除 TabBar 自带的顶部阴影
//    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
//    [[UITabBar appearance] setShadowImage:[UIImage imageNamed:@"navbar"]];

//    [[UITabBar appearance] setShadowImage:[UIImage imageNamed:@""]];
}
//- (BOOL)shouldAutorotate
//{
//    return self.wrappedSelectedViewController.shouldAutorotate;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return self.wrappedSelectedViewController.supportedInterfaceOrientations;
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return self.wrappedSelectedViewController.preferredStatusBarStyle;
//}
//
//- (BOOL)prefersStatusBarHidden
//{
//    return self.wrappedSelectedViewController.prefersStatusBarHidden;
//}
//
//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
//{
//    return self.wrappedSelectedViewController.preferredStatusBarUpdateAnimation;
//}
//
//- (UIViewController *)wrappedSelectedViewController
//{
//    UIViewController *vc = self.selectedViewController;
//    if (vc != nil && vc != self.moreNavigationController) {
//        return vc;
//    }
//    if (self.selectedIndex != NSNotFound && self.selectedIndex < self.viewControllers.count) {
//        return [self.viewControllers objectAtIndex:self.selectedIndex];
//    }
//    return nil;
//}

//- (void)_rebuildTabBarItemsAnimated:(BOOL)animated
//{
//}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    UIViewController *vc = [self.viewControllers objectAtIndex:selectedIndex];
    if ([self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)] && ![self.delegate tabBarController:self shouldSelectViewController:vc]) {
        return;
    }
    [self setSelectedViewController:vc];
    if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [self.delegate tabBarController:self didSelectViewController:vc];
    }
}

//这个方法可以抽取到 UIImage 的分类中
- (UIImage *)imageWithColor:(UIColor *)color
{
    NSParameterAssert(color != nil);
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
#pragma mark -
#pragma mark - Private Methods

/**
 *  利用 KVC 把 系统的 tabBar 类型改为自定义类型。
 */
- (void)setUpTabBar{
    
    [self setValue:[[DWTabBar alloc] init] forKey:@"tabBar"];
}

@end
