//
//  ZHSOrderViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/18.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSOrderViewController.h"
#import "ZHSOrderlistTableViewCell.h"
#import "ZHSOrderInputTableViewCell.h"
#import "ZHSOrderListOfHeaderTableViewCell.h"

@interface ZHSOrderViewController ()<MMTableViewHandleDelegate>
{
    NSMutableArray *_city;
    NSArray *_privenceAry;
    NSString *_privence;// 省
    
    NSArray *_cityAry;
    NSString *_cityStr;//市
    
    NSArray *_countyAry;
    NSString *_county;// 县
    
    NSArray *_huibenguanAry;
    NSString *_huibenguanStr;// 绘本馆
    
    MMRow*logRow;
    NSIndexPath *indexpath;//  选中的indexpath
}
@property (weak, nonatomic) IBOutlet UITableView *listTableview;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(nonatomic,strong)MMTableViewHandle *handle;
@property(nonatomic,strong)MMTableViewHandle *listhandle;

@end

@implementation ZHSOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.listTableview.frame = CGRectMake(kWidth, 64, kWidth-47, kHight);
    [self.view addSubview:self.listTableview];
    self.navigationItem.title = @"借阅订单";
    [self createLeftBarItemWithImage];
//    self.tabBarHidden = YES;
    _city = [NSMutableArray arrayWithArray:@[@{@"title":@"河南省",@"list":@[
  @{@"title":@"郑州市",@"list":
  @[@{@"title":@"金水区",@"list":@[@{@"title":@"金水区绘本管"},@{@"title":@"金水区绘本馆"},@{@"title":@"金水区绘本馆"}]},
  @{@"title":@"郑东新区",@"list":@[@{@"title":@"郑东新区绘本管"},@{@"title":@"郑东新区绘本馆"},@{@"title":@"郑东新区绘本馆"}]},
  @{@"title":@"中原区",@"list":@[@{@"title":@"中原区绘本管"},@{@"title":@"中原区绘本馆"},@{@"title":@"中原区绘本馆"}]}
  ]},
  @{@"title":@"开封市",@"list":
  @[@{@"title":@"龙亭区",@"list":@[@{@"title":@"龙亭区绘本管"},@{@"title":@"龙亭区绘本馆"},@{@"title":@"龙亭区绘本馆"}]},
          @{@"title":@"金明区",@"list":@[@{@"title":@"金明区绘本管"},@{@"title":@"金明区绘本馆"},@{@"title":@"金明区绘本馆"}]},
          @{@"title":@"通许县",@"list":@[@{@"title":@"通许县绘本管"},@{@"title":@"通许县绘本馆"},@{@"title":@"通许县绘本馆"}]}
            
            ]},
  @{@"title":@"漯河市",@"list":
        @[@{@"title":@"郾城区",@"list":@[@{@"title":@"郾城区绘本管"},@{@"title":@"郾城区绘本馆"},@{@"title":@"郾城区绘本馆"}]},
          @{@"title":@"源汇区",@"list":@[@{@"title":@"源汇区绘本管"},@{@"title":@"源汇区绘本馆"},@{@"title":@"源汇区绘本馆"}]},
          @{@"title":@"舞阳县",@"list":@[@{@"title":@"舞阳县绘本管"},@{@"title":@"舞阳县绘本馆"},@{@"title":@"舞阳县绘本馆"}]}
            
            ]}]
                                                 }]];
    [self initListView];

    
}
// 判断返回@listTableview
-(void)backReloadlisttableview{
    if (!logRow||logRow.tag == 0) {
        self.backgroundView.hidden = YES;
        [UIView animateWithDuration:0.8 animations:^{
            self.listTableview.frame = CGRectMake(kWidth, 64, kWidth-47, kHight);
        } completion:^(BOOL finished) {

        }];
    }else{
    if (logRow.tag == 1) {
        [self reloadProvence];
    }
    if (logRow.tag == 2) {
        [self reloadcityWith:_cityAry];
    }
    if (logRow.tag == 3) {
        [self reloadCountyWith:_countyAry];
    }
        logRow.tag = logRow.tag-1;

    }
}
// 刷新省
-(void)reloadProvence{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    MMRow *row = [MMRow rowWithTag:0 rowInfo:nil rowActions:@[^{
        [self backReloadlisttableview];
    }]
                            height:44 reuseIdentifier:@"ZHSOrderListOfHeaderTableViewCell"];
    [section addRows:@[row]];
    [_city enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        MMRow *row1 = [MMRow rowWithTag:1 rowInfo:obj rowActions:nil height:38 reuseIdentifier:@"ZHSOrderlistTableViewCell"];
        [section addRow:row1];
    }];
    [table addSections:@[section]];
    _listhandle.tableModel = table;
    _privenceAry = _cityAry;
    [_listhandle reloadTable];

}
// 刷新市
-(void)reloadcityWith:(NSArray*)city{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    MMRow *row2 = [MMRow rowWithTag:0 rowInfo:nil rowActions:@[^{
        [self backReloadlisttableview];
    }] height:44 reuseIdentifier:@"ZHSOrderListOfHeaderTableViewCell"];
    [section addRow:row2];
    [city enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        MMRow *row1 = [MMRow rowWithTag:2 rowInfo:obj rowActions:nil height:38 reuseIdentifier:@"ZHSOrderlistTableViewCell"];
        [section addRow:row1];
    }];
    [table addSections:@[section]];
    _listhandle.tableModel = table;
    _cityAry = city;
    [_listhandle reloadTable];


}
// 刷新区、县
-(void)reloadCountyWith:(NSArray*)county{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    MMRow *row2 = [MMRow rowWithTag:0 rowInfo:nil rowActions:@[^{
        [self backReloadlisttableview];
    }] height:44 reuseIdentifier:@"ZHSOrderListOfHeaderTableViewCell"];
    [section addRow:row2];
    [county enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        MMRow *row1 = [MMRow rowWithTag:3 rowInfo:obj rowActions:nil height:38 reuseIdentifier:@"ZHSOrderlistTableViewCell"];
        [section addRow:row1];
    }];
    [table addSections:@[section]];
    _countyAry = county;
    _listhandle.tableModel = table;
    [_listhandle reloadTable];
}
// 刷新绘本馆
-(void)reloadHuiBenGuanWith:(NSArray*)huibenguan{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    MMRow *row2 = [MMRow rowWithTag:0 rowInfo:nil rowActions:@[^{
        [self backReloadlisttableview];
    }] height:44 reuseIdentifier:@"ZHSOrderListOfHeaderTableViewCell"];
    [section addRow:row2];
    [huibenguan enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        MMRow *row1 = [MMRow rowWithTag:4 rowInfo:obj rowActions:nil height:38 reuseIdentifier:@"ZHSOrderlistTableViewCell"];
        [section addRow:row1];
    }];
    [table addSections:@[section]];
    _listhandle.tableModel = table;
    _huibenguanAry  = huibenguan;
    [_listhandle reloadTable];
}

