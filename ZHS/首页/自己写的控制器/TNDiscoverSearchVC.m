//
//  TNDiscoverSearchVC.m
//  searchDemo
//
//  Created by marcus on 15/7/21.
//  Copyright (c) 2015年 marcus. All rights reserved.
//

#import "TNDiscoverSearchVC.h"
//#import "THDiscoverWebView.h"

#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? YES : NO)
#define searchHistoryCount 10

@interface TNDiscoverSearchVC () <MMTableViewHandleDelegate,UISearchBarDelegate>
@property (strong,nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchTable;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;  //搜索结果
@property (strong,nonatomic) NSMutableArray * searchHistoryArray; //搜索历史
@property (strong,nonatomic) NSMutableArray * hotSearchArray; //热门搜索
@property (strong,nonatomic) NSMutableArray * mainArray; //搜索结果
@property (assign,nonatomic) NSInteger         page;               // 当前页码
@property (assign,nonatomic) BOOL noMore; //没有更多数据  默认为NO
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSearchTableHeight;
@property (strong,nonatomic) MMTableViewHandle * searchTableHandle;
@property (strong,nonatomic) MMTableViewHandle * mainTableHandle;
@property (strong,nonatomic) NSString * searchContent; //记录搜索条件
@property (weak, nonatomic) IBOutlet UIView *noDataView; //没有数据时现实的View
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@end


@implementation TNDiscoverSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self requestHotSearch];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init
-(void)initView{  
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom;
//    _mainTable.hidden = YES;
    _noDataView.hidden = YES;
    
//    初始化 searchBar
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(8, 3, kWidth-100, 28)];
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"请输入您感兴趣的内容..."];
    if (!IOS7) {
        [(UIView*)[[_searchBar subviews] objectAtIndex:0] removeFromSuperview];
    }
    self.navigationItem.titleView = _searchBar;
    [_searchBar becomeFirstResponder];
    
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [backButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = backButton;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
//    __weak __typeof(self) tempSelf = self;
//    [_mainTable addTNGIFHeaderWithBlock:^{
//        tempSelf.page = 1;
//        [tempSelf requestDataWithContent:tempSelf.searchContent];
//    }];
//    
//    [_mainTable addTNGIFFooterWithBlock:^{
//        tempSelf.page ++;
//        [tempSelf requestDataWithContent:tempSelf.searchContent];
//    }];
}

-(void)initData{
    _searchTableHandle = [MMTableViewHandle handleWithTableView:_searchTable];
    [_searchTableHandle registerTableCellNibWithIdentifier:@"TNDiscoverSearchHistoryCell"];
    [_searchTableHandle registerTableCellNibWithIdentifier:@"TNDiscoverHotSearchCell"];
    _searchTableHandle.delegate = self;
    
//    _mainTableHandle = [MMTableViewHandle handleWithTableView:_mainTable];
//    [_mainTableHandle registerTableCellNibWithIdentifier:@"THDiscoverCell"];
//    _mainTableHandle.delegate = self;
    
    __weak __typeof(self) tempSelf = self;
    [_searchTableHandle setScrollDidScrollBlock:^(MMTableViewHandle *tableHandle, CGPoint offset) {
        
        [tempSelf.searchBar resignFirstResponder];
    }];
    
    _searchHistoryArray = [[NSMutableArray alloc]init];
    _hotSearchArray = [[NSMutableArray alloc]init];
    _mainArray = [[NSMutableArray alloc]init];
    
//    _page = 1;
    _noMore = NO;
}

//请求 热门搜索数据
-(void)requestHotSearch{
    [_hotSearchArray addObjectsFromArray:@[@"小王子",@"心理健康",@"品格养成",@"跳芭蕾",@"大脚丫",@"大脚丫",@"大脚丫",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾",@"大脚丫跳",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾",@"大脚丫跳芭蕾"]];
    [self reloadDataForSearchTable];
}

