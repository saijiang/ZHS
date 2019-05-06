//
//  THCouponVC.m
//  Tuhu
//
//  Created by 邢小迪 on 15/7/31.
//  Copyright (c) 2015年 telenav. All rights reserved.
//

#import "THCouponVC.h"
#import "TNImageycleTableViewCell.h"
#import "ZHSSchoolbagDetailMiaoShuTableViewCell.h"
#import "ZHSSchoolbagXinXiListTableViewCell.h"
#import "ZHSOrderViewController.h"
#import "ZHSSchoolbag.h"
#import "ZHSBooks.h"
#import "ZHSShoolbagDetailViewController.h"
#import "ZHSMyCenterOfPrepaidViewController.h"
#define TableSize CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

@interface THCouponVC ()<UIScrollViewDelegate,MMTableViewHandleDelegate>
{
    BOOL        _isScrolling;
    NSUInteger  _flog;//标记第几个按钮被点击了
    MMTableViewHandle *_handle1;
    MMTableViewHandle *_handle2;
//    NSMutableArray      *_tables;
    NSMutableArray *_tuiJianSchoolbagsArray;
}

@property (strong, nonatomic) IBOutlet UIView *navTitleview;
@property (weak, nonatomic) IBOutlet UIButton *collectBtn;


@property (weak, nonatomic) IBOutlet UIButton *liJiJieYue;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *lines;


@property (strong, nonatomic)  UIScrollView *scrollView;
@property (strong, nonatomic) IBOutletCollection(UITableView) NSArray *tableviews;
@property (strong, nonatomic) MMTableViewHandle *handle;

@end

@implementation THCouponVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = NO;
    }
    _flog = 1000;
//    self.liJiJieYue.layer.cornerRadius = 15;
//    self.liJiJieYue.layer.borderWidth = 0.5;
//    self.liJiJieYue.layer.borderColor = [[[TNAppContext currentContext] getColor:@"#67c758"] CGColor];
//    
//    
//    self.collectBtn.layer.cornerRadius = 15;
//    self.collectBtn.layer.borderWidth = 0.5;
//    self.collectBtn.layer.borderColor = [[[TNAppContext currentContext] getColor:@"#A9B7B7"] CGColor];
    _tuiJianSchoolbagsArray = [@[] mutableCopy];
    if ([self.cancelCollection isEqualToString:@"yes"]) {
        [self.collectBtn setTitle:@"取消收藏" forState:UIControlStateNormal];
    }
    TNUser *user = [TNAppContext currentContext].user;
    if (!user.school_class_info.count) {
        [self.liJiJieYue setTitle:@"加入班级" forState:UIControlStateNormal];
    }
}

