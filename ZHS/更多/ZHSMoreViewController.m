//
//  ZHSMoreViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/16.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSMoreViewController.h"
#import "TNFlowUtil.h"
#import "SDImageCache.h"
#import "ZHSYJFKViewController.h"
#import "TNH5ViewController.h"

@interface ZHSMoreViewController ()

@end

@implementation ZHSMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
}
- (IBAction)tapCliclk:(UITapGestureRecognizer*)sender {
    NSInteger num = sender.view.tag;
    switch (num) {
        case 1:
        {
            [self.navigationController pushViewController:[ZHSYJFKViewController new] animated:YES];
        }
            break;
        case 2:
        {
            TNH5ViewController *VC = [TNH5ViewController new];
            VC.urlString = @"http://admin.cctvzhs.com/pages/about/us";
            VC.titleString = @"关于我们";
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        case 3:
        {
            float cacheSize =  (float)([[SDImageCache sharedImageCache] getSize]/1024.0/1024.0);
            NSString *str = [NSString stringWithFormat:@"确定清除本地缓存%.2f？",cacheSize];
                TNBlockAlertView * block = [[TNBlockAlertView alloc]initWithTitle:nil message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [block setBlockForOk:^{
                    [[NSURLCache sharedURLCache] removeAllCachedResponses];
                    [[SDImageCache sharedImageCache]cleanDisk];
                    [[SDImageCache sharedImageCache]clearDisk];
                    [[SDImageCache sharedImageCache]clearMemory];
                }];
                [block show];
        }
            break;
        case 4:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kZhiHuiShuHuiBenAppStoreURL]];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logout:(id)sender {
    [TNAppContext currentContext].user = nil;
    [TNFlowUtil presentLoginWithCompletion:nil presentingViewController:self animated:YES];
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
