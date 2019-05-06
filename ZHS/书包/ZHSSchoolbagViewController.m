//
//  ZHSSchoolbagViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/16.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSSchoolbagViewController.h"

#import "TNOrderPickerView.h"
#import "THCouponVC.h"
#import "ZHSBooks.h"
#import "ZHSSchoolbag.h"
#import "ZHSOnlyBookDetailViewController.h"

@interface ZHSSchoolbagViewController ()<MMTableViewHandleDelegate,UISearchBarDelegate,TNOrderPickerViewDelegate>
{
    UIView * nianlingView;
    UIView * nianlingView1;
    UIView * nianlingView2;
    UIView * nianlingView3;
    
    UILabel *lableWithJiaGe;
    UILabel *lableWithJiaGe1;
    UILabel *lableWithJiaGe2;
    UILabel *lableWithJiaGe3;
    
    NSMutableArray *_ages;
    NSMutableArray *_themes;
    
    NSMutableArray *_schoolbags;
    NSInteger _offset; // 标示数据从第几条开始请求
    NSMutableDictionary *_prams;// 分类选择的字典
    BOOL _isSearch ;// 来区分是否是搜索模式

}

@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (strong, nonatomic) TNOrderPickerView   *orderPicker;
@property (nonatomic, strong) UIView              *shadowView;






@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) MMTableViewHandle *handle;

@end

@implementation ZHSSchoolbagViewController
-(void)viewDidFirstAppear:(BOOL)animated{
    [super viewDidFirstAppear:YES];
    self.shadowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHight)];
    self.shadowView.backgroundColor = [UIColor blackColor];
    self.shadowView.alpha = 0.6;
    self.shadowView.hidden = YES;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickShadowView)];
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.shadowView addGestureRecognizer:tapRecognizer];
    [self.view addSubview:self.shadowView];
    
    self.orderPicker = [TNOrderPickerView viewFromNib];
    self.orderPicker.frame = CGRectMake(0, 0, kWidth,0);
    self.orderPicker.delegate = self;
    self.orderPicker.hidden = YES;
    [self.view addSubview:self.orderPicker];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    MMLog(@"%d",self.tabBarHidden);
    NSUserDefaults* ud=[NSUserDefaults standardUserDefaults];
    if ([ud boolForKey:@"huiben"]) {
        [self requestPackages];
        [self requestPackageCategories];
        [ud setBool:NO forKey:@"huiben"];
    }

}
#pragma mark === clickShadowView
-(void)clickShadowView{
    [UIView animateWithDuration:0.3 animations:^{
        self.orderPicker.frame = CGRectMake(0, 0, kWidth, 0);
    }completion:^(BOOL finished) {
        self.orderPicker.hidden = YES;
        self.shadowView.hidden = YES;
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarHidden = NO;
    
    _isSearch = NO;
    CGFloat Width = 90*3;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,(kWidth-Width)/2, Width, 44)];
    
    nianlingView = [[ UIView alloc]initWithFrame:CGRectMake(0, 0, Width/3, 44)];
    UIView *lineLable = [[ UIView alloc]initWithFrame:CGRectMake(Width/3-1, 15, 1, 20)];
    lineLable.backgroundColor = [UIColor whiteColor];
    [nianlingView addSubview:lineLable];
    lableWithJiaGe = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 30)];
    lableWithJiaGe.text = @"所有年级";
    lableWithJiaGe.userInteractionEnabled = YES;
    lableWithJiaGe.textAlignment = NSTextAlignmentCenter;
    lableWithJiaGe.textColor = [UIColor whiteColor];
    lableWithJiaGe.font = [UIFont fontWithName:@"Helvetica" size:14];
    [nianlingView addSubview:lableWithJiaGe];
    UIImageView *button = [[UIImageView alloc] initWithFrame:CGRectMake(73, 23, 7, 5)];
    button.image = [UIImage imageNamed:@"shop_arrow_down"];
    button.userInteractionEnabled = YES;
    [nianlingView addSubview:button];
    
    [view addSubview:nianlingView];
    
    
    nianlingView2 = [[ UIView alloc]initWithFrame:CGRectMake(1* Width/3, 0, Width/3, 44)];

    lableWithJiaGe2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 30)];
    UIView *lineLable2 = [[ UIView alloc]initWithFrame:CGRectMake(Width/3-1, 15, 1, 20)];
    lineLable2.backgroundColor = [UIColor whiteColor];
    [nianlingView2 addSubview:lineLable2];
    lableWithJiaGe2.text = @"所有主题";
    lableWithJiaGe2.textAlignment = NSTextAlignmentCenter;
    lableWithJiaGe2.textColor = [UIColor whiteColor];
    lableWithJiaGe2.userInteractionEnabled = YES;
    lableWithJiaGe2.font = [UIFont fontWithName:@"Helvetica" size:14];
    [nianlingView2 addSubview:lableWithJiaGe2];
    UIImageView *button2 = [[UIImageView alloc] initWithFrame:CGRectMake(73, 23, 7, 5)];
    button2.image = [UIImage imageNamed:@"shop_arrow_down"];
    button2.userInteractionEnabled = YES;
    [nianlingView2 addSubview:button2];
    [view addSubview:nianlingView2];
    
    
    nianlingView3 = [[ UIView alloc]initWithFrame:CGRectMake(2* Width/3, 0, Width/3, 44)];
    
    lableWithJiaGe3 = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 30)];

    lableWithJiaGe3.text = @"默认排序";
    lableWithJiaGe3.textAlignment = NSTextAlignmentCenter;
    lableWithJiaGe3.textColor = [UIColor whiteColor];
    lableWithJiaGe3.font = [UIFont fontWithName:@"Helvetica" size:14];
    [nianlingView3 addSubview:lableWithJiaGe3];
    
    UIImageView *button3 = [[UIImageView alloc] initWithFrame:CGRectMake(73, 23, 7, 5)];
    button3.image = [UIImage imageNamed:@"shop_arrow_down"];
    button3.userInteractionEnabled = YES;
    lableWithJiaGe3.userInteractionEnabled = YES;
    [nianlingView3 addSubview:button3];
    [view addSubview:nianlingView3];
    

    self.navigationItem.titleView = view ;

    [self addTapToNavTitle];

    // Do any additional setup after loading the view from its nib.
