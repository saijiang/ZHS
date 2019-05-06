//
//  ZHSMyCenterViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/16.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSMyCenterViewController.h"
#import "ZHSMyJieYueJiLuViewController.h"
#import "ZHSMyCollectionViewController.h"
#import "ZHSMyIncomeViewController.h"
#import "ZHSMyCenterOfRecyclingableViewCellViewController.h"
#import "ZHSMyCenterOfPrepaidViewController.h"
#import "ZHSMyAccountViewController.h"
#import "ZHSMyYiJianJieYueViewController.h"
#import "ZHSMyInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "ZHSLuckyDrawViewController.h"
#import "ZHSMyCenterOfHuiYuanZhuanXiangViewController.h"

@interface ZHSMyCenterViewController ()<MMTableViewHandleDelegate,MMNavigationControllerNotificationDelegate>
{
    NSString *rank;
    NSString*score;
    NSString *youeryuan;
}
@property (weak, nonatomic) IBOutlet UIView *userImage_backg;
@property(nonatomic,strong)MMTableViewHandle *handle;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIView *newview;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *gongnengView;
@property (weak, nonatomic) IBOutlet UIView *right;
@property (weak, nonatomic) IBOutlet UIView *left;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLable;
#pragma mark ==========用户的排名情况和幼儿园班级信息
@property (weak, nonatomic) IBOutlet UILabel *rankL;
@property (weak, nonatomic) IBOutlet UILabel *scoreL;
@property (weak, nonatomic) IBOutlet UILabel *youeryuanL;
#pragma mark ==========user图像约束更新、
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userView_H;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userViewOfWhiteView_H;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImage_W;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImage_H;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mingciView_Top;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userimage_backg_H;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userimage_backg_W;

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1_W;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1_H;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1_left;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1_bottom;

#pragma mark ==========user三个功能约束更新
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gongnengView_H;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yuanpanImage_W;
#pragma mark ==========圆盘约束更新
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yuanpanImage_H;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ziLable_Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftView_Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightView_Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yuyanpanImage_Top;

@end

@implementation ZHSMyCenterViewController
- (void)viewControllerDidShowWithPop:(NSArray *)viewControllers
{
    if ([viewControllers containsObjectClass:[ZHSMyInfoViewController class]])
    {
        [self.userImageView sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",kUrl,[TNAppContext currentContext].user.avatar[@"small"]]] placeholderImage:[UIImage imageNamed:@"chengzhang"]];
        self.usernameLable.text = [TNAppContext currentContext].user.name;
        NSUserDefaults* ud=[NSUserDefaults standardUserDefaults];
        if ([ud boolForKey:@"geRenCenter"]) {
            [self requestUserInfo];
            [ud setBool:NO forKey:@"geRenCenter"];
        }
    }}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarHidden = NO;
    self.navigationBarHidden = YES;
    [self requestUserInfo];
    UIImageView *imaeV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHight)];
    imaeV.image = [UIImage imageNamed:@"navbar"];
    [self.view addSubview:imaeV];
    self.newview.frame = CGRectMake(0, 0, kWidth, kHight);
    [self.view addSubview:self.newview];
    for (UIView *view in self.gongnengView) {
        view.layer.cornerRadius = 8.f;
    }
    self.userView_H.constant = (163*kHight)/667.0;
    self.userViewOfWhiteView_H.constant = (43*kHight)/667.0;
