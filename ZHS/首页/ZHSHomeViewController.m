//
//  ZHSHomeViewController.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/16.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSHomeViewController.h"
#import "THCouponVC.h"
#import "ZHSBooks.h"
#import "LBXScanViewController.h"
#import "UMSocial.h"
#import "ScanResultViewController.h"
#import "ZHSCitysViewController.h"
#import "ZHSHomeOneYuanOneGuanViewController.h"
#import "ZHSHomeOfChildMusicViewController.h"
#import "ZHSUserOfBaoBaoInformationViewController.h"
#import "TNH5ViewController.h"
#import "ZHSMyCenterOfRecyclingableViewCellViewController.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "ZHSLuckyDrawViewController.h"
#import "ZHSFindYourTeacherViewController.h"
#import "DWPublishButton.h"
#import "AppDelegate.h"
#import "ZHSOnlyBookDetailViewController.h"

@interface ZHSHomeViewController ()<MMTableViewHandleDelegate,MMNavigationControllerNotificationDelegate,UISearchBarDelegate,UMSocialUIDelegate>
{
    BOOL _isShow;
    UIButton* _location;// 左侧的地址
    UIView *_customView;
    UIButton* _centerButtonOfNavgationbar;// 中间的幼儿园按钮

    
    __block NSMutableArray *_bannersAry;
    __block NSMutableArray *_hotspotsAry;
    __block NSMutableArray *_recommend_list;
    NSMutableDictionary *_musicInfoDic;

    
}

//@property (nonatomic)   CLLocationCoordinate2D    locationCoordinate2D;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) MMTableViewHandle *handle;

@end

@implementation ZHSHomeViewController

-(void)viewControllerDidShowWithPop:(NSArray *)viewControllers{
    _musicInfoDic = self.navigationController.userinfo;
    if ([viewControllers containsObjectClass:[ZHSUserOfBaoBaoInformationViewController class]]) {
        
        NSUserDefaults* ud=[NSUserDefaults standardUserDefaults];
        if ([ud boolForKey:@"home"]) {
            [self initData];
            [ud setBool:NO forKey:@"home"];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.tabBarHidden = NO;
    self.navigationBarHidden = NO;
    self.zhishiView.frame = CGRectMake(0, 0, kWidth, kHight-100);

    _isShow = YES;
//    [self initLocation];
    _bannersAry =  [@[] mutableCopy];
    _hotspotsAry = [@[] mutableCopy];
    _musicInfoDic = [@{} mutableCopy];
//    [self.navigationController.navigationBar setTitleTextAttributes:  @{NSFontAttributeName:[UIFont italicSystemFontOfSize:15],NSForegroundColorAttributeName:[UIColor whiteColor]}];
//    [self createRightBarItemWithImage:@"nav_notify_bell"];

    
    NSUserDefaults* ud=[NSUserDefaults standardUserDefaults];
    NSDate *date = [ud objectForKey:@"refreshTokenTime"];
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:date];
    //
    if (fabs(time)>60*60*24*5) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshToken];
        });
    }


    TNUser *user = [TNAppContext currentContext].user;
    if (![user.payment_status isEqualToString:@"paid"]) {
        NSArray *ary =  self.tabBarController.tabBar.subviews;
        [ary enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[DWPublishButton class]]) {
                [obj setImage:[UIImage imageNamed:@"jiahao"] forState:UIControlStateNormal];
            }
        }];
        [self.view addSubview: self.zhishiView];
    }

}