-(void)initListView{
    
    _listhandle = [MMTableViewHandle handleWithTableView:_listTableview];
    [_listhandle registerTableCellNibWithIdentifier:@"ZHSOrderListOfHeaderTableViewCell"];
    [_listhandle registerTableCellNibWithIdentifier:@"ZHSOrderlistTableViewCell"];
    [self reloadProvence];
    _listhandle.delegate = self;
    
   
}
#pragma mark ========选中cell
-(void)tableHandle:(MMTableViewHandle *)tableHandle didSelectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath{
    if (tableHandle == _handle) {
        indexpath = indexPath;
    }

    if (tableHandle == _listhandle && [cell isKindOfClass:[ZHSOrderlistTableViewCell class]]) {
        if (row.tag == 1) {
            logRow = row;
            _privence = row.rowInfo[@"title"];
            [self reloadcityWith:row.rowInfo[@"list"]];
        }
        
        if (row.tag == 2) {
            logRow = row;

            _cityStr = row.rowInfo[@"title"];
            [self reloadCountyWith:row.rowInfo[@"list"]];
        }
        if (row.tag == 3) {
            logRow = row;

            _county = row.rowInfo[@"title"];
            [self reloadHuiBenGuanWith:row.rowInfo[@"list"]];
        }
        if (row.tag == 4) {
            logRow = nil;
            _huibenguanStr = row.rowInfo[@"title"];
            self.backgroundView.hidden = YES;
            [UIView animateWithDuration:0.8 animations:^{
                self.listTableview.frame = CGRectMake(kWidth, 64, kWidth-47, kHight);
                [_handle deleteRow:[_handle lastRow] withRowAnimation:UITableViewRowAnimationFade];
                MMRow *rowof = [MMRow rowWithTag:0 rowInfo:@[@"绘 本 馆",[NSString stringWithFormat:@"%@%@%@%@",_privence,_cityStr,_county,_huibenguanStr]] rowActions:@[^(NSString *text){
                    
                },^{
                    self.backgroundView.hidden = NO;
                    [UIView animateWithDuration:0.5 animations:^{
                        self.listTableview.frame = CGRectMake(47, 64, kWidth-47, kHight);
                    }];
                }] height:44 reuseIdentifier:@"ZHSOrderInputTableViewCell"];
                [_handle.tableModel.sections[0] addRow:rowof];
                [_handle reloadTable];

            } completion:^(BOOL finished) {
                if (finished) {
                    [self reloadProvence];
                }
            }];
        }
        
    }
}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];

}
-(void)reloadListTable{

}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderHeaderTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderOfSchoolbagTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderInputTableViewCell"];

    
    
    _handle.delegate = self;
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    MMRow *row = [MMRow rowWithTag:0 rowInfo:@"订单详情" rowActions:nil height:39 reuseIdentifier:@"ZHSOrderHeaderTableViewCell"];
    
    MMRow *row1 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:100 reuseIdentifier:@"ZHSOrderOfSchoolbagTableViewCell"];
    MMRow *row2 = [MMRow rowWithTag:0 rowInfo:@"填写订单" rowActions:nil height:39 reuseIdentifier:@"ZHSOrderHeaderTableViewCell"];
    [section addRows:@[row,row1,row2]];
    [section addRow:[MMRow rowWithTag:0 rowInfo:@[@"收 货 人"] rowActions:@[^(NSString *text){
        
    }] height:44 reuseIdentifier:@"ZHSOrderInputTableViewCell"]];
    [section addRow:[MMRow rowWithTag:0 rowInfo:@[@"手    机"] rowActions:@[^(NSString *text){
        
    }] height:44 reuseIdentifier:@"ZHSOrderInputTableViewCell"]];
    [section addRow:[MMRow rowWithTag:0 rowInfo:@[@"详细地址"] rowActions:@[^(NSString *text){
        
    }] height:44 reuseIdentifier:@"ZHSOrderInputTableViewCell"]];
    [section addRow:[MMRow rowWithTag:0 rowInfo:@[@"绘 本 馆",[NSString stringWithFormat:@"%@%@%@%@",_privence,_cityStr,_county,_huibenguanStr]] rowActions:@[^(NSString *text){
        
    },^{
        self.backgroundView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.listTableview.frame = CGRectMake(47, 64, kWidth-47, kHight);
        }];
    }] height:44 reuseIdentifier:@"ZHSOrderInputTableViewCell"]];
    [table addSections:@[section]];
    _handle.tableModel = table;
    [_handle reloadTable];
    
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