//    self.userImage_W.constant = (85*kHight)/667.0;
//    self.userImage_H.constant = (85*kHight)/667.0;
    
    self.userimage_backg_H.constant = (95*kHight)/667.0;
    self.userimage_backg_W.constant = (95*kHight)/667.0;
    self.view1_H.constant = (85*kHight)/667.0;
    self.view1_W.constant = (85*kHight)/667.0;

    self.view1_bottom.constant = (self.userimage_backg_W.constant - self.view1_W.constant)/2;
    self.view1_left.constant = 15.0f+(self.userimage_backg_W.constant - self.view1_W.constant)/2;
    
    self.gongnengView_H.constant = (113*kWidth)/375.0;
    self.yuanpanImage_H.constant = (249*kHight)/667.0;
    self.yuanpanImage_W.constant = (255*kHight)/667.0;
    
    self.ziLable_Top.constant = (25*kHight)/667.0;
    self.leftView_Top.constant = (35*kHight)/667.0;
    self.rightView_Top.constant = (35*kHight)/667.0;
    self.yuyanpanImage_Top.constant = (25*kHight)/667.0;
    self.mingciView_Top.constant = (100*kHight)/667.0;
    

    
    self.userImage_backg.layer.cornerRadius = self.userimage_backg_H.constant/2;
    self.userImage_backg.layer.masksToBounds = YES;
    
    self.userImageView.layer.cornerRadius = self.view1_H.constant/2;
    self.userImageView.layer.masksToBounds = YES;
    
    self.view1.layer.cornerRadius = self.view1_H.constant/2;
    self.view1.layer.masksToBounds = YES;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",kUrl,[TNAppContext currentContext].user.avatar[@"small"]]] placeholderImage:[UIImage imageNamed:@"chengzhang"]];
    self.usernameLable.text = [TNAppContext currentContext].user.name;
    [self.left.layer insertSublayer:[self shadowAsInverseWithStartPoint:CGPointMake(0, 0.5) andEndPoint:CGPointMake(1, 0.5) startColor:@"#f3f3f6" endColor:@"#AFAFAF" view:self.left]atIndex:0];
    
    [self.right.layer insertSublayer:[self shadowAsInverseWithStartPoint:CGPointMake(0, 0.5) andEndPoint:CGPointMake(1, 0.5) startColor:@"#AFAFAF" endColor:@"#f3f3f6" view:self.right]atIndex:0];

    // Do any additional setup after loading the view from its nib.
}


-(void)requestUserInfo{
    NSString *path = [NSString stringWithFormat:@"%@/my-center/score-board",kHeaderURL];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            NSDictionary *dic = responseObject[@"data"];
            score =[NSString stringWithFormat:@"%@", dic[@"score"]];
            rank = [NSString stringWithFormat:@"%@",dic[@"rank"]];
            youeryuan = [NSString stringWithFormat:@"%@%@",dic[@"school_class"][@"school_info"][@"name"],dic[@"school_class"][@"name"]];
//            NSInteger num = (score.integerValue)*240/800;
            self.rankL.text = [NSString stringWithFormat:@"第%@名", rank ];
            self.scoreL.text = [NSString stringWithFormat:@"%@", score];
            self.youeryuanL.text = youeryuan;
        }
    }];
}
- (IBAction)MyAccount:(id)sender {
    TNUser *user = [TNAppContext currentContext].user;
    if (user.school_class_info.count) {
        [self.navigationController pushViewController:[ZHSMyAccountViewController new] animated:YES];
    }else{
        ZHSHomeViewController*vc = [TNFlowUtil startGoHome];
        [vc cityClick:nil];
    }

}
- (IBAction)jieyuejilu:(id)sender {
    [self.navigationController pushViewController:[ZHSMyJieYueJiLuViewController new] animated:YES];

}
- (IBAction)wodeshoucang:(id)sender {
    [self.navigationController pushViewController:[ZHSMyCollectionViewController new] animated:YES];

}
- (IBAction)myinfo:(id)sender {
    [self.navigationController pushViewController:[ZHSMyInfoViewController new] animated:YES];
}
#pragma mark =======给view添加渐变色
- (CAGradientLayer *)shadowAsInverseWithStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint startColor:(NSString*)startColor endColor:(NSString*)endColor view:(UIView*)view
{
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    CGRect newGradientLayerFrame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    gradientLayer.frame = newGradientLayerFrame;
    
    //添加渐变的颜色组合
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[[[TNAppContext currentContext] getColor:startColor] colorWithAlphaComponent:1]CGColor],
                            (id)[[[TNAppContext currentContext] getColor:endColor]CGColor],
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:1],
                               nil];
    
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    return gradientLayer;
}
- (IBAction)choujiang:(id)sender {
    [self requestIsChouJiang];
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
- (IBAction)huiyuanzhuanxiangBTNClick:(id)sender {
    [self.navigationController pushViewController:[ZHSMyCenterOfHuiYuanZhuanXiangViewController new] animated:YES ];
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
