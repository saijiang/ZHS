//
//  ZHSMyCenterOrderViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/7/12.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSMyCenterOrderViewController.h"

@interface ZHSMyCenterOrderViewController ()<MMTableViewHandleDelegate>
@property(strong,nonatomic)MMTableViewHandle *handle;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation ZHSMyCenterOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"订单详情";
}

-(void)initView{
    _handle = [MMTableViewHandle handleWithTableView:self.tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderAddressTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderCommodityTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderPayStyleTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderLastTableViewCell"];
    _handle.delegate = self;
    
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    MMRow *row1 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:91 reuseIdentifier:@"ZHSOrderAddressTableViewCell"];
    [section addRow:row1];
    MMRow *row2 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:106 reuseIdentifier:@"ZHSOrderCommodityTableViewCell"];
    [section addRow:row2];
    MMRow *row3 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:56 reuseIdentifier:@"ZHSOrderPayStyleTableViewCell"];
    [section addRow:row3];
    MMRow *row4 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:100 reuseIdentifier:@"ZHSOrderLastTableViewCell"];
    [section addRow:row4];
    [table addSections:@[section]];
    _handle.tableModel = table;
    [_handle reloadTable];}
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
