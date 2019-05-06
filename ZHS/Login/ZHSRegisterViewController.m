//
//  ZHSRegisterViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/12.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSRegisterViewController.h"
#import "MMLineBorderButton.h"
#import "SvUDIDTools.h"
#import "ZHSUserOfBaoBaoInformationViewController.h"
#import "TNH5ViewController.h"
#import "AppDelegate.h"
#import "ZHSMyInfoXingQuViewController.h"
#import "ZHSFindYourTeacherViewController.h"

@interface ZHSRegisterViewController ()<UITextFieldDelegate>
{
    BOOL _isShow;
}
@property (weak, nonatomic) IBOutlet UIView *diView;
@property (weak, nonatomic) IBOutlet UIButton *userXieYiBtn;
@property (weak, nonatomic) IBOutlet UIButton *regsterBtn;
@property (weak, nonatomic) IBOutlet MMLineBorderButton *yanZhengMaBtn;

@property (weak, nonatomic) IBOutlet UITextField *userPhoneTF;

@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UITextField *firstPasswordTF;


@property (weak, nonatomic) NSTimer *smsTimer;

@property (strong, nonatomic) NSString *smsCode;

@end

@implementation ZHSRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"注册";
    _isShow = NO;
    
    self.diView.layer.borderWidth = 0.5;
    self.diView.layer.borderColor = [[[TNAppContext currentContext] getColor:@"#D6D7DC"] CGColor];
    self.diView.layer.cornerRadius = 5.0f;
    self.regsterBtn.layer.cornerRadius = 5.0f;
    self.userPhoneTF.clearButtonMode = UITextFieldViewModeAlways;
    self.codeTF.clearButtonMode = UITextFieldViewModeAlways;
    self.yanZhengMaBtn.enabled = NO;
    if (kWidth < 375) {
        self.observeKeyboardChangeFrameNotification = YES;
    }

}
-(void)keyboardWillShow:(NSNotification *)notification{
    if (_isShow == NO&& [self.firstPasswordTF isFirstResponder]) {
        CGPoint pt = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
        pt = [self.view.window convertPoint:pt toView:self.view];
        UIViewAnimationCurve curve = [notification.userInfo integerForKey:UIKeyboardAnimationCurveUserInfoKey];
        NSTimeInterval duration = [notification.userInfo doubleForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:duration delay:0 options:curve << 16 animations:^{
            DLog(@"%f",self.view.centerX);
            DLog(@"%f",self.view.centerY);
            self.view.centerY = self.view.centerY - 120 ;
            DLog(@"%f",self.view.centerX);
            DLog(@"%f",self.view.centerY);
            _isShow = YES;
        } completion:nil];
    }
}
-(void)keyboardWillHide:(NSNotification *)notification{
    if (_isShow == YES && [self.firstPasswordTF isFirstResponder]) {
        UIViewAnimationCurve curve = [notification.userInfo integerForKey:UIKeyboardAnimationCurveUserInfoKey];
        NSTimeInterval duration = [notification.userInfo doubleForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:duration delay:0 options:curve << 16 animations:^{
            DLog(@"%f",self.view.centerX);
            DLog(@"%f",self.view.centerY);
            self.view.centerY = self.view.centerY+120;
            DLog(@"%f",self.view.centerX);
            DLog(@"%f",self.view.centerY);
            _isShow = NO;
        } completion:nil];
    }
    
}

//-(void)keyboardWillChangeFrame:(NSNotification *)notification{
//    if ([self.firstPasswordTF becomeFirstResponder] || [self.secondPassword becomeFirstResponder]) {
//    CGPoint pt = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
//    pt = [self.view.window convertPoint:pt toView:self.view];
//    UIViewAnimationCurve curve = [notification.userInfo integerForKey:UIKeyboardAnimationCurveUserInfoKey];
//    NSTimeInterval duration = [notification.userInfo doubleForKey:UIKeyboardAnimationDurationUserInfoKey];
//    [UIView animateWithDuration:duration delay:0 options:curve << 16 animations:^{
//        DLog(@"%f",self.view.centerX);
//        DLog(@"%f",self.view.centerY);
//        if (pt.y < 480) {
//            self.view.centerY = self.view.centerY - 100 ;
//            DLog(@"%f",self.view.centerX);
//            DLog(@"%f",self.view.centerY);
//        }else
//        {
//            self.view.centerY = (pt.y-100)/2;
//            DLog(@"%f",self.view.centerX);
//            DLog(@"%f",self.view.centerY);
//        }
//    } completion:nil];
//    }
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.userPhoneTF) {
        
        const char* p = string.UTF8String;
        for (int i=0; i< string.length; i++)
        {
            if (p[i]<'0' || p[i] >'9')
            {
                return NO;
            }
        }
        
        if (s.length >11) {
            return NO;
        }
        if (s.length==0) {
        }
        
        if (s.length < 11) {
            self.yanZhengMaBtn.enabled = NO;
            self.regsterBtn.enabled = NO;

        } else {
            self.yanZhengMaBtn.enabled = !self.smsTimer.isValid;
            self.regsterBtn.enabled = self.codeTF.text.length == 4;
        }
    }else if (textField == self.codeTF) {
        if (s.length > 6) {
            return NO;
        }
        if (s.length==0) {
            //            self.disslabel.hidden = YES;
            //            self.errorlabel.hidden = YES;
        }
        if (s.length < 4) {
            
//            [self.regsterBtn setTitleColor:[[TNAppContext currentContext] getColor:@"#e6939c"] forState:UIControlStateNormal];
            self.regsterBtn.enabled = NO;
            //            self.disslabel.hidden = YES;
            //            self.errorlabel.hidden = YES;
        } else {
//            [self.regsterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.regsterBtn.enabled = self.userPhoneTF.text.length == 11;
        }
    }


    return YES;
}