-(void)viewDidAppear:(BOOL)animated{
    self.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    TNUser *user = [TNAppContext currentContext].user;
    if ([user.school_info[@"name"] length] && [user.school_class_info[@"name"] length]) {
        [_centerButtonOfNavgationbar setTitle:[NSString stringWithFormat:@"%@%@",user.school_info[@"name"],user.school_class_info[@"name"]] forState:UIControlStateNormal] ;
        _centerButtonOfNavgationbar.enabled = NO;
    }else{
        [_centerButtonOfNavgationbar setTitle:@"点击加入班级" forState:UIControlStateNormal] ;
        _centerButtonOfNavgationbar.enabled = YES;
    }

    
}
#pragma mark  初始化navgationbar 右侧的按钮：搜索 和 扫码
-(void)search:(UIBarButtonItem*)sender{
    TNUser *user = [TNAppContext currentContext].user;
    user.school_class_info = nil;
    user.school_info = nil;
    [TNAppContext currentContext].user = user;
    [[TNAppContext currentContext] saveUser];
}
#pragma mark ==== 点击通知
-(void)clickRightSender:(UIButton *)sender{
    
}
-(void)scanCode:(UIBarButtonItem *)sender{
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    style.photoframeLineW = 6;
    style.photoframeAngleW = 24;
    style.photoframeAngleH = 24;
    MMLog(@"%f",kWidth);
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    
    //qq里面的线条图片
    UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    style.animationImage = imgLine;
    
    LBXScanViewController *vc = [LBXScanViewController new];
    vc.style = style;
    vc.isQQSimulator = YES;
    vc.completion = ^(NSString *strScanned,LBXScanResult*strResult){
        ScanResultViewController *vc = [ScanResultViewController new];
        vc.imgScan = strResult.imgScanned;
        
        vc.strScan = strResult.strScanned;
        
        vc.strCodeType = strResult.strBarCodeType;
        
        [self.navigationController pushViewController:vc animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];

}

-(void)cityClick:(UIButton*)sender{
    ZHSFindYourTeacherViewController*vc = [ZHSFindYourTeacherViewController new];
    vc.isCanBack = YES;
    [self.navigationController pushViewController:vc animated:YES];

    
}
//-(void)requestCity{
//    NSString *path = [NSString stringWithFormat:@"%@/area",kHeaderURL];
//    if ([TNAppContext currentContext].citys.count <1 ) {
//        [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
//            if (code) {
//                [TNAppContext currentContext].citys = responseObject[@"data"];
//            }else{
//                [TNToast showWithText:responseObject[@"message"]];
//            }
//        }];
//  
//    }
//}
#pragma mark  初始化navgationbar 左侧的按钮：地址
-(void)leftBarButtonItems{
    NSInteger num1,num2;
    if (kWidth >= 375) {
        num1 = 200;
        num2 = 250;
    }else{
        num1 = 160;
        num2 = 200;
    }

    
    
    UIButton* locationImage = [UIButton buttonWithType:UIButtonTypeCustom];
    locationImage.frame = CGRectMake(0, 12, 18, 25);
    UIImage *image =[UIImage imageNamed:@"location"];
    [locationImage addTarget:self action:@selector(cityClick:) forControlEvents:UIControlEventTouchUpInside];
    [locationImage setBackgroundImage:image forState:UIControlStateNormal] ;
    
    _location = [UIButton buttonWithType:UIButtonTypeCustom];
    _location.frame = CGRectMake(23, 12, num1, 30);
    [_location addTarget:self action:@selector(cityClick:) forControlEvents:UIControlEventTouchUpInside];
    [_location setTintColor:[UIColor whiteColor]];
    _location.titleLabel.font = [UIFont systemFontOfSize:16.0f];
//    _location.titleLabel.textAlignment =  NSTextAlignmentLeft;
    [_location setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

    _customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, num2, 44)];
    _customView.backgroundColor = [UIColor clearColor];
    [_customView addSubview:locationImage];
    [_customView addSubview:_location];
    
//    UIBarButtonItem *customUIBarButtonitem = [[UIBarButtonItem alloc] initWithCustomView:_customView];
//    self.navigationItem.leftBarButtonItem = customUIBarButtonitem;
    
}
#pragma mark  初始化navgationbar 中间的titleButton
-(void)centerButtonOfNavgationbar{

    _centerButtonOfNavgationbar = [UIButton buttonWithType:UIButtonTypeCustom];
    _centerButtonOfNavgationbar.frame = CGRectMake(0, 0, kWidth-100, 44);
    [_centerButtonOfNavgationbar addTarget:self action:@selector(cityClick:) forControlEvents:UIControlEventTouchUpInside];
    _centerButtonOfNavgationbar.titleLabel.font = [UIFont italicSystemFontOfSize: 15.0];
    TNUser *user = [TNAppContext currentContext].user;
    if ([user.school_info[@"name"] length] && [user.school_class_info[@"name"] length]) {
        [_centerButtonOfNavgationbar setTitle:[NSString stringWithFormat:@"%@%@",user.school_info[@"name"],user.school_class_info[@"name"]] forState:UIControlStateNormal] ;

    }else{
        [_centerButtonOfNavgationbar setTitle:@"点击加入班级" forState:UIControlStateNormal] ;
    }
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth-100, 44)];
    customView.backgroundColor = [UIColor clearColor];
    [customView addSubview:_centerButtonOfNavgationbar];
    self.navigationItem.titleView = customView;
