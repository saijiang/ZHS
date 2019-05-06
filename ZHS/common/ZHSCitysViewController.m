//
//  ZHSCitysViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/24.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSCitysViewController.h"

@interface ZHSCitysViewController ()<MMTableViewHandleDelegate>
{
    NSMutableDictionary *_youeryaunDic;
    
    NSDictionary*_kindergarten_infoDic;
    NSDictionary*_city_infoDic;

    
    NSArray *_cityArray; // 标记选择了哪个市
    NSInteger logRow;
//    MMRow*logRow1;// 标记幼儿园的那个点击row

}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UITableView *youeryuanListTableview;
@property(strong,nonatomic)MMTableViewHandle *handle;
@property(strong,nonatomic)MMTableViewHandle *handle1;

@end

@implementation ZHSCitysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"选择幼儿园";
    _youeryaunDic = [@{} mutableCopy];
    
    self.youeryuanListTableview.frame = CGRectMake(kWidth, 0, kWidth, kHight);
    [self.view addSubview:self.youeryuanListTableview];
    
}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
//    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderListOfHeaderTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderlistTableViewCell"];
    if ([TNAppContext currentContext].citys.count) {
        [self reloadcityWith:nil];

    }else{
        [self requestCity];
    }
    _handle.delegate = self;
    
    _handle1 = [MMTableViewHandle handleWithTableView:_youeryuanListTableview];
    //    [_handle registerTableCellNibWithIdentifier:@"ZHSOrderListOfHeaderTableViewCell"];
    [_handle1 registerTableCellNibWithIdentifier:@"ZHSOrderlistTableViewCell"];
//    [self reloadcityWith:nil];
    _handle1.delegate = self;
    
}
// 刷新幼儿园
-(void)reloadYoueryuanWith:(NSArray*)youeryaun{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    
    [youeryaun enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        NSInteger num = 4;
        if ([obj[@"class_info"] count]==0) {
            num = 5;
        }
        MMRow *row1 = [MMRow rowWithTag:num rowInfo:obj rowActions:nil height:44 reuseIdentifier:@"ZHSOrderlistTableViewCell"];
        [section addRow:row1];
        
        if (idx == youeryaun.count-1) {
            [table addSections:@[section]];
            _handle1.tableModel = table;
            [UIView animateWithDuration:0.5 animations:^{
                self.youeryuanListTableview.frame = CGRectMake(0, 0, kWidth, kHight);
            }];
            [_handle1 reloadTable];
        }
    }];

  
    
}
-(void)requestCity{
    NSString *path = [NSString stringWithFormat:@"%@/area",kHeaderURL];
    if ([TNAppContext currentContext].citys.count <1 ) {
        [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            if (code == 1) {
                [TNAppContext currentContext].citys = responseObject[@"data"];
                [self reloadcityWith:nil];

            }else{
                [TNToast showWithText:responseObject[@"message"]];
            }
        }];
        
    }
}
// 刷新市
-(void)reloadcityWith:(NSArray*)city{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];

    [city?city:[TNAppContext currentContext].citys enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        DLog(@"type_id ==========%@",obj[@"type_id"]);
        MMRow *row1 = [MMRow rowWithTag:[obj[@"type_id"] integerValue] rowInfo:obj rowActions:nil height:44 reuseIdentifier:@"ZHSOrderlistTableViewCell"];
        [section addRow:row1];
        if (idx == (city?city:[TNAppContext currentContext].citys).count-1) {
            [table addSections:@[section]];
            _handle.tableModel = table;
            [_handle reloadTable];
        }
    }];

}
-(void)tableHandle:(MMTableViewHandle *)tableHandle didSelectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath{
    if (tableHandle == _handle) {
        logRow = row.tag;
        if (row.tag ==1) {
            _cityArray = row.rowInfo[@"sub_info"];
        }
        if ([row.rowInfo[@"sub_info"] count] == 0) {
            _city_infoDic = row.rowInfo;
            [self requestYoueryuan:row.rowInfo[@"id"]];
        }else
            [self reloadcityWith:row.rowInfo[@"sub_info"]];
    }
    if (tableHandle == _handle1) {
        logRow = row.tag;
        if ([row.rowInfo[@"class_info"] count] == 0) {
//            [self requestYoueryuan:row.rowInfo[@"id"]];
            [self.navigationController popViewControllerAnimated:YES];
            self.myblock(row.rowInfo,_kindergarten_infoDic,_city_infoDic);
        }else
        {
        _kindergarten_infoDic  = row.rowInfo;
        [self reloadYoueryuanWith:row.rowInfo[@"class_info"]];
        }
    }

}
-(void)requestYoueryuan:(NSString*)ID{
    NSString *path = [NSString stringWithFormat:@"%@/school?district_id=%@",kHeaderURL,ID];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            _youeryaunDic = responseObject[@"data"];
            [self reloadYoueryuanWith:responseObject[@"data"]];
        }else{
            [TNToast showWithText:responseObject[@"message"] duration:0.5];
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)back{
    switch (logRow) {
        case 1:
        {
            [self reloadcityWith:[TNAppContext currentContext].citys];
        }
            break;
        case 2:
        {
            [self reloadcityWith:_cityArray];
        }
            break;
        case 3:
        {
            [UIView animateWithDuration:0.5 animations:^{
                self.youeryuanListTableview.frame = CGRectMake(kWidth, 0, kWidth, kHight);
            }];
        }
            break;
        case 4:
        {
            [self reloadYoueryuanWith:(NSArray*)_youeryaunDic];
        }
            break;
            
        default:
        {
            [self.navigationController popViewControllerAnimated:YES];
 
        }
            break;
    }
    logRow = logRow-1;

    
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