- (IBAction)codeClick:(id)sender {
//#warning --- 审核测试号码 ---
    NSArray *testPhone = @[
                           
                           ];
    
    NSString *mobile = [self.userPhoneTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![[TNAppContext currentContext] validateMobile:mobile] && ![testPhone containsObject:mobile]) {
        [TNToast showWithText:@"不是有效的手机号码"];
        //        self.disslabel.hidden = NO;
        //        self.errorlabel.hidden =YES;
        return;
    }
    
    [self.userPhoneTF resignFirstResponder];
    [self.codeTF becomeFirstResponder];
    self.yanZhengMaBtn.enabled = NO;
    __block NSInteger count = 60;
    self.smsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 block:^BOOL(NSTimer *timer) {
        NSString *titleString = [NSString stringWithFormat:@"%@秒后重发", @(--count)];
        self.yanZhengMaBtn.titleLabel.text = titleString;
        [self.yanZhengMaBtn setTitle:titleString forState:UIControlStateNormal];
        return NO;
    } userInfo:nil repeatCount:60 completion:^(BOOL canceled) {
        [self.yanZhengMaBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.yanZhengMaBtn.enabled = YES;
    }];
    [self.smsTimer fire];
    NSDictionary *param = @{@"mobile": mobile,@"uuid":[SvUDIDTools UDID]};
    NSMutableDictionary *dic2 = [NSMutableDictionary dictionaryWithDictionary:param];
    if ([testPhone containsObject:mobile]){
        [dic2 setObject:@"TuhuTest" forKey:@"test"];
    }
    
    /*
     UPDATE 2015/7/6
     使用新的网络请求基类， 发起异步POST请求
     */
    [[THRequstManager sharedManager] asynPOST:[NSString stringWithFormat:@"%@/auth/verify-mobile",kHeaderURL] parameters:param withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
//            self.smsCode = responseObject[@"Code"];
            [TNToast showWithText:@"验证码已经发送到您手机，请查收。" duration:1];
            
//            if ([responseObject[@"Result"] length]) {
//                self.smsCode = responseObject[@"Result"];
////                self.smsTextField.text = self.smsCode;
//                self.regsterBtn.enabled = YES;
//            }
            
        }else
        {
            if (responseObject[@"message"]) {
                [TNToast showWithText:responseObject[@"message"] duration:1];
            }else
            {
                [TNToast showWithText:@"数据异常"];
            }
        }
        self.regsterBtn.enabled = YES;
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    [self.smsTimer invalidate];
}
- (IBAction)regster:(id)sender {
        __weak typeof(self)tempSelf = self;
        [[THRequstManager sharedManager] asynPOST:[NSString stringWithFormat:@"%@/auth/register",kHeaderURL] parameters:@{
            @"uuid":[SvUDIDTools UDID],
            @"mobile": self.userPhoneTF.text,
            @"code": self.codeTF.text,
            @"password":self.firstPasswordTF.text,
            } withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
                if (code == 1) {
                    [TNToast showWithText:responseObject[@"message"]];
                    NSDictionary *data = responseObject[@"data"];
                    TNUser *user = [TNUser modelWithJsonDicWithoutMap:data[@"customer"]];
                    user.token = data[@"token"];
                    user.ID = data[@"customer"][@"id"];
                    [TNAppContext currentContext].user = user;
                    [[TNAppContext currentContext] saveUser];
                    NSUserDefaults* ud=[NSUserDefaults standardUserDefaults];
                    NSDate *date = [NSDate date];
//                    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//                    NSInteger interval = [zone secondsFromGMTForDate: date];
//                    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
                    [ud setObject:date forKey:@"refreshTokenTime"];
//                    [ud setObject:localeDate forKey:@"refreshTokenTime"];
                    [tempSelf.navigationController pushViewController:[ZHSFindYourTeacherViewController new] animated:YES];
//                    [self presentViewController:[ZHSUserOfBaoBaoInformationViewController new] animated:YES completion:nil];
                    
                    UIDevice *device = [UIDevice currentDevice];
                    NSMutableDictionary *dic = [@{} mutableCopy];
                    NSMutableDictionary *prams = [@{} mutableCopy];
                    [dic setValue:[(AppDelegate*)[UIApplication sharedApplication].delegate deviceToken] forKey:@"device_token"];
                    [dic setValue:device.systemName forKey:@"device_type"];
                    [dic setValue:device.systemVersion forKey:@"os_version"];
                    [prams setValue:dic forKey:@"device"];
                    NSString *path = [NSString stringWithFormat:@"%@/customer/update",kHeaderURL];
                    [[THRequstManager sharedManager] asynPOST:path parameters:prams blockUserInteraction:NO messageDuring:0.5  withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
                        
                    }];
                    
                }else{
                    [TNToast showWithText:responseObject[@"message"]];
                }
                
    }];

}
- (IBAction)xieyiBtnClick:(id)sender {
    TNH5ViewController *vc = [TNH5ViewController new];
    vc.titleString = @"用户协议";
    vc.urlString = @"http://www.cctvzhs.com/reg.html";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
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
