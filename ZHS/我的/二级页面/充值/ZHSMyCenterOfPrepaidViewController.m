//
//  ZHSMyCenterOfPrepaidViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/18.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSMyCenterOfPrepaidViewController.h"
#import "TNAlipayManager.h"
#import "TNWXPayManager.h"
#import "ZHSTuiYaJinViewController.h"
#import "MMLineBorderButton.h"
#import "ZHSLuckyDrawViewController.h"

@interface ZHSMyCenterOfPrepaidViewController ()
{
    BOOL _isBack;
    NSString *_payType;
}
@property (weak, nonatomic) IBOutlet UILabel *monry;

@property (weak, nonatomic) IBOutlet MMLineBorderButton *payBTN;
@property (weak, nonatomic) IBOutlet UIImageView *alipayImage;
@property (weak, nonatomic) IBOutlet UIImageView *weChatImage;

@end

@implementation ZHSMyCenterOfPrepaidViewController
#pragma mark =====添加支付监听

-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAlipayResult:) name:TNAlipayDidReceiveResultNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveWeChatPayResult:) name:TNWeChatpayDidReceiveResultNotification object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    _isBack = self.navigationController.navigationBar.hidden;
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"充值";
    _payType = @"alipay";
    
//    self.tabBarHidden = YES;
    [self createLeftBarItemWithImage];
    [self createRightBarItemWithImage:@"tixian"];
    if (self.money.length) {
        self.monry.text = self.money;
        [self.payBTN setTitle:[NSString stringWithFormat:@"确认支付%@元",self.money] forState:UIControlStateNormal];

    }else{
        [self requestMonry];
    }

}
-(void)clickRightSender:(UIButton *)sender{
    TNUser *user = [TNAppContext currentContext].user;
    
    if ([user.payment_status isEqualToString:@"not_paid"]) {
        [TNToast showWithText:@"您还没有支付押金"];
    }
    if ([user.payment_status isEqualToString:@"paid"]) {
        [self.navigationController pushViewController:[ZHSTuiYaJinViewController new] animated:YES];
    }
}
#pragma mark =====请求此账户需要支付的押金金额
-(void)requestMonry{
    NSString *path = [NSString stringWithFormat:@"%@/my-center/pay-acount",kHeaderURL];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            if ([responseObject[@"data"][@"money"] length]) {
                NSString *money = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"money"]];
                self.monry.text = money;
                [self.payBTN setTitle:[NSString stringWithFormat:@"确认支付%@元",money] forState:UIControlStateNormal];
            }
        }
    }];
}
- (IBAction)tapAlipay:(id)sender {
    self.alipayImage.image = [UIImage imageNamed:@"xuanze_sel"];
    self.weChatImage.image = [UIImage imageNamed:@"xuanze_nol"];
    _payType = @"alipay";
}
- (IBAction)tapWeChat:(id)sender {
    self.alipayImage.image = [UIImage imageNamed:@"xuanze_nol"];
    self.weChatImage.image = [UIImage imageNamed:@"xuanze_sel"];
    _payType = @"wxpay";
}
-(void)viewWillDisappear:(BOOL)animated{
    if (_isBack) {
        self.navigationController.navigationBar.hidden = YES;
    }else{
        self.navigationController.navigationBar.hidden = NO;
 
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark =====点击支付

- (IBAction)pay:(id)sender {
    TNUser *user = [TNAppContext currentContext].user;
    if ([user.payment_status isEqualToString:@"not_paid"]) {
        if ([_payType isEqualToString:@"alipay"]) {
        NSString *path = [NSString stringWithFormat:@"%@/customer/payment/alipay",kHeaderURL];
        [[THRequstManager sharedManager] asynPOST:path parameters:@{} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            if (code == 1) {
                [[TNAlipayManager defaultManager] sendOrderWithTradeNO:nil serialNumbers:nil productName:nil desc:nil price:0 orderString:responseObject[@"data"][@"orderStr"]];
            }
        }];
            
        }
        
        if ([_payType isEqualToString:@"wxpay"]) {
            NSString *path = [NSString stringWithFormat:@"%@/customer/payment/wechat",kHeaderURL];
            [[THRequstManager sharedManager] asynPOST:path parameters:@{} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
                if (code == 1) {
                    [[TNWXPayManager defaultManager] payWithTradeNo:nil title:nil price:0 notifyURL:nil jsonDic:responseObject[@"data"][@"orderObj"] completion:^(BOOL success, NSError *error) {
                              
                    }];
                }

            }];

        }
        
        
    }
    if ([user.payment_status isEqualToString:@"paid"]) {
        [TNToast showWithText:@"您已经支付过押金"];
    }


}
- (void)didReceiveAlipayResult:(NSNotification *)noti
{
    NSString *path = [NSString stringWithFormat:@"%@/my-center/payment-status",kHeaderURL];
    __weak typeof(self)tempself = self;
    [[THRequstManager sharedManager] asynGET:path  withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            NSDictionary *dic = responseObject[@"data"];
            if ([dic[@"payment_status"] isEqualToString:@"not_paid"]) {
                [TNToast showWithText:@"支付失败"];
            }
            if ([dic[@"payment_status"] isEqualToString:@"paid"]) {
                [TNToast showWithText:@"支付成功"];
                TNUser *user = [TNAppContext currentContext].user;
                user.payment_status = @"paid";
                [[TNAppContext currentContext] saveUser];
                [tempself requestIsChouJiang];
            }
        }
    }];
//    if ([noti.userInfo[TNAlipaySuccessKey] boolValue]) {
//        [TNToast showWithText:@"购买成功"];
//    } else {
//        [TNToast showWithText:@"支付失败"];
//    }
}

- (void)didReceiveWeChatPayResult:(NSNotification *)noti
{
    NSString *path = [NSString stringWithFormat:@"%@/my-center/payment-status",kHeaderURL];
    __weak typeof(self)tempself = self;
    [[THRequstManager sharedManager] asynGET:path  withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            NSDictionary *dic = responseObject[@"data"];
            if ([dic[@"payment_status"] isEqualToString:@"not_paid"]) {
                [TNToast showWithText:@"支付失败"];
            }
            if ([dic[@"payment_status"] isEqualToString:@"paid"]) {
                [TNToast showWithText:@"支付成功"];
                TNUser *user = [TNAppContext currentContext].user;
                user.payment_status = @"paid";
                [[TNAppContext currentContext] saveUser];
                [tempself requestIsChouJiang];
            }
        }
    }];

}
#pragma mark ======支付成功判断是否可以抽奖
-(void)requestIsChouJiang{
    __weak typeof(self)tempSelf = self;
    NSString *path = [NSString stringWithFormat:@"%@/check-lottery?type=PAID",kHeaderURL];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            ZHSLuckyDrawViewController *vc = [ZHSLuckyDrawViewController new];
            vc.lotteryID = responseObject[@"data"][@"id"];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [tempSelf.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
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
