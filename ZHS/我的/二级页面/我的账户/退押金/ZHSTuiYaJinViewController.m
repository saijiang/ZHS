//
//  ZHSTuiYaJinViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/2/3.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSTuiYaJinViewController.h"

@interface ZHSTuiYaJinViewController ()
@property (weak, nonatomic) IBOutlet UIView *diview;
@property (weak, nonatomic) IBOutlet UITextField *zhifubao;
@property (weak, nonatomic) IBOutlet UITextField *name;

@end

@implementation ZHSTuiYaJinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.diview.layer.borderWidth = 0.5;
    self.diview.layer.borderColor = [[[TNAppContext currentContext] getColor:@"#D6D7DC"] CGColor];
    self.diview.layer.cornerRadius = 5.0f;
    [self createLeftBarItemWithImage];
    [self createRightBarItemWithTitle:@"提交"];
}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
}
-(void)clickRightSender:(UIButton *)sender{
    if (self.zhifubao.text.length&&self.name.text.length) {
        NSString *path = [NSString stringWithFormat:@"%@/my-center/withdraw-request",kHeaderURL];
        NSMutableDictionary *dic = [@{} mutableCopy];
        [dic setValue:self.zhifubao.text forKey:@"alipay"];
        [dic setValue:self.name.text forKey:@"name"];
        __weak typeof(self)tempself = self;
        [[THRequstManager sharedManager] asynPOST:path parameters:dic withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            if (code == 1) {
                [TNToast showWithText:responseObject[@"message"]];
                [tempself back];
            }
        }];
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