- (IBAction)navBarBtnClickAction:(UIButton*)sender{
    _flog = sender.tag;
    [_scrollView setContentOffset:CGPointMake((_flog/1000-1)*ScreenWidth, 0) animated:YES];
    for (UIView*view in self.lines) {
        if (view.tag == sender.tag) {
            view.hidden = NO;
        }else{
            view.hidden = YES;
        }
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - init
- (void)initData
{
    [TNToast hideLoadingToast];
//    _tables = [@[] mutableCopy];
    [self createLeftBarItemWithImage];
}

-(void)initView{
    
    self.navTitleview.frame = CGRectMake(0, 0, kWidth-100, 44);
    self.navigationItem.titleView = self.navTitleview;

    if (kDevice_Is_iPhoneX) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kWidth, TableSize.height-64-50 - 24)];
    }
    else
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kWidth, TableSize.height-64-50)];
    _scrollView.delegate = self;
    _scrollView.tag = 1;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.alwaysBounceHorizontal = NO;
    _scrollView.scrollEnabled = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    if (kDevice_Is_iPhoneX) {
        _scrollView.contentSize = CGSizeMake(kWidth*3, TableSize.height-64-50 - 24);
    }
    else
    _scrollView.contentSize = CGSizeMake(kWidth*3, TableSize.height-64-50);
    [self.view addSubview:_scrollView];
    
    for(int i=0; i<3; i++)
    {
        UITableView* table =_tableviews[i];
        if (kDevice_Is_iPhoneX) {
          table.frame = CGRectMake(i*kWidth, 0, kWidth, TableSize.height-64-50 - 24);
        }
        else
        table.frame = CGRectMake(i*kWidth, 0, kWidth, TableSize.height-64-50);
        [_scrollView addSubview:table];
    }
    
    
    /*
     ****************************************
     书包的详情数据table展示
     ****************************************
     */
    _handle = [MMTableViewHandle handleWithTableView:_tableviews[0]];
    [_handle registerTableCellNibWithIdentifier:@"TNImageycleTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagDetailMiaoShuTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagXinXiListTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagWenanTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];


    
    _handle.delegate = self;
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    
    NSMutableArray *imagesUrlAry = [@[] mutableCopy];
    NSLog(@"%@",_schoolbag.books_list);
    [_schoolbag.books_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHSBooks *book = obj;
        [imagesUrlAry addObject:@{@"image_url":[NSString stringWithFormat:@"%@%@",kUrl, book.images[0][@"large"]]}];
    }];
    
    MMRow *row = [MMRow rowWithTag:0 rowInfo:@{@"data":imagesUrlAry} rowActions:nil height:140 reuseIdentifier:@"TNImageycleTableViewCell"];
    [section addRow:row];//轮播图

    
    MMRow *row1 = [MMRow rowWithTag:0 rowInfo:_schoolbag rowActions:nil height:76 reuseIdentifier:@"ZHSSchoolbagDetailMiaoShuTableViewCell"];
    [section addRow:row1];
    
    MMSection*section_1 = [MMSection tagWithTag:0];
    section_1.heightForHeader = 10;
    
    /* 遍历拼接书目的名字 */
    __block NSMutableString *shumuStr  = [@"" mutableCopy];
    [self.schoolbag.books_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHSBooks *book = obj;
        if (idx == _schoolbag.books_list.count-1) {
            [shumuStr appendFormat:@"%@",book.title];
        }else
        [shumuStr appendFormat:@"%@、",book.title];
    }];
    /* 遍历拼接主题的名字 */
