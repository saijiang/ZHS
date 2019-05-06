//
//  ZHSHomeOfChildMusicViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/2.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSHomeOfChildMusicViewController.h"
#import "ZHSHomeOfChildMusicCollectionViewCell.h"
#import "PlayerController.h"
#import "ZHSBooks.h"
#import "douPlayer.h"
#import "WtyMusicAnimationView.h"
#import "LBXScanViewController.h"

@interface ZHSHomeOfChildMusicViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,MMNavigationControllerNotificationDelegate,UISearchBarDelegate>
{
    __block NSMutableArray *dataArray;
//    NSInteger num;
    NSIndexPath *_indexPathForPlayOrNO;
    BOOL _isplaying;
    BOOL _isSearch;
}
@property (nonatomic, weak) WtyMusicAnimationView *musicAnimationView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ZHSHomeOfChildMusicViewController
//  从后面的页面pop回来时，会调用这个方法
- (BOOL)viewControllerWillShowWithPop:(NSArray *)viewControllers
{
    if ([viewControllers containsObjectClass:[PlayerController class]]) {
        NSNumber *numObjc = self.navigationController.userinfo;
        _isplaying = numObjc.boolValue;
        [self.collectionview reloadData];    }

    return YES;
}
#pragma mark =========== 搜索的代理方法
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text) {
//        num = 0;
        _isSearch = YES;
//        if (_isSearch) {
            if (dataArray.count) {
                [dataArray removeAllObjects];
            }
//        }
        [self requestDataWithSearchWith:searchBar.text];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.navigationBarHidden = NO;
    _isplaying = [self.musicInfo[@"_isplaying"] boolValue];
    _indexPathForPlayOrNO = self.musicInfo[@"_indexPathForPlayOrNO"];
    _isSearch = NO;
    
    self.title = @"宝宝悦听";
    [self createLeftBarItemWithImage];

    dataArray = [@[] mutableCopy];
    if (kWidth >=375) {
//        _collectionview
    }
    __weak typeof(self)tempSelf = self;
    [_collectionview addPPFooterWithBlock:^{
//        num  = num +1;
        if (_isSearch) {
            [self requestDataWithSearchWith:_searchBar.text];
        }else
        [tempSelf requestDataWithSearchWith:@""];
    }];
    [self requestDataWithSearchWith:@""];
    [_collectionview registerNib:[UINib nibWithNibName:@"ZHSHomeOfChildMusicCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ZHSHomeOfChildMusicCollectionViewCell"];
    
#pragma mark =====初始化右侧的扫码和音乐
    WtyMusicAnimationView *musicAnimation = [[NSBundle mainBundle] loadNibNamed:@"WtyMusicAnimationView" owner:nil options:nil].firstObject;
    musicAnimation.hidden = YES;
    musicAnimation.targat = self;
    musicAnimation.action = @selector(pushToPlayerViewController);
    self.musicAnimationView = musicAnimation;
    
    UIButton* saoma = [UIButton buttonWithType:UIButtonTypeCustom];
    saoma.frame = CGRectMake(50, 10, 25, 25);
    UIImage *image =[UIImage imageNamed:@"scanCode"];
    [saoma addTarget:self action:@selector(scanCode:) forControlEvents:UIControlEventTouchUpInside];
    [saoma setBackgroundImage:image forState:UIControlStateNormal] ;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    [view addSubview:self.musicAnimationView];
    [view addSubview:saoma];
    
    UIBarButtonItem *customUIBarButtonitem = [[UIBarButtonItem alloc] initWithCustomView:view];
    
    
    self.navigationItem.rightBarButtonItem = customUIBarButtonitem;
    
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushPlayerViewController) name:@"推出播放页面" object:nil];

    [center addObserver:self selector:@selector(stopMusicAnimation) name:@"停止音符跳动" object:nil];
    [center addObserver:self selector:@selector(startMusicAnimation) name:@"开始音符跳动" object:nil];
    [center addObserver:self selector:@selector(showMusicAnimation) name:@"显示音符" object:nil];
    [center addObserver:self selector:@selector(hiddenMusicAnimation) name:@"隐藏音符" object:nil];
    PlayerController *vc = [PlayerController sharedManager];
    if (vc.Play) {
        [self showMusicAnimation];
    }

}
#pragma mark =======扫码听书
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
        [self back];
        [[THRequstManager sharedManager]asynGET:[NSString stringWithFormat:@"%@/book/%@/findMedia",kHeaderURL,strScanned] withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            [TNToast showWithText:responseObject[@"message"]];
            if (code ==1) {
                [dataArray removeAllObjects];
                    ZHSBooks *book = [ZHSBooks modelWithJsonDicWithoutMap:responseObject[@"data"]];
                    book.ID = responseObject[@"data"][@"id"];
                    [dataArray addObject:book];
                [_collectionview reloadData];

            }
            [_collectionview.footer endRefreshing];

        }];

    };
    [self.navigationController pushViewController:vc animated:YES];
    
}
#pragma mark 推出播放页面
- (void)pushPlayerViewController
{
    PlayerController *player = [PlayerController sharedManager];
    [self.navigationController pushViewController:player animated:YES];
}

