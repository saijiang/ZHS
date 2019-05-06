//
//  ZHSShoolbagDetailViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/17.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSShoolbagDetailViewController.h"
#import "THCouponVC.h"
#import "ZHSOnlyBookDetailViewController.h"

@interface ZHSShoolbagDetailViewController ()<MMTableViewHandleDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) MMTableViewHandle *handle;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;


@end

@implementation ZHSShoolbagDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLeftBarItemWithImage];
    if (self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = NO;
    }
    // Do any additional setup after loading the view from its nib.
    if (_isSmile) {
        _image.image = [UIImage imageNamed:@"xiao_book"];
        self.titleLable.text = kIsBookMode?@"恭喜您预借成功，您可以到“我的”查看。\n我们还为您推荐以下类似的绘本。" : @"恭喜您预借成功，您可以到“我的”查看。\n我们还为您推荐以下类似的书包。";
    }else{
        
    }
}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
//    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSPictureBookMuseumTableViewCell"];
//    [_handle registerTableCellNibWithIdentifier:@"ZHSTheFourPieceTableViewCell"];
//    [_handle registerTableCellNibWithIdentifier:@"ZHSTheFivePieceTableViewCell"];
//    [_handle registerTableCellNibWithIdentifier:@"ZHSTuiJianTableViewCell"];
//    
    _handle.delegate = self;
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    __weak typeof(self)weakSelf = self;

    [_schoolbags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMRow *row;
        if (kIsBookMode) {
            row = [MMRow rowWithTag:0 rowInfo:obj rowActions:@[^{
                ZHSOnlyBookDetailViewController *vc = [[ZHSOnlyBookDetailViewController alloc] init];
                vc.schoolbag = obj;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }] height:267 reuseIdentifier:@"ZHSPictureBookMuseumTableViewCell"];
        }else{
            row = [MMRow rowWithTag:0 rowInfo:obj rowActions:@[^{
            
            THCouponVC *vc = [[THCouponVC alloc] init];
            vc.schoolbag = obj;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }] height:267 reuseIdentifier:@"ZHSPictureBookMuseumTableViewCell"];
        }
        [section addRow:row];
    }];
    
    [table addSection:section];
    _handle.tableModel = table;
    [_handle reloadTable];
//    MMRow *row = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:140 reuseIdentifier:@"TNImageycleTableViewCell"];
//    MMRow *row1 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:120 reuseIdentifier:@"ZHSTheFourPieceTableViewCell"];
//    MMRow *row2 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:140 reuseIdentifier:@"ZHSTheFivePieceTableViewCell"];
//    MMRow *row3 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:40 reuseIdentifier:@"ZHSTuiJianTableViewCell"];
//    
//    [section addRow:row1];
//    [section addRow:row2];
//    [section addRow:row3];


}
-(void)tableHandle:(MMTableViewHandle *)tableHandle didSelectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath{
    if ([row.reuseIdentifier isEqualToString:@"ZHSPictureBookMuseumTableViewCell"]) {
        THCouponVC *vc = [THCouponVC new];
        vc.schoolbag = _schoolbags[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(void)initView{
    
    self.navigationItem.title = kIsBookMode?@"推荐绘本":@"推荐书包";
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
