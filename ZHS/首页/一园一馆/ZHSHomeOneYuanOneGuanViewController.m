//
//  ZHSHomeOneYuanOneGuanViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/1.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSHomeOneYuanOneGuanViewController.h"
#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式
#import "ZHSYYYGPostDataViewController.h"

@interface ZHSHomeOneYuanOneGuanViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tiaojianL;


@end

@implementation ZHSHomeOneYuanOneGuanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"一园一馆";
    self.tiaojianL.text = @"1、幼儿园经营良好，短期内不会发生经营变化。\n2、申请者必须是幼儿园负责人、法人、园长或其他。\n3、申请者必须保证所提供的信息均为真实信息。";
}


- (IBAction)woshiyaunzhang:(id)sender {
    ZHSYYYGPostDataViewController *vc = [ZHSYYYGPostDataViewController new];
    vc.isFrom = @"园长申请";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)woshijiazhang:(id)sender {
    ZHSYYYGPostDataViewController *vc = [ZHSYYYGPostDataViewController new];
    vc.isFrom = @"家长推荐";
    [self.navigationController pushViewController:vc animated:YES];
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