#pragma mark - 显示跳动音符
- (void)showMusicAnimation
{
    BOOL isplay = [[NSUserDefaults standardUserDefaults]boolForKey:@"isPlaying"];
    if (isplay) {
        [self.musicAnimationView startGif];
    } else {
        [self.musicAnimationView stopGif];
    }
    self.musicAnimationView.hidden = NO;
    
}

#pragma mark - 开始跳动音符
- (void)startMusicAnimation
{
    [self.musicAnimationView startGif];
}

#pragma mark - 停止跳动音符
- (void)stopMusicAnimation
{
    [self.musicAnimationView stopGif];
}

#pragma mark - 隐藏音符
- (void)hiddenMusicAnimation
{
    self.musicAnimationView.hidden = YES;
}



- (void)pushToPlayerViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"推出播放页面" object:nil];
}

#pragma mark =========== 请求书的音频

-(void)requestDataWithSearchWith:(NSString*)search{

    NSString *path = [NSString stringWithFormat:@"%@/book/media?offset=%ld&limit=10&search=%@",kHeaderURL,(unsigned long)dataArray.count,search];

    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            
            [responseObject[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ZHSBooks *book = [ZHSBooks modelWithJsonDicWithoutMap:obj];
                book.ID = obj[@"id"];
                [dataArray addObject:book];
            }];
            [_collectionview reloadData];
        }else{
//            [_collectionview removeFooter];
        }
        [_collectionview.footer endRefreshing];

    }];
}
#pragma mark ===========collectionview的代理方法

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    if (_shortcutDataArray.count >1)
//    {
//        return [(NSArray *)_shortcutDataArray[section] count];
//    }
//    else
//    {
        return dataArray.count;
//    }
}

-  (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZHSHomeOfChildMusicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZHSHomeOfChildMusicCollectionViewCell" forIndexPath:indexPath];
    [cell handleCellWithData:dataArray[indexPath.row]];
    if (indexPath.row == _indexPathForPlayOrNO.row) {
        if (_isplaying) {
            cell.playImage.image = [UIImage imageNamed:@"baobaoyueting_stop"];
        }else{
            cell.playImage.image = [UIImage imageNamed:@"play"];
        }
    }else{
        cell.playImage.image = [UIImage imageNamed:@"play"];
    }
    return cell;
}
-(void)requestMusicWithID:(NSString *)ID{

}
#pragma mark ===========collectionView 点击cell 触发的方法

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZHSBooks *book = dataArray[indexPath.row];
    NSString *path = [NSString stringWithFormat:@"%@/book/%@/media?token=%@",kHeaderURL,book.ID,[TNAppContext currentContext].user.token];
//    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
//        if (code ==1) {
            PlayerController *play = [PlayerController sharedManager];
            MusicModel *music = [[MusicModel alloc] init];
            music.name = book.title;
            music.mp3Url = path;
            music.picUrl = [NSString stringWithFormat:@"%@%@",kUrl,book.images[0][@"small"]];
            play.musicModel = music;
            [self.navigationController pushViewController:play animated:YES];
    _indexPathForPlayOrNO = indexPath;
//        }
//    }];

    

//    TNSegueTarget * segue = _shortcutDataArray[indexPath.section][indexPath.row][@"segue"];
//    [TNUtils customSegueToTarget:segue inNavigation:self.navigationController];
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (kWidth == 375) {
        return UIEdgeInsetsMake(5, 15, 5, 15);
    }else if (kWidth>375){
        return UIEdgeInsetsMake(5, 25, 5, 25);
    }else
    return UIEdgeInsetsMake(5, 0, 5, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
}
-(void)back{
    NSMutableDictionary *dic = [@{} mutableCopy];
    if (_indexPathForPlayOrNO) {
        [dic setValue:_indexPathForPlayOrNO forKey:@"_indexPathForPlayOrNO"];
        [dic setValue:@(_isplaying) forKey:@"_isplaying"];
    }
    [self.navigationController popViewControllerAnimated:YES withUserinfo:dic];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