//    [self.navigationItem.titleView addSubview:_centerButtonOfNavgationbar];
}

#pragma mark  初始化navgationbar 右侧的按钮：搜索 和 扫码
-(void)rightBarButtonItems{
    /*
     ***************************************************************************************
     暂时去除导航栏的搜索和扫码功能   by XXD
     ***************************************************************************************
    NSInteger num1,num2,num3;
    if (kWidth >= 375) {
        num1 = 0;
        num2 = 35;
        num3 = 60;
    }else{
        num1 = 5;
        num2 = 45;
        num3 = 80;
    }
    UIButton* search = [UIButton buttonWithType:UIButtonTypeCustom];
    search.frame = CGRectMake(num1, 12, 25, 25);
    UIImage *image =[UIImage imageNamed:@"search"];
    [search addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [search setBackgroundImage:image forState:UIControlStateNormal] ;
    
    UIButton* scanCode = [UIButton buttonWithType:UIButtonTypeCustom];
    scanCode.frame = CGRectMake(num2, 12, 25, 25);
    UIImage *image1 =[UIImage imageNamed:@"scanCode"];
    [scanCode addTarget:self action:@selector(scanCode:) forControlEvents:UIControlEventTouchUpInside];
    [scanCode setBackgroundImage:image1 forState:UIControlStateNormal] ;
     ***************************************************
     */
    UIButton* notify = [UIButton buttonWithType:UIButtonTypeCustom];
    notify.frame = CGRectMake(7, 13, 17, 18);
    UIImage *image =[UIImage imageNamed:@"nav_notify_bell"];
    [notify addTarget:self action:@selector(scanCode:) forControlEvents:UIControlEventTouchUpInside];
    [notify setBackgroundImage:image forState:UIControlStateNormal] ;
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 31, 44)];
    customView.backgroundColor = [UIColor clearColor];