//加载热搜词 和 历史搜索记录
-(void)reloadDataForSearchTable{
    if (_searchTable.hidden) {
        _searchTable.hidden = NO;
    }
    [self readDataFromPlistFile];
    MMTable * table = [MMTable tagWithTag:0];
    _searchTableHandle.tableModel = table;
    __weak __typeof(self) tempSelf = self;
    //刷新热门搜索区域数据
    if (_hotSearchArray && _hotSearchArray.count>0) {
        MMSection * section = [MMSection tagWithTag:0];
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 30)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kWidth, 29)];
        title.font = [UIFont boldSystemFontOfSize:14];
        title.backgroundColor = [UIColor whiteColor];
        title.textColor = UIColorWithCode(0x666666);
        title.text = [NSString stringWithFormat:@"%@", @"热门搜索"];
        [view addSubview:title];
        section.headerView = view;
        section.heightForHeader = 40;
        UIView * footView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 5)];
        footView1.backgroundColor = [UIColor whiteColor];
        UIView * footView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 15)];
        footView2.backgroundColor = UIColorWithCode(0xeeeeee);
        UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 5, kWidth, 0.5)];
        line1.backgroundColor = UIColorWithCode(0xcccccc);
        UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 14, kWidth, 0.5)];
        line2.backgroundColor = UIColorWithCode(0xcccccc);
        [footView2 addSubview:footView1];
        [footView2 addSubview:line1];
        [footView2 addSubview:line2];
        section.footerView = footView2;
        section.heightForFooter = 15;
        [table addSection:section];
        
//      将热门搜索的值每四个绑定为一组
        NSInteger icount=0;
        NSMutableArray * tempArray = [[NSMutableArray alloc]init];
        for (int i=0; i<_hotSearchArray.count; i++) {
            icount++;
            [tempArray addObject:_hotSearchArray[i]];
            if (icount==4) {
                MMRow * row = [MMRow rowWithTag:0
                                        rowInfo:tempArray
                                     rowActions:^(NSString * tempStr){
//                                         tempSelf.page = 1;
                                         [self writeDataWithContent:tempStr];
                                         tempSelf.searchBar.text = tempStr;
//                                         [tempSelf requestDataWithContent:tempStr];
                                     }
                                         height:40
                                reuseIdentifier:@"TNDiscoverHotSearchCell"];
                [section addRow:row];
                icount = 0;
                tempArray = [[NSMutableArray alloc]init];
            }
        }
        if (tempArray.count>0){
            MMRow * row = [MMRow rowWithTag:0
                                    rowInfo:tempArray
                                 rowActions:^(NSString * tempStr){
//                                     tempSelf.page = 1;
                                     [self writeDataWithContent:tempStr];
//                                     [tempSelf requestDataWithContent:tempStr];
                                 }
                                     height:40
                            reuseIdentifier:@"TNDiscoverHotSearchCell"];
            [section addRow:row];
        }
    }
    
//    刷新历史搜索区域数据
    MMSection * section1 = [MMSection tagWithTag:0];
    UIView * view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 30)];
    view1.backgroundColor = [UIColor whiteColor];
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 39, kWidth, 0.5)];
    line.backgroundColor = UIColorWithCode(0xDFDFDF);
    [view1 addSubview:line];
    UILabel *title1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kWidth, 30)];
    title1.font = [UIFont boldSystemFontOfSize:14];
    title1.backgroundColor = [UIColor whiteColor];
    title1.textColor = UIColorWithCode(0x666666);
    title1.text = [NSString stringWithFormat:@"%@", @"历史搜索"];
    [view1 addSubview:title1];
    section1.headerView = view1;
    section1.heightForHeader = 40;
    [table addSection:section1];
    if (_searchHistoryArray.count>0) {
        for (int i=0; i<_searchHistoryArray.count; i++) {
            NSString * searchStr = _searchHistoryArray[i];
            MMRow * row1 = [MMRow rowWithTag:0
                                     rowInfo:searchStr
                                  rowActions:nil
                                      height:44
                             reuseIdentifier:@"TNDiscoverSearchHistoryCell"];
            [section1 addRow:row1];
        }
        UIButton * footButton = [[UIButton alloc]initWithFrame:CGRectMake((kWidth-120)/2, 10, 120, 30)];
        footButton.layer.borderColor = UIColorWithCode(0x999999).CGColor;
        footButton.layer.borderWidth = 0.5;
        footButton.layer.cornerRadius = 5;
        footButton.backgroundColor = [UIColor whiteColor];
        [footButton setTitleColor:UIColorWithCode(0x666666) forState:UIControlStateNormal];
        footButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [footButton setTitle:@"清空历史搜索记录" forState:UIControlStateNormal];
        [footButton addTarget:self action:@selector(clearDataFromPlistFile) forControlEvents:UIControlEventTouchUpInside];
        UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 50)];
        tempView.backgroundColor = [UIColor whiteColor];
