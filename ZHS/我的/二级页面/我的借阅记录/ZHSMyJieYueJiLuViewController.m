//
//  ZHSMyJieYueJiLuViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/17.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSMyJieYueJiLuViewController.h"
#import "ZHSBorrowLog.h"
#import "ZHSSchoolbag.h"
#import "ZHSBooks.h"
#import "ZHSBorrowLogsDetailViewController.h"

@interface ZHSMyJieYueJiLuViewController ()<MMTableViewHandleDelegate>
{
    __block NSMutableArray *_borrowlogs;
    BOOL _isBack;
    NSInteger _flog;// 标记借阅记录
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(strong,nonatomic)MMTableViewHandle *handle;
@property (strong, nonatomic) IBOutlet UIView *defView;
@end

@implementation ZHSMyJieYueJiLuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    if (self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = NO;
    }
    self.navigationItem.title = @"借阅记录";
//    self.tabBarHidden = YES;
    _borrowlogs = [@[] mutableCopy];
    _flog = 0;
}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSMyJieYueJiLuTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSMyJieYueJiLuLastTableViewCell"];
    
    _handle.delegate = self;
    __weak typeof(self)weakSelf = self;
    [_handle.tableView addPPFooterWithBlock:^{
        _flog = _flog+1;
        [weakSelf requestborrowLogs];
        
    }];
    [self requestborrowLogs];
    
}
-(void)reloadBorrowLogsData{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    [_borrowlogs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMRow *row = [MMRow rowWithTag:0 rowInfo:obj rowActions:nil height:160 reuseIdentifier:@"ZHSMyJieYueJiLuTableViewCell"];
        [section addRow:row];
        
    }];
    
    
//        MMRow *row2 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:160 reuseIdentifier:@"ZHSMyJieYueJiLuLastTableViewCell"];
//        [section addRow:row2];
    [table addSections:@[section]];
    _handle.tableModel = table;
    [_handle reloadTable];
}
-(void)requestborrowLogs{
    
    NSString *path = [NSString stringWithFormat:@"%@/my-center/borrow-log?offset=%ld&limit=10",kHeaderURL,_flog*10];
//    NSString *path = [NSString stringWithFormat:@"%@/my-center/borrow-log",kHeaderURL];

    __weak typeof(self) tempSelf = self;
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        [tempSelf.tableview.footer endRefreshing];
        if (code == 1) {
            NSArray *dataAry = responseObject[@"data"];
            [dataAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dic = obj;
                ZHSBorrowLog *log = [ZHSBorrowLog modelWithJsonDicUseSelfMap:dic];
                ZHSSchoolbag *schoolbag = [ZHSSchoolbag modelWithJsonDicUseSelfMap:dic[@"package_info"][@"package_setting"]];
                NSArray *books = dic[@"package_info"][@"package_setting"][@"books_list"];
                NSMutableArray *booklist = [@[] mutableCopy];
                for (NSDictionary*dic in books) {
                    ZHSBooks*book = [ZHSBooks modelWithJsonDicWithoutMap:dic];
                    [booklist addObject:book];
                }
                schoolbag.books_list = booklist;
                log.schoolbag = schoolbag;
                [_borrowlogs addObject:log];
            }];
            if (_borrowlogs.count == 0) {
                tempSelf.defView.frame = CGRectMake(0, 0, kWidth, kHight);
                [tempSelf.view addSubview:tempSelf.defView];
            }else
                [tempSelf reloadBorrowLogsData];
        }
    }];
}

-(void)tableHandle:(MMTableViewHandle *)tableHandle didSelectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath{
    [tableHandle.tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([row.reuseIdentifier isEqualToString:@"ZHSMyJieYueJiLuLastTableViewCell"]) {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [TNFlowUtil startGoSchoolbag];
        }else{
    ZHSBorrowLogsDetailViewController *vc = [ZHSBorrowLogsDetailViewController new];
    vc.borrowlog = _borrowlogs[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
        }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)back{
    _isBack = YES;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:NO];
    if (_isBack) {
        self.navigationController.navigationBar.hidden = YES;
    }

}

- (IBAction)mashangjieyue:(id)sender {
    [TNFlowUtil startGoSchoolbag];
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
