//
//  ZHSMyCenterOfRecyclingableViewCellViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/21.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSMyCenterOfRecyclingableViewCellViewController.h"
#import "LBXScanViewController.h"
#import "TNFlowUtil.h"
#import "TNH5ViewController.h"

@interface ZHSMyCenterOfRecyclingableViewCellViewController ()<UITextFieldDelegate>
{
    BOOL _isBack;
    NSMutableArray*_imagesID;
    NSString * _isbn;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heights;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widths;
@property (weak, nonatomic) IBOutlet UITextField *isbnLable;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UIImageView *topimage;
@property (weak, nonatomic) IBOutlet UIImageView *bottomimage;

@property (weak, nonatomic) IBOutlet UIView *containerview;
@end

@implementation ZHSMyCenterOfRecyclingableViewCellViewController
- (IBAction)clickSaoMaButton:(id)sender {
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    style.photoframeLineW = 6;
    style.photoframeAngleW = 24;
    style.photoframeAngleH = 24;
    MMLog(@"%f",kWidth);
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    
    //qq里面的线条图片
    UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    style.animationImage = imgLine;
    
    LBXScanViewController *vc = [LBXScanViewController new];
    vc.style = style;
    vc.isQQSimulator = YES;
    __weak typeof(self)tempself = self;
    vc.completion = ^(NSString *strScanned,LBXScanResult*strResult){
        _isbn = strScanned;
        [tempself.navigationController popViewControllerAnimated:YES];
        [tempself requestBookInfoWith:_isbn];
    };
    [self.navigationController pushViewController:vc animated:YES];

    
}
-(void)requestBookInfoWith:(NSString*)isbn{
    NSString *path = [NSString stringWithFormat:@"%@/book/isbn/%@",kHeaderURL,isbn];
    __weak typeof(self)tempSelf = self;
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        tempSelf.isbnLable.text = [NSString stringWithFormat:@"书名:%@",responseObject[@"title"]];
    }];
}
-(void)postImageWith:(UIImage*)image view:(UIImageView*)view
{
    NSString *path = [NSString stringWithFormat:@"%@/photo-upload",kHeaderURL];
    [[THRequstManager sharedManager] asynPOST:path parameters:@{@"file":image} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            if (view == _topimage) {
                [_imagesID replaceObjectAtIndex:0 withObject:responseObject[@"data"][@"id"]] ;
            }
            if (view == _bottomimage) {
                [_imagesID replaceObjectAtIndex:1 withObject:responseObject[@"data"][@"id"] ];
            }
            view.image = image;
        }else{
            [TNToast showWithText:@"图片上传失败，请重新上传"];
        }
    }];
}
- (IBAction)tapZhaopian:(UITapGestureRecognizer*)sender {
    if (self.isbnLable.text && self.isbnLable.text.length) {
        __weak typeof(self)tempSelf = self;
        TNBlockActionSheet* mySheet = [[TNBlockActionSheet alloc]initWithTitle:@"上传相片" delegate:nil cancelButtonTitle:@"取消"destructiveButtonTitle:@"拍摄" otherButtonTitles:@"从相册选取", nil];
        [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            [TNFlowUtil startPhotoPickerWithPresentingViewController:tempSelf defaultToFrontCamera:NO animated:YES completion:^(UIImagePickerController *picker, BOOL isCancel, UIImage *image) {
                if (isCancel) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    return ;
                }
//                if (sender.view == _topimage) {
//                    tempSelf.topimage.image = image;
//                }
//                if (sender.view == _bottomimage) {
                [tempSelf postImageWith:image view:(UIImageView*)sender.view];
//                    tempSelf.bottomimage.image = image;
//                }
                [tempSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        } atButtonIndex:0];
        [mySheet setBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            [TNFlowUtil startAlbumPickerWithPresentingViewController:tempSelf animated:YES completion:^(UIImagePickerController *picker, BOOL isCancel, UIImage *image) {
                if (isCancel) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    return ;
                }
//                if (sender.view == _topimage) {
//                    tempSelf.topimage.image = image;
//                }
//                if (sender.view == _bottomimage) {
//                    tempSelf.bottomimage.image = image;
//                }
                [tempSelf postImageWith:image view:(UIImageView*)sender.view];

                [tempSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        } atButtonIndex:1];
        [mySheet showInView:self.view.window];
    }
}
- (IBAction)clickOKButton:(id)sender {
    NSString *path = [NSString stringWithFormat:@"%@/my-center/cyclic-request",kHeaderURL];
    NSMutableDictionary *parms = [@{} mutableCopy];
    [parms setValue:_isbn forKey:@"isbn"];
    [parms setValue:_imagesID forKey:@"photos"];
    __weak typeof(self)tempself = self;
    [[THRequstManager sharedManager] asynPOST:path parameters:parms withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            [TNToast showWithText:responseObject[@"message"]];
            [tempself back];
        }
    }];
    
}
#pragma mark ===== UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
-(void)viewWillAppear:(BOOL)animated{
        self.navigationController.navigationBar.hidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _isBack = NO;
//    self.heights.constant = 600;
    self.widths.constant = kWidth;
    [self.containerview layoutIfNeeded];
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"循环利用";
//    self.tabBarHidden = YES;
    self.address.delegate = self;
    _imagesID = [@[@"",@""] mutableCopy];
}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)xieyiBtnClick:(id)sender {
    TNH5ViewController *vc = [TNH5ViewController new];
    vc.titleString = @"循环分享协议";
    vc.urlString = @"http://www.cctvzhs.com/own.html";
    [self.navigationController pushViewController:vc animated:YES];

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