//        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 49, kWidth, 0.5)];
//        line.backgroundColor = UIColorWithCode(0xDFDFDF);
//        [tempView addSubview:line];
        [tempView addSubview:footButton];
        section1.heightForFooter = 50;
        section1.footerView = tempView;
        
    }else{
        UIView * view2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 30)];
        view2.backgroundColor = [UIColor whiteColor];
        UILabel *title2 = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kWidth, 30)];
        title2.font = [UIFont systemFontOfSize:14];
        title2.backgroundColor = [UIColor whiteColor];
        title2.textColor = UIColorWithCode(0x999999);
        title2.textAlignment = NSTextAlignmentCenter;
        title2.text = [NSString stringWithFormat:@"%@", @"没有搜索记录"];
        [view2 addSubview:title2];
        section1.heightForFooter = 40;
        section1.footerView = view2;
    }
    
        [_searchTableHandle reloadTable];
}


//根据搜索条件查询数据
-(void)requestDataWithContent:(NSString *)content{
    if (!content || [content isEqualToString:@""]) {
        return;
    }
//    if (_page==1) {
//         [TNToast showLoadingToast];
//        _searchContent = content;
//        _mainTable.hidden = YES;
//        _searchTable.hidden = YES;
//        _showLabel.text = @"亲，正在努力加载数据！";
//        _noDataView.hidden = NO;
//    }
    [_searchBar resignFirstResponder];


}



-(void)tableHandle:(MMTableViewHandle *)tableHandle didSelectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath{
    if (tableHandle == _searchTableHandle && indexPath.section==1)
    {
        NSString * content = row.rowInfo;
//        self.page = 1;
        self.searchBar.text = content;
        [self writeDataWithContent:content];
        [self requestDataWithContent:content];
    }
}

#pragma mark UISearchBarDelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    _mainTable.hidden = YES;
    _noDataView.hidden = YES;
    [self reloadDataForSearchTable];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    _page = 1;
    [self writeDataWithContent:searchBar.text];
    [self requestDataWithContent:searchBar.text];
}

#pragma mark readOrWriteSearchHistoryPlist
//获取文件路径
- (NSString *)getPlistFilePath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths  objectAtIndex:0];
    DLog(@"path = %@",path);
    NSString *filename=[path stringByAppendingPathComponent:@"discoverSearchHistory.plist"];
    return filename;
}

//检查文件是否存在，不存在需要创建
-(BOOL)checkFileIsExist{
    NSString * filename =[self getPlistFilePath];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filename]) {
        //文件存在
        return YES;
    }else{
        //文件不存在
        [fm createFileAtPath:filename contents:nil attributes:nil];
        NSMutableArray *searchName = [[NSMutableArray alloc] initWithCapacity:0];
        NSDictionary *dic = @{@"searchName":searchName};
        [dic writeToFile:filename atomically:YES];
        return NO;
    }
}

//读取数据
-(void)readDataFromPlistFile{
    if ([self checkFileIsExist]) {
        NSString * filename =[self getPlistFilePath];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filename];
        [_searchHistoryArray removeAllObjects];
        _searchHistoryArray = [NSMutableArray arrayWithArray: [dic objectForKey:@"searchName"]];
    }else{
        [_searchHistoryArray removeAllObjects];
    }
}

//写入数据
-(void)writeDataWithContent:(NSString*)content{
    [self checkFileIsExist];
    NSString * filename =[self getPlistFilePath];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filename];
    NSMutableArray *searchArray = [NSMutableArray arrayWithArray:[dic objectForKey:@"searchName"]];
    //    搜索内容存在于搜索记录中，调整顺序
    if ([searchArray containsObject:content]) {
        [searchArray removeObject:content];
        [searchArray insertObject:content atIndex:0];
    }else{
        [searchArray insertObject:content atIndex:0];
    }
    //    搜索记录大于最大限制值，删除多余记录
    while (searchArray.count>searchHistoryCount) {
        [searchArray removeLastObject];
    }
    dic = @{@"searchName":searchArray};
    [dic writeToFile:filename atomically:YES];
}

//清空历史记录
-(void)clearDataFromPlistFile{
    TNBlockAlertView *alert = [[TNBlockAlertView alloc]initWithTitle:@"" message:@"清除全部查询历史记录吗？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"好", nil];
    [alert setBlockForOk:^{
        [self checkFileIsExist];
        NSString * filename =[self getPlistFilePath];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filename];
        NSMutableArray *searchArray = [NSMutableArray arrayWithArray:[dic objectForKey:@"searchName"]];
        [searchArray removeAllObjects];
        dic = @{@"searchName":searchArray};
        [dic writeToFile:filename atomically:YES];
        [self reloadDataForSearchTable];
        
    }];
    [alert show];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    [_searchBar resignFirstResponder];
    

}

#pragma mark - utils
- (CGFloat)getCellHeight
{
    return ScreenWidth*0.5f + 30.f;
}



@end