//    [customView addSubview:scanCode];
//    [customView addSubview:search];
    [customView addSubview:notify];
    
    UIBarButtonItem *customUIBarButtonitem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    self.navigationItem.rightBarButtonItem = customUIBarButtonitem;
    
}
#pragma mark =====初始化页面
-(void)initData{
    __weak typeof(self)tempSelf = self;
    [[THRequstManager sharedManager] asynGET:[NSString stringWithFormat:@"%@/homepage",kHeaderURL] withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        [_tableview.header endRefreshing];
        if (code == 1) {
            MMLog(@"%@",responseObject);
            NSDictionary *dataDic = responseObject[@"data"];
            _bannersAry = dataDic[@"banners"];
            _hotspotsAry = dataDic[@"hotspots"];
            _recommend_list = dataDic[@"recommend_list"];
            [tempSelf reloadTableview];
        }else{
            MMLog(@"++++++++++++");
            commonNotNetwork *notnetworkView = [TNNibUtil loadObjectWithClass:[UIView class] fromNib:@"commonNotNetwork"];
            [notnetworkView.notNetworkbutton addTarget:self action:@selector(notNetwork:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:notnetworkView];
        }
    }];
}
-(void)notNetwork:(UIButton *)btn{
    if ([[TNAppContext currentContext]returnNetwork] == MMNetworkNull) {
        [self initData];
    }else{
        [self refreshToken];
        [self initData];
    }
    [btn.superview removeFromSuperview];
}
-(void)initView{
//    [self rightBarButtonItems];
//    [self leftBarButtonItems];
    [self centerButtonOfNavgationbar];
    // 适配 navigationBar 和 tabBar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSIndexTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"TNImageycleTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSTheFourPieceTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSTheFivePieceTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSTuiJianTableViewCell"];

    
    [_tableview addPPHeaderWithBlock:^{
        [self initData];
    }];
    _handle.delegate = self;


}
-(void)reloadTableview{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    MMRow *row = [MMRow rowWithTag:0 rowInfo:@{@"data":_bannersAry?_bannersAry:@[],@"VC":self} rowActions:nil height:140 reuseIdentifier:@"TNImageycleTableViewCell"];
    __weak typeof(self)tempSelf = self;
    //首页列表1
    MMRow *row1 = [MMRow rowWithTag:0 rowInfo:nil rowActions:@[
    ^{
        ZHSHomeOfChildMusicViewController *vc = [ZHSHomeOfChildMusicViewController new];//宝宝悦听
        vc.musicInfo = _musicInfoDic;
        [tempSelf.navigationController pushViewController:vc animated:YES];
        
    },^{
        ZHSHomeOneYuanOneGuanViewController*vc = [ZHSHomeOneYuanOneGuanViewController new];//一园一馆
        [tempSelf.navigationController pushViewController:vc animated:YES];
        
    },^{
            [tempSelf.navigationController pushViewController:[ZHSMyCenterOfRecyclingableViewCellViewController new] animated:YES];//循环收益

    },^{
            TNH5ViewController *vc = [TNH5ViewController new];//兴趣培养
            vc.titleString = @"兴趣培养";
            vc.urlString = @"http://www.cctvzhs.com/pyxq.html";
            [tempSelf.navigationController pushViewController:vc animated:YES];
    }] height:100 reuseIdentifier:@"ZHSTheFourPieceTableViewCell"];
//首页列表2
    MMRow *row2 = [MMRow rowWithTag:0 rowInfo:_hotspotsAry rowActions:@[^{
        NSString *str = [_hotspotsAry[0][@"links"] substringToIndex:3];
        if ([str isEqualToString:@"htt"]) {
            TNH5ViewController *h5 = [TNH5ViewController new];
            h5.isShare = YES;
            h5.imageShareString = ((NSDictionary*)_hotspotsAry[0])[@"image_url"];
            h5.titleString =((NSDictionary*)_hotspotsAry[0])[@"title"];
            h5.urlString = ((NSDictionary*)_hotspotsAry[0])[@"links"];
//            h5.urlString = @"http://mp.weixin.qq.com/s?__biz=MzIyODExMjE2Mw==&mid=402604701&idx=1&sn=b08dc8e36b9b85cd1128cb06ca585dc3#rd";

            [tempSelf.navigationController pushViewController:h5 animated:YES];
        }
        if ([str isEqualToString:@"app"]) {
            MMLog(@"app:跳转本地的页面");
            
        }
    },^{
        NSString *str = [_hotspotsAry[1][@"links"] substringToIndex:3];
        if ([str isEqualToString:@"htt"]) {
            TNH5ViewController *h5 = [TNH5ViewController new];
            h5.isShare = YES;
            h5.imageShareString = ((NSDictionary*)_hotspotsAry[1])[@"image_url"];
            h5.titleString =((NSDictionary*)_hotspotsAry[1])[@"title"];
            h5.urlString = ((NSDictionary*)_hotspotsAry[1])[@"links"];
//            h5.urlString = @"http://mp.weixin.qq.com/s?__biz=MzIyODExMjE2Mw==&mid=401295493&idx=1&sn=ea824c105b48fd948b8727994c868243#rd";
            [tempSelf.navigationController pushViewController:h5 animated:YES];
        }
        if ([str isEqualToString:@"app"]) {
            MMLog(@"app:跳转本地的页面");
        }
        
    },^{
        NSString *str = [_hotspotsAry[2][@"links"] substringToIndex:3];
        if ([str isEqualToString:@"htt"]) {
            TNH5ViewController *h5 = [TNH5ViewController new];
            h5.isShare = YES;
            h5.imageShareString = ((NSDictionary*)_hotspotsAry[2])[@"image_url"];
            h5.titleString =((NSDictionary*)_hotspotsAry[2])[@"title"];
            h5.urlString = ((NSDictionary*)_hotspotsAry[2])[@"links"];
//            h5.urlString = @"http://www.autoyou.com.cn/home";

            [tempSelf.navigationController pushViewController:h5 animated:YES];
        }
        if ([str isEqualToString:@"app"]) {
            MMLog(@"app:跳转本地的页面");
        }
        
    },^{
        NSString *str = [_hotspotsAry[3][@"links"] substringToIndex:3];
        if ([str isEqualToString:@"htt"]) {
            TNH5ViewController *h5 = [TNH5ViewController new];
            h5.isShare = YES;
            h5.imageShareString = ((NSDictionary*)_hotspotsAry[3])[@"image_url"];
            h5.titleString =((NSDictionary*)_hotspotsAry[3])[@"title"];
            h5.urlString = ((NSDictionary*)_hotspotsAry[3])[@"links"];
//            h5.urlString = @"http://mp.weixin.qq.com/s?__biz=MzIyODExMjE2Mw==&mid=402608561&idx=1&sn=d28a189e1b69c6fb324fce9c1f2dbc61#rd";
            [tempSelf.navigationController pushViewController:h5 animated:YES];
        }
        if ([str isEqualToString:@"app"]) {
            MMLog(@"app:跳转本地的页面");
        }
        
    }] height:144 reuseIdentifier:@"ZHSTheFivePieceTableViewCell"];
    //首页列表3
    MMRow *row3 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:40 reuseIdentifier:@"ZHSTuiJianTableViewCell"];
    
    [section addRow:row];
    [section addRow:row1];
    [section addRow:row2];
    [section addRow:row3];
    [table addSection:section];
    for (int i = 0; i < _recommend_list.count; i ++) {
        MMRow *row = [MMRow rowWithTag:0 rowInfo:_recommend_list[i] rowActions:@[^(ZHSSchoolbag*schoolbag){
            if (kIsBookMode) {//是否是单图书模式
                ZHSOnlyBookDetailViewController *vc = [[ZHSOnlyBookDetailViewController alloc] init];
                vc.schoolbag = schoolbag;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                THCouponVC *vc = [[THCouponVC alloc] init];
                vc.schoolbag = schoolbag;
                [self.navigationController pushViewController:vc animated:YES];
                
            }
//            THCouponVC *vc = [[THCouponVC alloc] init];
//            vc.schoolbag = schoolbag;
//            [self.navigationController pushViewController:vc animated:YES];
        },^{
            [tempSelf huanyihuan:i];
        }] height:219 reuseIdentifier:@"ZHSIndexTableViewCell"];
        MMSection*sec = [MMSection section];
        [sec addRow:row];
        [table addSection:sec];

    }
    _handle.tableModel = table;
    [_handle reloadTable];
}
-(void)huanyihuan:(NSInteger)class_level{
    NSString *path = [NSString stringWithFormat:@"%@/homepage/refresh-recommend",kHeaderURL];
    NSMutableDictionary *parms = [@{} mutableCopy];
    if (class_level == 0) {
        [parms setValue:@"小班" forKey:@"class_level"];
    }
    if (class_level == 1) {
        [parms setValue:@"中班" forKey:@"class_level"];
    }
    if (class_level == 2) {
        [parms setValue:@"大班" forKey:@"class_level"];
    }
    
    __block NSMutableArray *strAry = [@[] mutableCopy];
    [_recommend_list[class_level][@"packages"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [strAry addObject:@{@"id": obj[@"id"]}];
    }];
    [parms setObject:strAry forKey:@"last_packages"];
//    __weak typeof(self)tempSelf = self;
    [[THRequstManager sharedManager] asynPOST:path parameters:parms withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            [_recommend_list replaceObjectAtIndex:class_level withObject:responseObject[@"data"]];
//            MMRow *row = [MMRow rowWithTag:0 rowInfo:_recommend_list[class_level] rowActions:@[^(ZHSSchoolbag*schoolbag){
//                THCouponVC *vc = [[THCouponVC alloc] init];
//                vc.schoolbag = schoolbag;
//                [self.navigationController pushViewController:vc animated:YES];
//            },^{
//                [tempSelf huanyihuan:class_level];
//            }] height:219 reuseIdentifier:@"ZHSIndexTableViewCell"];
//            [_handle replaceRows:@[row] forSection:class_level+1 withRowAnimation:UITableViewRowAnimationFade];
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:class_level+1];
            MMRow *row = [_handle rowWithIndexPath:index];
            row.rowInfo = responseObject[@"data"];
            [_handle reloadTableRowsAtIndexPath:index withRowAnimation:UITableViewRowAnimationFade];
            
        }
    }];
    
}
#pragma mark ====== 点击cell触发的时间
//-(void)tableHandle:(MMTableViewHandle *)tableHandle didSelectCell:(UITableViewCell *)cell forRow:(MMRow *)row atIndexPath:(NSIndexPath *)indexPath{
//    [tableHandle deselectRowAtIndexPath:indexPath animated:NO];
//    if (indexPath.row>3) {
//        THCouponVC *vc = [[THCouponVC alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//
//}
//-(void)tapLocation{
//    
//    [[TNBaiduMapManager defaultManager] reverseGeocodeWithLocation:_locationCoordinate2D completion:^(BMKReverseGeoCodeResult *result, BMKSearchErrorCode error) {
//        if (error == BMK_SEARCH_NO_ERROR) {
//            MMLog(@"%@",result.address);
//            MMLog(@"%@%@",result.address,[result.poiList[0] name]);
//            [_location setTitle:[NSString stringWithFormat:@"%@",result.addressDetail.city] forState:UIControlStateNormal];
//            self.navigationItem.title = [NSString stringWithFormat:@"%@%@",result.address,[result.poiList[0] name]];
//        }
//    }];

