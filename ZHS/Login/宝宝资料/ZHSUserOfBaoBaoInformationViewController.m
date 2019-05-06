//
//  ZHSUserOfBaoBaoInformationViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/2.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSUserOfBaoBaoInformationViewController.h"
#import "ZHSCitysViewController.h"
#import "ZHSMyInfoXingQuViewController.h"
#import "MMLineBorderButton.h"
#import "ZHSMyInfoViewController.h"
@interface ZHSUserOfBaoBaoInformationViewController ()<UITextFieldDelegate,MMNavigationControllerNotificationDelegate>
{
   __block NSNumber * _school_class_id;
    NSInteger sex;
}
@property (weak, nonatomic) IBOutlet UIView *diview;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UILabel *age;
@property (weak, nonatomic) IBOutlet UILabel *kindergarten;
@property (weak, nonatomic) IBOutlet UITextField *baobaoSex;



@property (strong, nonatomic) IBOutlet UIView *datePickerContantView;
@property (weak, nonatomic)   IBOutlet UIButton *cancel;
@property (weak, nonatomic)  IBOutlet UIButton *Yes;
@property (weak, nonatomic) IBOutlet UIDatePicker *datepiker;
@property (weak, nonatomic) IBOutlet UIView *youeryuanInfoView;
@property (weak, nonatomic) IBOutlet MMLineBorderButton *nextBTN;
@end

@implementation ZHSUserOfBaoBaoInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_interactivePopDisabled = YES;

    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
//    [self createRightBarItemWithTitle:@"跳过" font:12];

    self.diview.layer.cornerRadius = 5.0f;
    self.youeryuanInfoView.layer.cornerRadius = 5.0f;
    self.navigationItem.title = @"完善宝宝资料";
    self.datePickerContantView.frame = CGRectMake(0, kHight, kWidth, 240);
    [self.view addSubview:self.datePickerContantView];
    if (_school_info[@"name"] && _school_class_info[@"name"]) {
        self.kindergarten.text = [NSString stringWithFormat:@"%@%@",_school_info[@"name"],_school_class_info[@"name"]];
    }
    _school_class_id =_school_class_info[@"id"];
    if ([self.navigationController.viewControllers containsObjectClass:[ZHSHomeViewController class]] ||[self.navigationController.viewControllers containsObjectClass:[ZHSMyInfoViewController class]]) {
        [self.nextBTN setTitle:@"完成" forState:UIControlStateNormal];
    }
}

- (IBAction)nextBTNClick:(UIButton *)sender {
    if (_name.text.length && _age.text.length ) {
       
        __weak typeof(self)tempSelf = self;
        NSMutableDictionary *prams = [@{} mutableCopy];
        NSMutableDictionary *prams1 = [@{} mutableCopy];
        [prams1 setValue:self.name.text forKey:@"name"];
        [prams1 setValue:self.age.text forKey:@"birthday"];
        [prams1 setValue:sex?@"female":@"male" forKey:@"gender"];
        [prams setValue:prams1 forKey:@"baby"];
        if (_school_class_id) {
            [prams setValue:_school_class_id forKey:@"school_class_id"];
        }
        
        [[THRequstManager sharedManager] asynPOST:[NSString stringWithFormat:@"%@/customer/update",kHeaderURL] parameters:prams withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
                if (code == 1) {
                    TNUser *user = [TNUser modelWithJsonDicWithoutMap:responseObject[@"data"]];
                    user.token = [TNAppContext currentContext].user.token;
                    user.ID = [TNAppContext currentContext].user.ID;
                    [TNAppContext currentContext].user = user;
                    [[TNAppContext currentContext] saveUser];
                    if ([self.nextBTN.currentTitle isEqualToString:@"完成"]) {
                        NSUserDefaults* ud=[NSUserDefaults standardUserDefaults];
                        [ud setBool:YES forKey:@"home"];
                        [ud setBool:YES forKey:@"huiben"];
                        [ud setBool:YES forKey:@"geRenCenter"];

                        [self.navigationController popToRootViewControllerAnimated:YES];
                        
                    }else{
                    [tempSelf.navigationController pushViewController:[ZHSMyInfoXingQuViewController new] animated:YES];
                    }

                }else{
                    [TNToast showWithText:responseObject[@"message"]];
                }
                                                                                                                           
                                                                                                                           
            }];
        }else{
            [TNToast showWithText:@"宝宝姓名或者生日没有填写"];
        }

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.baobaoSex) {
        [self.view endEditing:YES];
        __weak typeof(self)tempSelf = self;
        TNBlockActionSheet* mySheet = [[TNBlockActionSheet alloc]initWithTitle:@"提示" delegate:nil cancelButtonTitle:@"取消"destructiveButtonTitle:@"小王子" otherButtonTitles:@"小公主", nil];
        [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            sex = 0;
            tempSelf.baobaoSex.text = @"小王子";
        } atButtonIndex:0];
        [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            sex = 1;
            tempSelf.baobaoSex.text = @"小公主";
        } atButtonIndex:1];
        [mySheet showInView:self.view.window];
    return NO;

    }
    return YES;
    
}
//- (IBAction)tapCity:(id)sender {
//    ZHSCitysViewController *vc = [ZHSCitysViewController new];
//    __weak typeof(self)tempSelf = self;
//    vc.myblock = ^(NSDictionary*classDic,NSDictionary *kindergarten_infoDic,NSDictionary*city_infoDic){
//        _school_class_id = classDic[@"id"];
//        tempSelf.kindergarten.text = [NSString stringWithFormat:@"%@%@%@",city_infoDic[@"description"],kindergarten_infoDic[@"name"],classDic[@"name"]];
//    };
//    [self.navigationController pushViewController:vc animated:YES];
////    [self presentViewController:vc animated:YES completion:nil];
//}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======选择宝宝出生时间
- (IBAction)cancle:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.datePickerContantView.frame = CGRectMake(0, kHight, kWidth, 240);
    }];
}
- (IBAction)xuanzeshijain:(id)sender {
    [self reclaimedKeyboard];
    [UIView animateWithDuration:0.5 animations:^{
        self.datePickerContantView.frame = CGRectMake(0, kHight-240, kWidth, 240);
        self.datePickerContantView.hidden = NO;
    }];
}
- (IBAction)yes:(UIButton *)sender{
    NSDate *date = self.datepiker.date;
    DLog(@"time is %@",date);
    DLog(@"time is %f",date.timeIntervalSince1970);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat : @"YYYY-MM-dd"];
    NSString *dateString = [formatter stringFromDate:date];
    self.age.text = [NSString stringWithFormat:@"%@",dateString];
    
    [self cancle:nil];
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
