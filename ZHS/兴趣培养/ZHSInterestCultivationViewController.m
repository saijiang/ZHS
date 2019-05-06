//
//  ZHSInterestCultivationViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/7/13.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSInterestCultivationViewController.h"
#import "ZHSInterestCultivationDetailViewController.h"

@interface ZHSInterestCultivationViewController ()<MMTableViewHandleDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(strong,nonatomic) MMTableViewHandle *handle;
@end

@implementation ZHSInterestCultivationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tabBarHidden = NO;
    self.title = @"兴趣培养";
}
-(void)initView{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSInterestListTableViewCell"];
    _handle.delegate = self;
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    for (int i = 0; i <20; i ++) {
        MMRow *row = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:145 reuseIdentifier:@"ZHSInterestListTableViewCell"];
        [section addRow:row];
    }
    [table addSections:@[section]];
    _handle.tableModel = table;
    [_handle reloadTable];

}
-(void)tableHandle:(MMTableViewHandle *)tableHandle didSelectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath{
    
    [self.navigationController pushViewController:[ZHSInterestCultivationDetailViewController new] animated:YES];
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
