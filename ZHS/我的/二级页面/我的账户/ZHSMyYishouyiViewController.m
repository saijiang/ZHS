//
//  ZHSMyYishouyiViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/21.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSMyYishouyiViewController.h"

@interface ZHSMyYishouyiViewController ()<MMTableViewHandleDelegate>
@property(strong,nonatomic)MMTableViewHandle *handle;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *shouyi;


@end

@implementation ZHSMyYishouyiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"已收益";
}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSMyAccountHeaderTableViewCell"];
    //    [_handle registerTableCellNibWithIdentifier:@"ZHSMyJieYueJiLuLastTableViewCell"];
    
    
    _handle.delegate = self;
    [self requestMyAccountList];
    
    
}
-(void)requestMyAccountList{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    section.headerView = [self creatview:@"2016年01月"];
    section.heightForHeader = 37;
    for (int i = 0; i <10; i ++) {
        MMRow *row = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:58 reuseIdentifier:@"ZHSMyAccountHeaderTableViewCell"];
        [section addRow:row];
    }
    [table addSections:@[section]];
    _handle.tableModel = table;
    [_handle reloadTable];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backClick:(id)sender {
    [self back];
}
-(UIView *)creatview:(NSString *)title{
    UIView *view =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 37)];
    view.backgroundColor = [[TNAppContext currentContext] getColor:@"#f0f2f2"];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(22, 9, 80, 20)];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = title;
    lable.font = [UIFont systemFontOfSize:14.0f];
    lable.textColor = [[TNAppContext currentContext] getColor:@"#323232"];
    [view addSubview:lable];
    
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(kWidth-60, 9, 40, 20)];
    lable1.textAlignment = NSTextAlignmentCenter;
    lable1.text = @"账单";
    lable1.font = [UIFont systemFontOfSize:14.0f];
    lable1.textColor = [[TNAppContext currentContext] getColor:@"#999999"];
    [view addSubview:lable1];
    return view;
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
