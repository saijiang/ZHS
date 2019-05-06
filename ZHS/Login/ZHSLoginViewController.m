//
//  ZHSLoginViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/12.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSLoginViewController.h"
#import "ZHSRegisterViewController.h"
#import "ZHSForgotPasswordViewController.h"
#import "AppDelegate.h"

@interface ZHSLoginViewController ()
{
    BOOL _isShow;
}

@property (weak, nonatomic) IBOutlet UIView *diView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *usernamTF;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@end

@implementation ZHSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self createLeftBarItemWithImage];
    _isShow = NO;
    self.navigationItem.title =@"登录";
//    self.diView.layer.borderWidth = 1;
//    self.diView.layer.borderColor = [[[TNAppContext currentContext] getColor:@"#D6D7DC"] CGColor];
    self.diView.layer.cornerRadius = 5.0f;
    self.loginBtn.layer.cornerRadius = 5.0f;
    if (kWidth < 375) {
        self.observeKeyboardChangeFrameNotification = YES;
    }
}
-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)keyboardWillShow:(NSNotification *)notification{
    if (_isShow == NO) {
    CGPoint pt = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    pt = [self.view.window convertPoint:pt toView:self.view];
    UIViewAnimationCurve curve = [notification.userInfo integerForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSTimeInterval duration = [notification.userInfo doubleForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration delay:0 options:curve << 16 animations:^{
        DLog(@"%f",self.view.centerX);
        DLog(@"%f",self.view.centerY);
        self.view.centerY = self.view.centerY - 100 ;
        DLog(@"%f",self.view.centerX);
        DLog(@"%f",self.view.centerY);
        _isShow = YES;
    } completion:nil];
    }
}
-(void)keyboardWillHide:(NSNotification *)notification{
    if (_isShow == YES) {
        CGPoint pt = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
        pt = [self.view.window convertPoint:pt toView:self.view];
        UIViewAnimationCurve curve = [notification.userInfo integerForKey:UIKeyboardAnimationCurveUserInfoKey];
        NSTimeInterval duration = [notification.userInfo doubleForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:duration delay:0 options:curve << 16 animations:^{
            DLog(@"%f",self.view.centerX);
            DLog(@"%f",self.view.centerY);
            self.view.centerY = self.view.centerY+100 ;
            DLog(@"%f",self.view.centerX);
            DLog(@"%f",self.view.centerY);
            _isShow = NO;
        } completion:nil];
    }

}
//-(void)keyboardWillChangeFrame:(NSNotification *)notification{
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
//}
- (IBAction)gotoRegsterVC:(id)sender {
    ZHSRegisterViewController *vc = [[ZHSRegisterViewController alloc]initWithNibName:@"ZHSRegisterViewController" bundle:[NSBundle mainBundle]];
//    [self presentViewController:vc animated:YES completion:^{}];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)forgotPasswordBtnClick:(id)sender {
    ZHSForgotPasswordViewController *VC = [[ZHSForgotPasswordViewController alloc] initWithNibName:@"ZHSForgotPasswordViewController" bundle:[NSBundle mainBundle]];
//    [self presentViewController:VC animated:YES completion:^{}];
    [self.navigationController pushViewController:VC animated:YES];

}
- (IBAction)login:(id)sender {
    if (self.usernamTF.text && _passwordTF.text) {
        __weak typeof(self)tempSelf = self;
        [[THRequstManager sharedManager] asynPOST:[NSString stringWithFormat:@"%@/auth/login",kHeaderURL] parameters:@{
            @"mobile": self.usernamTF.text,
            @"password":self.passwordTF.text                                                                                                                          } withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            if (code == 1) {
                [TNToast showWithText:responseObject[@"message"]];
                NSDictionary *data = responseObject[@"data"];
                TNUser *user = [TNUser modelWithJsonDicWithoutMap:data[@"customer"]];
                user.token = data[@"token"];
                user.ID = data[@"customer"][@"id"];
                [TNAppContext currentContext].user = user;
                [[TNAppContext currentContext] saveUser];
                [tempSelf dismissViewControllerAnimated:YES completion:nil];
                [TNFlowUtil startMainFlow];
                NSUserDefaults* ud=[NSUserDefaults standardUserDefaults];
                NSDate *date = [NSDate date];
//                NSTimeZone *zone = [NSTimeZone systemTimeZone];
//                NSInteger interval = [zone secondsFromGMTForDate: date];
//                NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
                [ud setObject:date forKey:@"refreshTokenTime"];

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
