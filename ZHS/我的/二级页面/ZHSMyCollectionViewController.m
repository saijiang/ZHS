//
//  ZHSMyCollectionViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/16.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSMyCollectionViewController.h"
#import "ZHSBooks.h"
#import "ZHSSchoolbag.h"
#import "THCouponVC.h"
#import "ZHSOnlyBookDetailViewController.h"

@interface ZHSMyCollectionViewController ()<MMTableViewHandleDelegate>
{
    NSMutableArray *_schoolbags;
    BOOL _isBack;
    NSInteger flog;
}
@property (strong, nonatomic) IBOutlet UIView *morenView;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(strong,nonatomic)MMTableViewHandle *handle;


@end

@implementation ZHSMyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isBack = NO;
    flog = 0;
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    if (self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = NO;
    }
    self.navigationItem.title = @"我的收藏";
//    self.tabBarHidden = YES;
    _schoolbags = [@[] mutableCopy];
}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSMyCollectionTableViewCell"];
//    [_handle registerTableCellNibWithIdentifier:@"ZHSMyJieYueJiLuLastTableViewCell"];
    __weak typeof(self)tempSelf = self;
    [_handle.tableView addPPFooterWithBlock:^{
        flog = flog+1;
        [tempSelf requestMyCollection];
    }];
    _handle.delegate = self;
    [self requestMyCollection];

   
}
-(void)reloadMyCollection{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    NSInteger num = 0;
    if (_schoolbags.count%3==0) {
        num = _schoolbags.count/3;
    }else{
        num = _schoolbags.count/3+1;
    }
    for (int i = 0; i < num; i ++) {
        NSMutableArray *ary = [@[] mutableCopy];
        if (i*3+0<_schoolbags.count) {
            [ary addObject:_schoolbags[i*3+0]];
        }
        if (i*3+1<_schoolbags.count) {
            [ary addObject:_schoolbags[i*3+1]];
        }
        if (i*3+2<_schoolbags.count) {
            [ary addObject:_schoolbags[i*3+2]];
        }
        MMRow *row = [MMRow rowWithTag:0 rowInfo:ary rowActions:@[^(ZHSSchoolbag*schoolbag){
            if (kIsBookMode) {
                ZHSOnlyBookDetailViewController *vc = [[ZHSOnlyBookDetailViewController alloc] init];
                vc.schoolbag = schoolbag;
                vc.cancelCollection = @"yes";
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                THCouponVC *vc = [[THCouponVC alloc] init];
                vc.schoolbag = schoolbag;
                vc.cancelCollection = @"yes";
                [self.navigationController pushViewController:vc animated:YES];
            }
        }] height:160 reuseIdentifier:@"ZHSMyCollectionTableViewCell"];
        [section addRow:row];

    }
//    MMRow *row1 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:160 reuseIdentifier:@"ZHSMyCollectionTableViewCell"];
    //    MMRow *row2 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:160 reuseIdentifier:@"ZHSMyJieYueJiLuLastTableViewCell"];
    
    [table addSections:@[section]];
    _handle.tableModel = table;
    [_handle reloadTable];

}
-(void)requestMyCollection{
    [[THRequstManager sharedManager] asynGET:[NSString stringWithFormat:@"%@/my-center/favorites?offset=%ld&limit=9",kHeaderURL,flog*9] withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            if ([responseObject[@"data"] count]) {
                NSArray *dataAry = responseObject[@"data"];
                [dataAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ZHSSchoolbag *schoolbag = [ZHSSchoolbag modelWithJsonDicUseSelfMap:obj];
                    NSArray *books = obj[@"books_list"];
                    NSMutableArray *booklist = [@[] mutableCopy];
                    for (NSDictionary*dic in books) {
                        ZHSBooks*book = [ZHSBooks modelWithJsonDicWithoutMap:dic];
                        [booklist addObject:book];
                    }
                    schoolbag.books_list = booklist;
                    [_schoolbags addObject:schoolbag];
                }];
                [self reloadMyCollection];

            }else{
                if (flog == 0) {
                    self.morenView.frame = self.view.bounds;
                    [self.view addSubview:self.morenView];
                }
                [_tableview removeFooter];
            }
        }
        [_tableview.footer endRefreshing];
    }];
//    [[THRequstManager sharedManager] asynPOST:[NSString stringWithFormat:@"%@/my-center/collection",kHeaderURL] parameters:@{} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
//        if (code) {
//            
//        }
//    }];
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
    if (_isBack) {
        self.navigationController.navigationBar.hidden = YES;
    }
}
- (IBAction)mashangCollection:(id)sender {
    [self back];
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
