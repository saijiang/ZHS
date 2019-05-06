//
//  ZHSFindYourTeacherViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/3/9.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSFindYourTeacherViewController.h"
#import "ZHSUserOfBaoBaoInformationViewController.h"
#import "ZHSMyInfoXingQuViewController.h"
#import "ZHSMyCenterViewController.h"

@interface ZHSFindYourTeacherViewController ()
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UITextField *teacherPhoneTF;

@end

@implementation ZHSFindYourTeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (_isCanBack) {
        [self createLeftBarItemWithImage];
    }else{
        [self createLeftBarItemWithTitle:@""];
        self.fd_interactivePopDisabled = YES;
    }
    self.navigationItem.title = @"找到您的老师";
    self.phoneView.layer.cornerRadius = 5;
    if (!([self.navigationController.viewControllers containsObjectClass:[ZHSHomeViewController class]] ||[self.navigationController.viewControllers containsObjectClass:[ZHSMyCenterViewController class]] )) {
        [self createRightBarItemWithTitle:@"跳过"font:12];
    }
}
-(void)clickRightSender:(UIButton *)sender{
    TNBlockAlertView * block = [[TNBlockAlertView alloc]initWithTitle:nil message:@"加入宝宝班级享更多特权，您也可以随便看看！" delegate:self cancelButtonTitle:@"加入班级" otherButtonTitles:@"继续体验", nil];
    __weak typeof(self)tempSelf = self;
    [block setBlockForOk:^{
        [tempSelf.navigationController pushViewController:[ZHSMyInfoXingQuViewController new] animated:YES];

    }];
    [block setBlockForCancel:^{
//        [tempSelf.navigationController pushViewController:[ZHSMyInfoXingQuViewController new] animated:YES];

    }];
    [block show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nextBtnClick:(id)sender {
    if (self.teacherPhoneTF.text.length) {
        NSString *path = [NSString stringWithFormat:@"%@/get-school-class",kHeaderURL];
        NSMutableDictionary *prams = [@{} mutableCopy];
        [prams setValue:self.teacherPhoneTF.text forKey:@"mobile"];
        __weak typeof(self)tempself = self;
        [[THRequstManager sharedManager] asynPOST:path parameters:prams withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            if (code == 1) {
                NSDictionary *objc = responseObject[@"data"];
                ZHSUserOfBaoBaoInformationViewController *vc = [ZHSUserOfBaoBaoInformationViewController new];
                vc.school_info = objc[@"school_info"];
                vc.school_class_info =objc[@"school_class_info"];
                [tempself.navigationController pushViewController:vc animated:YES];
            }
            [TNToast showWithText:responseObject[@"message"]];
        }];
    }else{
        [TNToast showWithText:@"请输入手机号码"];
    }
}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
}
-(void)back{
    if (_isCanBack) {
        [self.navigationController popViewControllerAnimated:YES];
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
