//
//  ScanResultViewController.m
//  LBXScanDemo
//
//  Created by lbxia on 15/11/17.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "ScanResultViewController.h"
#import "UIImageView+WebCache.h"

@interface ScanResultViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *scanImg;
@property (weak, nonatomic) IBOutlet UILabel *labelScanText;
@property (weak, nonatomic) IBOutlet UILabel *labelScanCodeType;
@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    NSString *path = [NSString stringWithFormat:@"%@/book/isbn/%@",kHeaderURL,_strScan];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        _labelScanText.text = _strScan;
        _labelScanCodeType.text = [NSString stringWithFormat:@"书名:%@",responseObject[@"title"]];
        NSDictionary *images = responseObject[@"images"][0];
        
        [TNToast showWithText:responseObject[@"message"] duration:2];
        [_scanImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://admin.cctvzhs.com%@",images[@"large"]]]];

    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    _scanImg.image = _imgScan;
//    _labelScanText.text = _strScan;
//    _labelScanCodeType.text = [NSString stringWithFormat:@"书名:%@",_strCodeType];
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES ];
}

@end