//    _mySearchBar.backgroundColor = RGB(249,249,249);
//    _mySearchBar.backgroundImage = [self imageWithColor:[UIColor clearColor] size:_mySearchBar.bounds.size];
}
#pragma mark ====== 给帅选条件添加点击事件
-(void)addTapToNavTitle{
    UITapGestureRecognizer *tapCarwashView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOrderView:)];
    [nianlingView addGestureRecognizer:tapCarwashView];

    UITapGestureRecognizer *tapNearbyView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOrderView:)];
    [nianlingView2 addGestureRecognizer:tapNearbyView];
    
    UITapGestureRecognizer *tapScreenView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickOrderView:)];
    [nianlingView3 addGestureRecognizer:tapScreenView];
}
-(void)clickOrderView:(UITapGestureRecognizer*)sender{

    self.orderPicker.hidden = NO;
    self.shadowView.hidden = NO;
    if (sender.view == nianlingView) {
        [_orderPicker reloadOrderDataWithShopType:_ages];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.orderPicker.frame = CGRectMake(0, 0, kWidth, 42*_ages.count+5);
        }];

    }
    else if (sender.view == nianlingView2) {
       [_orderPicker reloadOrderDataWithShopType:_themes];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.orderPicker.frame = CGRectMake(0, 0, kWidth, 42*_themes.count+5);
        }];

    }
    else
    {
    [_orderPicker reloadOrderDataWithShopType:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.orderPicker.frame = CGRectMake(0, 0, kWidth, 42*3);
    }];
    }
}
#pragma mark ====== TNOrderPickerView 代理
-(void)orderPickerView:(TNOrderPickerView *)pickerView didSelectOrderWithName:(NSString *)name code:(NSString *)code{
    _isSearch = NO;
    if ([code isEqualToString:@"class_level"]) {
        lableWithJiaGe.text = name;
        if (![name isEqualToString:@"所有年级"]) {
            [_prams setObject:name forKey:code];
        }else
            [_prams removeObjectsForKeys:@[code]];
    }
    else if ([code isEqualToString:@"awards"]) {
        lableWithJiaGe1.text = name;
        if (![name isEqualToString:@""]) {
            [_prams setObject:name forKey:code];
        }else
            [_prams removeObjectsForKeys:@[code]];


    }
    else if ([code isEqualToString:@"theme"]) {
        lableWithJiaGe2.text = name;
        if (![name isEqualToString:@"所有主题"]) {
            [_prams setObject:name forKey:code];
        }else
            [_prams removeObjectsForKeys:@[code]];

    }else{
    lableWithJiaGe3.text = name;
        if ([code isEqualToString:@"ranking"]) {
            [_prams setObject:code forKey:@"orderby"];
            [_prams setObject:@"desc" forKey:@"seq"];
        }
        if ([name isEqualToString:@"默认排序"]) {
            [_prams removeObjectsForKeys:@[@"orderby",@"seq"]];
        }
        if ([name isEqualToString:@"借阅最多"]) {
            [_prams setObject:code forKey:@"orderby"];
        }
        
    }
    [self clickShadowView];
    if (_schoolbags.count) {
        [_schoolbags removeAllObjects];
    }
    [self requestPackagesWithCategories];
    [_prams setObject:@"desc" forKey:@"seq"];


}
//取消searchbar背景色
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}
-(void)initView{
    _mySearchBar.frame =CGRectMake(12 , 7, kWidth-24, 30);
    // 适配 navigationBar 和 tabBar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSPictureBookMuseumTableViewCell"];

    
    
    _handle.delegate = self;

    __weak __typeof(self) tempSelf= self;

    [_tableview addPPFooterWithBlock:^{
        _offset = (_offset/10 +1)*10;
        DLog(@"%@",_prams);
        if (_prams.allKeys.count>1) {
            [tempSelf requestPackagesWithCategories];
        }else if(_isSearch){
            [tempSelf requestPackagesWithSearchWith:_mySearchBar.text];
        }else
        [tempSelf requestPackages];
    }];

}
-(void)initData{
    _ages = [@[] mutableCopy];
    _themes = [@[] mutableCopy];
    _schoolbags = [@[] mutableCopy];
    _prams = [@{} mutableCopy];

    [self requestPackageCategories];
    [self requestPackages];
}
-(void)tableHandle:(MMTableViewHandle *)tableHandle didSelectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath{
    if (kIsBookMode) {
        ZHSOnlyBookDetailViewController *vc = [[ZHSOnlyBookDetailViewController alloc] init];
        vc.schoolbag = _schoolbags[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        THCouponVC *vc = [[THCouponVC alloc] init];
        vc.schoolbag = _schoolbags[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark  请求分类的数据
-(void)requestPackageCategories{
    NSString *path = [NSString stringWithFormat:@"%@/package-categories",kHeaderURL];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            NSDictionary *data = responseObject[@"data"];
            _ages = data[@"class_level"];
            _themes = data[@"theme"];
        }
    }];
    
}
-(void)reloadSchoolbagData{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    __weak typeof(self)weakSelf = self;
    [_schoolbags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMRow *row;
        if (kIsBookMode) {
            row = [MMRow rowWithTag:0 rowInfo:obj rowActions:@[^{
                ZHSOnlyBookDetailViewController *vc = [[ZHSOnlyBookDetailViewController alloc] init];
                vc.schoolbag = obj;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }] height:267 reuseIdentifier:@"ZHSPictureBookMuseumTableViewCell"];
        }else{
            row = [MMRow rowWithTag:0 rowInfo:obj rowActions:@[^{
            THCouponVC *vc = [[THCouponVC alloc] init];
            vc.schoolbag = obj;
            [weakSelf.navigationController pushViewController:vc animated:YES];
            }] height:267 reuseIdentifier:@"ZHSPictureBookMuseumTableViewCell"];
        }
        
        [section addRow:row];
    }];
    
    [table addSection:section];
    _handle.tableModel = table;
    [_handle reloadTable];
}
#pragma mark  分类请求书包的数据
-(void)requestPackagesWithCategories{
     NSMutableString *path = [NSMutableString stringWithFormat:@"%@/package?offset=%ld&limit=5",kHeaderURL,(unsigned long)_schoolbags.count];
    for (NSString *key in [_prams allKeys]) {
        if (_prams[key] && [_prams[key] length]) {
            [path appendFormat:@"&%@=%@",key,_prams[key]];
        }
    }
    
    
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        [_tableview.footer endRefreshing];
        if (code == 1) {
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
        }
        [self reloadSchoolbagData];

    }];
    


}
#pragma mark UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text) {
        _isSearch = YES;
        if (_schoolbags.count) {
            [_schoolbags removeAllObjects];
        }
        [self reclaimedKeyboard];
        [self requestPackagesWithSearchWith:searchBar.text];
        
    }
}
#pragma mark searchBar delegate
//searchBar开始编辑时改变取消按钮的文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSArray *subViews;
    searchBar.showsCancelButton = YES;
    subViews = [(searchBar.subviews[0]) subviews];
    for (id view in subViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
            break;
        }
    }
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //取消
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}
#pragma mark  搜索请求书包的数据
-(void)requestPackagesWithSearchWith:(NSString *)searchStr{
    NSString *path = [NSString stringWithFormat:@"%@/package?search=%@&offset=%ld&limit=5",kHeaderURL,searchStr,(unsigned long)_schoolbags.count];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        [_tableview.footer endRefreshing];
        if (code == 1) {
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
            [self reloadSchoolbagData];
            
        }else{
//            [TNToast showWithText:responseObject[@"message"] duration:0.3];
        }
    }];
}
#pragma mark  请求书包的数据
-(void)requestPackages{
    NSString *path = [NSString stringWithFormat:@"%@/package?offset=%ld&limit=5",kHeaderURL,(unsigned long)_schoolbags.count];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        [_tableview.footer endRefreshing];
        if (code == 1) {
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
            [self reloadSchoolbagData];
        }else{
            [_tableview removeFooter];
            if (code == THRequstErrorCodeConnectionError) {
                commonNotNetwork *notnetworkView = [TNNibUtil loadObjectWithClass:[UIView class] fromNib:@"commonNotNetwork"];
                [notnetworkView.notNetworkbutton addTarget:self action:@selector(notNetwork:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:notnetworkView];
            }
        }
    }];
}
-(void)notNetwork:(UIButton *)btn{

    [self requestPackageCategories];
    [self requestPackages];
    [btn.superview removeFromSuperview];
}
#pragma mark  初始化UISearchBar

-(void)reclaimedKeyboard{
    [_mySearchBar resignFirstResponder];
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
