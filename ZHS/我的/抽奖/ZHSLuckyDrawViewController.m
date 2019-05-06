//
//  ZHSLuckyDrawViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/3/9.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSLuckyDrawViewController.h"

@interface ZHSLuckyDrawViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *styleH;
@property (weak, nonatomic) IBOutlet UILabel *jiangL;
@property (weak, nonatomic) IBOutlet UIView *styleView;
@property (weak, nonatomic) IBOutlet UILabel *miaoshuL;
@property (weak, nonatomic) IBOutlet UILabel *thirsL;
@end

@implementation ZHSLuckyDrawViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.drawH.constant = kHight*(955/1334.0);
    self.styleH.constant = kHight*(182/1334.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)luckyDraw:(id)sender {
    [self requestJiangWithID:self.lotteryID];
}
- (IBAction)backClick:(id)sender {
    [self back];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}
#pragma mark ======判断用户抽中的是几等奖
-(void)requestJiangWithID:(NSNumber *)ID{
    NSString *path = [NSString stringWithFormat:@"%@/get-lottery?ID=%@",kHeaderURL,ID];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            NSDictionary *dic = responseObject[@"data"];
            if ([dic[@"lottery"] integerValue]==-1) {
                self.miaoshuL.text = @"很遗憾";
                self.jiangL.text = dic[@"name"];
                self.thirsL.text = @"";
            }else{
                self.jiangL.text = dic[@"name"];
            }
            [UIView animateWithDuration:2 animations:^{
                self.styleView.hidden = NO;
            }];
        }else if([responseObject[@"status"] integerValue] == -1){
            [TNToast showWithText:responseObject[@"message"]];
            NSDictionary *dic = responseObject[@"data"];
            if ([dic[@"lottery"] integerValue]==-1) {
                self.miaoshuL.text = @"很遗憾";
                self.jiangL.text = dic[@"name"];
                self.thirsL.text = @"";
            }else{
                self.jiangL.text = dic[@"name"];
            }
            [UIView animateWithDuration:2 animations:^{
                self.styleView.hidden = NO;
            }];
        }else{
            [TNToast showWithText:responseObject[@"message"]];
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
