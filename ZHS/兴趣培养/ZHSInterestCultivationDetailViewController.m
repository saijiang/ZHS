//
//  ZHSInterestCultivationDetailViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/7/14.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSInterestCultivationDetailViewController.h"

@interface ZHSInterestCultivationDetailViewController ()

@end

@implementation ZHSInterestCultivationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"兴趣培养";
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
