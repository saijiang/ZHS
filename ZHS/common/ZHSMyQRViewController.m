//
//  MyQRViewController.m
//  LBXScanDemo
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "ZHSMyQRViewController.h"
#import "LBXScanWrapper.h"
#import "LBXAlertAction.h"

@interface  ZHSMyQRViewController()
{
    BOOL _isBack;
}
@property (weak, nonatomic) IBOutlet UILabel *qushumaLable;

//二维码
@property (nonatomic, weak)IBOutlet UIImageView* qrImgView;




@end

@implementation ZHSMyQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isBack = NO;
    // Do any additional setup after loading the view.
    [self createLeftBarItemWithImage];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = @"取书码";
    
    [self createQR1];
    self.qushumaLable.text = self.qushuCode;
}


- (void)newCodeChooose
{
    __weak __typeof(self) weakSelf = self;
    [LBXAlertAction showActionSheetWithTitle:@"选择" message:@"选择" chooseBlock:^(NSInteger buttonIdx) {
        
        if (buttonIdx==0) {
            [weakSelf createQR1];
        }
        else if (buttonIdx == 1)
        {
            [weakSelf createQR2];
        }
        else if (buttonIdx == 2)
        {
            [weakSelf createQR3];
        }
        else if (buttonIdx == 3)
        {
            [weakSelf createCodeEAN13];
        }
        else if (buttonIdx == 4)
        {
            [weakSelf createCode93];
        }
        
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitle:@"二维码+logo",@"二维码上色",@"二维码前景颜色+背景颜色",@"商品条形码",@"code93(支付宝付款条形码)",nil];
}


- (void)createQR1
{
    
    UIImage *qrImg = [LBXScanWrapper createQRWithString:self.qushuCode size:_qrImgView.bounds.size];
    
    UIImage *logoImg = [UIImage imageNamed:@"logo"];
    _qrImgView.image = [LBXScanWrapper addImageLogo:qrImg centerLogoImage:logoImg logoSize:CGSizeMake(40, 40)];
    
}

- (void)createQR2
{
    
    UIImage *image = [LBXScanWrapper createQRWithString:self.qushuCode size:_qrImgView.bounds.size];
    //二维码上色
    _qrImgView.image = [LBXScanWrapper imageBlackToTransparent:image withRed:255.0f andGreen:74.0f andBlue:89.0f];
    
}

- (void)createQR3
{
    
    //生成的不好识别，自己去调好颜色应该就可以识别了
    _qrImgView.image = [LBXScanWrapper createQRWithString:self.qushuCode QRSize:_qrImgView.bounds.size QRColor:[UIColor colorWithRed:200./255. green:84./255. blue:40./255 alpha:1.0]bkColor:[UIColor colorWithRed:41./255. green:130./255. blue:45./255. alpha:1.0]];
}

//商品条形码
- (void)createCodeEAN13
{
    
//    _tImgView.image = [LBXScanWrapper createCodeWithString:@"6944551723107" size:_qrImgView.bounds.size CodeFomart:AVMetadataObjectTypeEAN13Code];
}

- (void)createCode93
{
    
    //支付宝付款码-条款码
//    _tImgView.image = [LBXScanWrapper createCodeWithString:@"283657461695996598" size:_qrImgView.bounds.size CodeFomart:AVMetadataObjectTypeCode128Code];
}
-(void)back{
//    _isBack = YES;
    [self.navigationController popViewControllerAnimated:YES];
}
//-(void)viewWillDisappear:(BOOL)animated{
//    if (_isBack) {
//        self.navigationController.navigationBar.hidden = YES;
//    }
//}

@end
