//
//  ZHSMyYiJianJieYueViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/27.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSMyYiJianJieYueViewController.h"
#import "LBXScanViewController.h"
#import "ZHSSchoolbag.h"
#import "ZHSBooks.h"
#import "THCouponVC.h"
#import "MMLineBorderButton.h"
#import "ZHSMyCenterOfPrepaidViewController.h"
@interface ZHSMyYiJianJieYueViewController ()<MMTableViewHandleDelegate>
{
    BOOL _isBack;
    BOOL _isHidden;
    NSString *_code;
    NSString *schoolbagStatus;
    
}
@property (weak, nonatomic) IBOutlet MMLineBorderButton *lijijieyueBtn;
@property (strong, nonatomic) IBOutlet UIView *schoolbagView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) MMTableViewHandle *handle;

@end

@implementation ZHSMyYiJianJieYueViewController
- (IBAction)yijiansaomiao:(id)sender {
//    [self requestSchoolbagWithCode:@"P1-1-00000025"];

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
//        tempself.isbnLable.text = strScanned;
        [tempself requestSchoolbagWithCode:strScanned];
        [tempself.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];

}
-(void)initTableviewWith:(ZHSSchoolbag*)obj{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    MMRow *row = [MMRow rowWithTag:0 rowInfo:obj rowActions:@[^{
        THCouponVC *vc = [[THCouponVC alloc] init];
        vc.schoolbag = obj;
        [self.navigationController pushViewController:vc animated:YES];
    }] height:267 reuseIdentifier:@"ZHSPictureBookMuseumTableViewCell"];
        [section addRow:row];
    
    [table addSection:section];
    _handle.tableModel = table;
    [_handle reloadTable];
}
-(void)requestSchoolbagWithCode:(NSString*)code{
    _code = code;
    if ([code hasPrefix:@"P"]) {
        NSString *path = [NSString stringWithFormat:@"%@/package/info/%@",kHeaderURL,code];
        __weak typeof(self)tempSelf = self;
        [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            if (code ==1) {
                schoolbagStatus = responseObject[@"data"][@"can_borrow"];
                
                if ([schoolbagStatus  isEqual: @"not_paid"]) {
                    [tempSelf.lijijieyueBtn setTitle:@"您还不使我们的会员" forState:UIControlStateNormal];
                    tempSelf.lijijieyueBtn.enabled = NO;
                }else if ([schoolbagStatus  isEqual: @"ok"]) {
                    [tempSelf.lijijieyueBtn setTitle:@"一键借阅" forState:UIControlStateNormal];
                    tempSelf.lijijieyueBtn.enabled = YES;
                }else if ([schoolbagStatus  isEqual: @"has_pre_borrow"]) {
                    [tempSelf.lijijieyueBtn setTitle:@"您预借的书包与此书包不匹配" forState:UIControlStateNormal];
                    tempSelf.lijijieyueBtn.enabled = NO;
                }else if ([schoolbagStatus  isEqual: @"has_borrowed"]) {
                    if (kIsBookMode) {
                        [tempSelf.lijijieyueBtn setTitle:@"一键借阅" forState:UIControlStateNormal];
                        tempSelf.lijijieyueBtn.enabled = YES;
                    }else{
                    [tempSelf.lijijieyueBtn setTitle:@"您当前有书包正在借阅中" forState:UIControlStateNormal];
                    tempSelf.lijijieyueBtn.enabled = NO;
                    }
                }else if ([schoolbagStatus  isEqual: @"borrowed_by_other"]) {
                    [tempSelf.lijijieyueBtn setTitle:@"书包已经被其他人预借了" forState:UIControlStateNormal];
                    tempSelf.lijijieyueBtn.enabled = NO;
                }
                NSDictionary *obj = responseObject[@"data"][@"package_info"];
                ZHSSchoolbag *schoolbag = [ZHSSchoolbag modelWithJsonDicUseSelfMap:obj[@"package_setting"]];
                NSArray *books = obj[@"package_setting"][@"books_list"];
                NSMutableArray *booklist = [@[] mutableCopy];
                for (NSDictionary*dic in books) {
                    ZHSBooks*book = [ZHSBooks modelWithJsonDicWithoutMap:dic];
                    [booklist addObject:book];
                }
                schoolbag.books_list = booklist;
                [tempSelf initTableviewWith:schoolbag];
                [UIView animateWithDuration:1.0f animations:^{
                    tempSelf.schoolbagView.frame = CGRectMake(0, 0, kWidth, 357);
                }];
            }
        }];
    }else{
        [TNToast showWithText:@"请扫描书包的二维码"];
    }
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _isHidden = self.navigationController.navigationBar.hidden;
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = @"一键借阅";
    [self createLeftBarItemWithImage];
    self.schoolbagView.frame = CGRectMake(0, kHight, kWidth, 357);

    
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSPictureBookMuseumTableViewCell"];
        
    _handle.delegate = self;
    [self.view addSubview:self.schoolbagView];

}
-(void)back{
    _isBack = YES;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    if (_isBack) {
        self.navigationController.navigationBar.hidden = _isHidden;
    }
}

- (IBAction)yijianjieyue:(id)sender {

    NSString *path = [NSString stringWithFormat:@"%@/package/%@/borrow",kHeaderURL,_code];
    __weak typeof(self) tempSelf = self;
    [[THRequstManager sharedManager] asynPOST:path parameters:@{} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            NSDictionary *data = responseObject[@"data"];
            if ([data[@"pre_borrow"] integerValue] == 1) {
                [TNToast showWithText:responseObject[@"data"][@"reason"]];
                [tempSelf back];
            }
            else if ([data[@"pre_borrow"] integerValue] == 2) {
                [TNToast showWithText:responseObject[@"data"][@"reason"]];
                [tempSelf.navigationController pushViewController:[ZHSMyCenterOfPrepaidViewController new] animated:YES];
            }
            else if ([data[@"pre_borrow"] integerValue] == 3) {
                [TNToast showWithText:responseObject[@"data"][@"reason"]];
            }else
                [TNToast showWithText:responseObject[@"data"][@"reason"]];

        }
    }];

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
