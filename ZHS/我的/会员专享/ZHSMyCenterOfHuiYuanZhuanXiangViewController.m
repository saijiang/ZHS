//
//  ZHSMyCenterOfHuiYuanZhuanXiangViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/7/7.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSMyCenterOfHuiYuanZhuanXiangViewController.h"
#import "ZHSMyCenterOfHuiYuanZhuanXiangDetailViewController.h"

@interface ZHSMyCenterOfHuiYuanZhuanXiangViewController ()

@end

@implementation ZHSMyCenterOfHuiYuanZhuanXiangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"会员专享";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tapClick:(id)sender {
    [self.navigationController pushViewController:[ZHSMyCenterOfHuiYuanZhuanXiangDetailViewController new] animated:YES];
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