//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (error == BMK_SEARCH_NO_ERROR) {
////                _locationLabel.text =  [NSString stringWithFormat:@"当前地址:%@",result.address];
//                if ([result.addressDetail.province isEqualToString:@"上海市"] ||
//                    [result.addressDetail.province isEqualToString:@"北京市"] ||
//                    [result.addressDetail.province isEqualToString:@"天津市"] ||
//                    [result.addressDetail.province isEqualToString:@"重庆市"])
//                {
////                    self.city = result.addressDetail.district;
////                    self.province = result.addressDetail.city;
//                }
//                else
//                {
////                    self.city = result.addressDetail.city;
////                    self.province = result.addressDetail.province;
//                }
//            }
//        }

//}
//- (void)initLocation
//{
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    if (status < 3) {
//        
//    }
//    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status)
//    {
//        [TNToast showWithText:@"请开启定位功能"];
//    }
//    else
//    {
//        if (![TNLocationManager defaultManager].latestLocation.isValid)
//        {
//            [[TNLocationManager defaultManager] locateOnceWithAccuracy:kCLLocationAccuracyKilometer completion:^(TNLocation *location, NSError *error) {
//                // 转换GPS坐标至百度坐标  百度SDK提供的方法
//                _locationCoordinate2D= BMKCoorDictionaryDecode(BMKConvertBaiduCoorFrom(CLLocationCoordinate2DMake(location.latitude,location.longitude),BMK_COORDTYPE_GPS));
//                [self tapLocation];
//            }];
//        }
//        else
//        {
//            if ([TNLocationManager defaultManager].latestLocation)
//            {
//                // 转换GPS坐标至百度坐标  百度SDK提供的方法
//                _locationCoordinate2D= BMKCoorDictionaryDecode(BMKConvertBaiduCoorFrom(CLLocationCoordinate2DMake( [TNLocationManager defaultManager].latestLocation.latitude,[TNLocationManager defaultManager].latestLocation.longitude),BMK_COORDTYPE_GPS));
//                [self tapLocation];
//            }
//        }
//    }
//}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.navigationBarHidden = NO;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.navigationBarHidden = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refreshToken{
    NSString *path = [NSString stringWithFormat:@"%@/auth/refresh-token",kHeaderURL];
    [[THRequstManager sharedManager] asynGET:path   blockUserInteraction:NO messageDuring:0.5 withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code==1) {
            NSUserDefaults* ud=[NSUserDefaults standardUserDefaults];
            //            NSDate *date = [NSDate date];
            //            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            //            NSInteger interval = [zone secondsFromGMTForDate: date];
            //            NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
            [ud setObject:[NSDate date] forKey:@"refreshTokenTime"];
            TNUser *user = [TNAppContext currentContext].user;
            user.token = responseObject[@"data"][@"token"];
            [TNAppContext currentContext].user = user;
            [[TNAppContext currentContext] saveUser];
//            DLog(@"%@",[TNAppContext currentContext].user.token);
//#ifdef DEBUG
//            [TNToast showWithText:@"刷新token"];
//#endif
        }
    }];
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
