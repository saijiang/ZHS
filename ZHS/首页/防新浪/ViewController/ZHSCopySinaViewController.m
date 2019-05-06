//
//  ZHSCopySinaViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/4/13.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSCopySinaViewController.h"
#import "ZHSMyYiJianJieYueViewController.h"
#import "TNRootViewController.h"
#import "ZHSHomeOfChildMusicViewController.h"
#import "AppDelegate.h"

@interface ZHSCopySinaViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yuetingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jieyueConstraint;
@end

@implementation ZHSCopySinaViewController
- (IBAction)colse:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)yijianyueting:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:^{
        UITabBarController *tabBarController = (UITabBarController*)((TNRootViewController *)[(AppDelegate*)[UIApplication sharedApplication].delegate window].rootViewController).rootViewController;
        UIViewController *viewController = ((UINavigationController*)tabBarController.selectedViewController).visibleViewController;
        ZHSHomeOfChildMusicViewController *vc = [ZHSHomeOfChildMusicViewController new];
        [viewController.navigationController pushViewController:vc animated:YES];
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:15.0f animations:^{
        self.yuetingConstraint.constant = 80;
        self.jieyueConstraint.constant = 80;
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)yijianjieyue:(id)sender {
//    __weak typeof(self)tempSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        ;
        UITabBarController *tabBarController = (UITabBarController*)((TNRootViewController *)[(AppDelegate*)[UIApplication sharedApplication].delegate window].rootViewController).rootViewController;
        UIViewController *viewController = ((UINavigationController*)tabBarController.selectedViewController).visibleViewController;
        [viewController.navigationController pushViewController:[ZHSMyYiJianJieYueViewController new] animated:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
