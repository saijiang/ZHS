//
//  ZHSMyCenterOfHuiYuanZhuanXiangDetailViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/7/8.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSMyCenterOfHuiYuanZhuanXiangDetailViewController.h"
#import "ZHSMyCenterOrderViewController.h"
#import "ZHSOrderEditAddressViewController.h"
@interface ZHSMyCenterOfHuiYuanZhuanXiangDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *numberLable;
@property (weak, nonatomic) IBOutlet UIImageView *subtractImage;
@property (weak, nonatomic) IBOutlet UIImageView *addimage;

@end

@implementation ZHSMyCenterOfHuiYuanZhuanXiangDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"商品";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)jifenPay:(id)sender {
    [self.navigationController pushViewController:[ZHSOrderEditAddressViewController new] animated:YES];

//    [self.navigationController pushViewController:[ZHSMyCenterOrderViewController new] animated:YES];
}
- (IBAction)yuanjiaPay:(id)sender {
    [self.navigationController pushViewController:[ZHSOrderEditAddressViewController new] animated:YES];
}
- (IBAction)doAdd:(id)sender {
    self.numberLable.text = [NSString stringWithFormat:@"%ld",(self.numberLable.text.integerValue + 1)];
    if (self.numberLable.text.integerValue > 1) {
        self.subtractImage.image = [UIImage imageNamed:@"subtract_enable_btn_bg"];
    }
}
- (IBAction)doSubtract:(id)sender {
    if (self.numberLable.text.integerValue > 1) {
        self.numberLable.text = [NSString stringWithFormat:@"%ld",(self.numberLable.text.integerValue - 1)];
    }else{
        self.subtractImage.image = [UIImage imageNamed:@"subtract_unable_btn_bg"];
    }
    
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