//    __block NSMutableString *nianlingStr  = [@"" mutableCopy];
    __block NSMutableString *zhutiStr  = [@"" mutableCopy];
    [self.schoolbag.tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
//        if ([dic[@"category"] isEqualToString:@"class_level"]) {
//            [nianlingStr appendString:dic[@"name"]];
//        }
//        if ([dic[@"category"] isEqualToString:@"theme"]) {
            [ zhutiStr appendFormat:@"%@、" ,dic[@"name"]];
//        }

    }];
    
    NSArray *dataArray = @[@{@"title":@"书    目",@"content":shumuStr},@{@"title":@"适合年级",@"content":self.schoolbag.class_level},@{@"title":@"书包标签",@"content":zhutiStr.length?[zhutiStr substringToIndex:zhutiStr.length-1]:@""}];
    [dataArray enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        NSDictionary *dic = obj;
        CGFloat H =[[TNAppContext currentContext] heightFordetailText:dic[@"content"] andWidth:kWidth-108 andFontOfSize:14.0f];
        MMRow *row = [MMRow rowWithTag:0 rowInfo:dic rowActions:nil height:MAX(39, H+21) reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
        [section_1 addRow:row];
    }];
    MMRow *ro = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:45 reuseIdentifier:@"ZHSSchoolbagXinXiListTableViewCell"];
    [section_1 addRow:ro];

    MMSection *section_2 = [MMSection tagWithTag:0];
    section_2.heightForHeader = 10;
    MMRow *row5 = [MMRow rowWithTag:0 rowInfo:_schoolbag.descriptions rowActions:nil height:[[TNAppContext currentContext] heightFordetailText:_schoolbag.descriptions andWidth:kWidth-38 andFontOfSize:14.0f]+70 reuseIdentifier:@"ZHSSchoolbagWenanTableViewCell"];
    [section_2 addRow:row5];
    [table addSections:@[section,section_1,section_2]];
    _handle.tableModel = table;
    [_handle reloadTable];
    
    /*
     ****************************************
     书的详情数据table展示
     ****************************************
     */
    
    _handle1 = [MMTableViewHandle handleWithTableView:_tableviews[1]];
    [_handle1 registerTableCellNibWithIdentifier:@"ZHSBookTitleTableViewCell"];
    [_handle1 registerTableCellNibWithIdentifier:@"ZHSBookImagsTableViewCell"];
    [_handle1 registerTableCellNibWithIdentifier:@"ZHSSchoolbagDetailMiaoShuTableViewCell"];
    [_handle1 registerTableCellNibWithIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [_handle1 registerTableCellNibWithIdentifier:@"ZHSSchoolbagWenanTableViewCell"];
    [_handle1 registerTableCellNibWithIdentifier:@"ZHSSchoolbagPLTableViewCell"];

    _handle1.delegate = self;
    MMTable *table1 = [MMTable tagWithTag:0];
    MMSection *section1 = [MMSection tagWithTag:0];
    __weak typeof(self)tempSelf = self;
    MMRow *row_1 = [MMRow rowWithTag:0 rowInfo:@{@"data":_schoolbag,@"num":[NSNumber numberWithInteger:0]} rowActions:@[^(NSInteger flog,ZHSBooks*book){
        [tempSelf reloadBooksDataWith:flog data:book];
    }] height:40 reuseIdentifier:@"ZHSBookTitleTableViewCell"];
    [section1 addRow:row_1];
    
    MMSection *section1_1 = [MMSection tagWithTag:0];
    section1_1.heightForHeader = 10;
    section1_1.heightForFooter = 10;
    NSMutableArray *imagesUrlArryay = [@[] mutableCopy];
    [((ZHSBooks*)(_schoolbag.books_list[0])).images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [imagesUrlArryay addObject:[NSString stringWithFormat:@"%@%@",kUrl,obj[@"large"]]];
    }];
    MMRow *row_1_1 = [MMRow rowWithTag:0 rowInfo:imagesUrlArryay rowActions:nil height:165 reuseIdentifier:@"ZHSBookImagsTableViewCell"];
    [section1_1 addRow:row_1_1];
    
    
    MMSection *section2 = [MMSection tagWithTag:0];
    section2.heightForFooter = 10;
    MMRow *row_1_4 = [MMRow rowWithTag:0 rowInfo:@{@"title":@"书名",@"content":[_schoolbag.books_list[0] title]} rowActions:nil height:39 reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [section2 addRow:row_1_4];
    MMRow *row_1_5 = [MMRow rowWithTag:0 rowInfo:@{@"title":@"isbn",@"content":[_schoolbag.books_list[0] isbn]} rowActions:nil height:39 reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [section2 addRow:row_1_5];
    MMRow *row_1_2 = [MMRow rowWithTag:0 rowInfo:@{@"title":@"作者",@"content":[_schoolbag.books_list[0] authors]} rowActions:nil height:39 reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [section2 addRow:row_1_2];
    MMRow *row_1_3 = [MMRow rowWithTag:0 rowInfo:@{@"title":@"出版社",@"content":[_schoolbag.books_list[0] press]} rowActions:nil height:39 reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [section2 addRow:row_1_3];

    
    MMSection *section3 = [MMSection tagWithTag:0];
    MMRow *row_1_6 = [MMRow rowWithTag:0 rowInfo:[_schoolbag.books_list[0] summary] rowActions:nil height:[[TNAppContext currentContext] heightFordetailText:[_schoolbag.books_list[0] summary] andWidth:kWidth-38 andFontOfSize:14]+70 reuseIdentifier:@"ZHSSchoolbagWenanTableViewCell"];
    [section3 addRow:row_1_6];
    
    
    [table1 addSections:@[section1,section1_1,section2,section3]];
    _handle1.tableModel = table1;
    [_handle1 reloadTable];
    
    
    /* 
     ****************************************
     书的评论数据table展示 
     ****************************************
     */
    _handle2 = [MMTableViewHandle handleWithTableView:_tableviews[2]];
    [_handle2 registerTableCellNibWithIdentifier:@"ZHSSchoolbagPLTableViewCell"];
    [_handle2 registerTableCellNibWithIdentifier:@"ZHSSchoolbagCommentTableViewCell"];
    _handle1.delegate = self;
    MMTable *table2 = [MMTable tagWithTag:0];
    MMSection *section3_1 = [MMSection tagWithTag:0];
    MMRow *row3_1 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:105 reuseIdentifier:@"ZHSSchoolbagPLTableViewCell"];
    [section3_1 addRow:row3_1];

    for (int i = 0; i < 10; i ++) {
        MMRow *row = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:100 reuseIdentifier:@"ZHSSchoolbagCommentTableViewCell"];
        [section3_1 addRow:row];
    }
    [table2 addSection:section3_1];
    _handle2.tableModel = table2;
    [_handle2 reloadTable];



    
    
}
-(void)reloadBooksDataWith:(NSInteger)flog data:(ZHSBooks*)book {
    MMTable *table1 = [MMTable tagWithTag:0];
    MMSection *section1 = [MMSection tagWithTag:0];
    __weak typeof(self)tempSelf = self;
    MMRow *row_1 = [MMRow rowWithTag:0 rowInfo:@{@"data":_schoolbag,@"num":[NSNumber numberWithInteger:flog]} rowActions:@[^(NSInteger flog,ZHSBooks*book){
        [tempSelf reloadBooksDataWith:flog data:book];
    }] height:40 reuseIdentifier:@"ZHSBookTitleTableViewCell"];
    [section1 addRow:row_1];
    
    MMSection *section1_1 = [MMSection tagWithTag:0];
    section1_1.heightForHeader = 10;
    section1_1.heightForFooter = 10;
    NSMutableArray *imagesUrlArryay = [@[] mutableCopy];

    [book.images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [imagesUrlArryay addObject:[NSString stringWithFormat:@"%@%@",kUrl,obj[@"large"]]];
    }];
    MMRow *row_1_1 = [MMRow rowWithTag:0 rowInfo:imagesUrlArryay rowActions:nil height:165 reuseIdentifier:@"ZHSBookImagsTableViewCell"];
    [section1_1 addRow:row_1_1];
    
    
    MMSection *section2 = [MMSection tagWithTag:0];
    section2.heightForFooter = 10;
    MMRow *row_1_4 = [MMRow rowWithTag:0 rowInfo:@{@"title":@"书名",@"content":book.title} rowActions:nil height:39 reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [section2 addRow:row_1_4];
    MMRow *row_1_5 = [MMRow rowWithTag:0 rowInfo:@{@"title":@"isbn",@"content":book.isbn} rowActions:nil height:39 reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [section2 addRow:row_1_5];
    MMRow *row_1_2 = [MMRow rowWithTag:0 rowInfo:@{@"title":@"作者",@"content":book.authors} rowActions:nil height:39 reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [section2 addRow:row_1_2];
    MMRow *row_1_3 = [MMRow rowWithTag:0 rowInfo:@{@"title":@"出版社",@"content":book.press} rowActions:nil height:39 reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [section2 addRow:row_1_3];

    
    MMSection *section3 = [MMSection tagWithTag:0];
    MMRow *row_1_6 = [MMRow rowWithTag:0 rowInfo:book.summary rowActions:nil height:[[TNAppContext currentContext] heightFordetailText:book.summary andWidth:kWidth-38 andFontOfSize:14]+70 reuseIdentifier:@"ZHSSchoolbagWenanTableViewCell"];
    [section3 addRow:row_1_6];
    
    
    [table1 addSections:@[section1,section1_1,section2,section3]];
    _handle1.tableModel = table1;
    [_handle1 reloadTable];

}
- (IBAction)quickJieYue:(id)sender {
    ZHSOrderViewController*vc = [[ZHSOrderViewController alloc] initWithNibName:@"ZHSOrderViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark ===========收藏
- (IBAction)collect:(UIButton *)sender {
    NSString *path = [NSString stringWithFormat:@"%@/package/%@/favor",kHeaderURL,_schoolbag.ID];
    NSMutableDictionary *parms = [@{} mutableCopy];
    if ([self.cancelCollection isEqualToString:@"yes"]) {
        [parms setValue:@"remove" forKey:@"action"];
    }
    [[THRequstManager sharedManager] asynPOST:path parameters:parms withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            if ([self.cancelCollection isEqualToString:@"yes"]) {
                [TNToast showWithText:@"取消收藏成功"];

            }else
            [TNToast showWithText:@"收藏成功"];
        }
    }];
    
}
#pragma mark ===========预借

- (IBAction)preYuJie:(id)sender {
    if ([self.liJiJieYue.currentTitle isEqualToString:@"加入班级"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
       ZHSHomeViewController*vc = [TNFlowUtil startGoHome];
        [vc cityClick:nil];
    }else{
    NSString *path = [NSString stringWithFormat:@"%@/package/%@/pre-borrow",kHeaderURL,_schoolbag.ID];
//    NSString *path = @"http://admin.cctvzhs.com/api/v1/package/1/pre-borrow";
    __weak typeof(self)tempSelf = self;
    [[THRequstManager sharedManager] asynPOST:path parameters:@{} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code==1) {
            NSDictionary*data = responseObject[@"data"];
            if ([data[@"pre_borrow"] integerValue] == 1) {
                [TNToast showWithText:@"预借成功"];
                [data[@"related_packages"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ZHSSchoolbag *schoolbag = [ZHSSchoolbag modelWithJsonDicUseSelfMap:obj];
                    NSArray *books = obj[@"books_list"];
                    NSMutableArray *booklist = [@[] mutableCopy];
                    for (NSDictionary*dic in books) {
                        ZHSBooks*book = [ZHSBooks modelWithJsonDicWithoutMap:dic];
                        [booklist addObject:book];
                    }
                    schoolbag.books_list = booklist;
                    [_tuiJianSchoolbagsArray addObject:schoolbag];

                }];
                ZHSShoolbagDetailViewController *vc = [ZHSShoolbagDetailViewController new];
                vc.schoolbags = _tuiJianSchoolbagsArray;
                vc.isSmile = YES;
                [tempSelf.navigationController pushViewController:vc animated:YES];
            }else if ([data[@"pre_borrow"] integerValue] == 0){
                [TNToast showWithText:@"此书包已经被借阅"];
                [data[@"related_packages"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ZHSSchoolbag *schoolbag = [ZHSSchoolbag modelWithJsonDicUseSelfMap:obj];
                    NSArray *books = obj[@"books_list"];
                    NSMutableArray *booklist = [@[] mutableCopy];
                    for (NSDictionary*dic in books) {
                        ZHSBooks*book = [ZHSBooks modelWithJsonDicWithoutMap:dic];
                        [booklist addObject:book];
                    }
                    schoolbag.books_list = booklist;
                    [_tuiJianSchoolbagsArray addObject:schoolbag];
                    
                }];
                ZHSShoolbagDetailViewController *vc = [ZHSShoolbagDetailViewController new];
                vc.schoolbags = _tuiJianSchoolbagsArray;
                vc.isSmile = NO;
                [tempSelf.navigationController pushViewController:vc animated:YES];
            }else if ([data[@"pre_borrow"] integerValue] == 2){
                [TNToast showWithText:data[@"reason"]];
                [tempSelf.navigationController pushViewController:[ZHSMyCenterOfPrepaidViewController new] animated:YES];

            }else if ([data[@"pre_borrow"] integerValue] == 3){
                [TNToast showWithText:data[@"reason"]];
//                [tempSelf.navigationController pushViewController:[ZHSMyCenterOfPrepaidViewController new] animated:YES];
                
            }
        }
    }];
}
}



@end
