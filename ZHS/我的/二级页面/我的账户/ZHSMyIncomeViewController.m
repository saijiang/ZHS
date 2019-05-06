//
//  ZHSMyIncomeViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/17.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSMyIncomeViewController.h"

@interface ZHSMyIncomeViewController ()<MMTableViewHandleDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(strong,nonatomic)MMTableViewHandle *handle;
@end

@implementation ZHSMyIncomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"我的收益";
}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSMyIncomeMoneyTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSMyIncomeNoteHeaderTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSMyIncomeNoteTableViewCell"];
//    [_handle registerTableCellNibWithIdentifier:@"ZHSMyJieYueJiLuLastTableViewCell"];

    
    _handle.delegate = self;
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    MMRow *row = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:125 reuseIdentifier:@"ZHSMyIncomeMoneyTableViewCell"];
    MMRow *row1 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:50 reuseIdentifier:@"ZHSMyIncomeNoteHeaderTableViewCell"];
    [section addRows:@[row,row1]];
    for (int i = 0; i < 3; i ++) {
        MMRow *row2 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:75 reuseIdentifier:@"ZHSMyIncomeNoteTableViewCell"];
 
        [section addRow:row2];
    }
    
    [table addSections:@[section]];
    _handle.tableModel = table;
    [_handle reloadTable];
    
  
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    [super viewWillDisappear:NO];
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
