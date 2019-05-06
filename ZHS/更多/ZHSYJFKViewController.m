//
//  ZHSYJFKViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/2/3.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSYJFKViewController.h"

@interface ZHSYJFKViewController ()
@property (weak, nonatomic) IBOutlet UITextView *yijian;

@end

@implementation ZHSYJFKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"意见反馈";
    [self createRightBarItemWithTitle:@"确定"];
    self.yijian.layer.cornerRadius = 5.0f;
    self.yijian.layer.borderColor = [[UIColor blackColor] CGColor];
    self.yijian.layer.borderWidth = 0.5;
    
    [self.yijian becomeFirstResponder];
}
-(void)clickRightSender:(UIButton *)sender{
    if (self.yijian.text &&self.yijian.text.length) {
        NSString *path = [NSString stringWithFormat:@"%@/settings/feedback",kHeaderURL];
        NSMutableDictionary *dic = [@{} mutableCopy];
        [dic setValue:self.yijian.text forKey:@"content"];
        __weak typeof(self)tempSelf = self;
        [[THRequstManager sharedManager] asynPOST:path parameters:dic withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            if (code == 1) {
                [TNToast showWithText:responseObject[@"message"]];
                [tempSelf back];
            }
        }];
    }else{
        [TNToast showWithText:@"请填写您的意见"];
    }
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
