//
//  ZHSMyInfoXingQuViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/2/20.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSMyInfoXingQuViewController.h"
#import "ZHSRegisterViewController.h"

@interface ZHSMyInfoXingQuViewController ()<MMTableViewHandleDelegate>
{
    NSMutableArray *_dataArray;
    NSMutableSet *_interestingsSet;

}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(nonatomic,strong)MMTableViewHandle *handle;
@end

@implementation ZHSMyInfoXingQuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"兴趣爱好";
    [self createRightBarItemWithTitle:@"完成"];
    _interestingsSet = [NSMutableSet set];
}
-(void)clickRightSender:(UIButton *)sender{
    if (_interestingsSet.count) {
        __block NSMutableArray *postDataArray = [@[] mutableCopy];
        [_interestingsSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary *btn = obj;
            [postDataArray addObject:@{@"id":btn[@"id"]}];
        }];
        __weak typeof(self)tempSelf = self;
        [[THRequstManager sharedManager] asynPOST:[NSString stringWithFormat:@"%@/customer/update",kHeaderURL] parameters:@{@"interests": postDataArray} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
            if (code==1) {
                TNUser *user = [TNUser modelWithJsonDicWithoutMap:responseObject[@"data"]];
                user.interests = responseObject[@"data"][@"interests"];
                user.token = [TNAppContext currentContext].user.token;
                user.ID = [TNAppContext currentContext].user.ID;
                [TNAppContext currentContext].user = user;
                [[TNAppContext currentContext] saveUser];
                if ([self.navigationController.viewControllers containsObjectClass:[ZHSRegisterViewController class]]) {
                    [tempSelf dismissViewControllerAnimated:YES completion:nil];
                    [TNFlowUtil startMainFlow];
                }else
                [tempSelf back];
            }
        }];
    }
}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"TNDiscoverSearchHistoryCell"];
    [_handle registerTableCellNibWithIdentifier:@"TNDiscoverHotSearchCell"];
    _handle.delegate = self;
    [self requstInterseting];
    
    //    _mainTableHandle = [MMTableViewHandle handleWithTableView:_mainTable];
    //    [_mainTableHandle registerTableCellNibWithIdentifier:@"THDiscoverCell"];
    //    _mainTableHandle.delegate = self;
    
//    __weak __typeof(self) tempSelf = self;
//    [_searchTableHandle setScrollDidScrollBlock:^(MMTableViewHandle *tableHandle, CGPoint offset) {
//        
//        [tempSelf.searchBar resignFirstResponder];
//    }];
    
//    _dataArray = [@[
//  @{@"type_name":@"音乐",@"type_child":@[@"声乐",@"钢琴",@"小提琴",@"吉他",@"架子鼓",@"古筝",@"笛子",@"小号",@"电子琴"]
//    },
//  @{@"type_name":@"运动",@"type_child":@[@"游泳",@"跆拳道",@"击剑",@"乒乓球",@"足球",@"轮滑",@"户外拓展"]
//    },
//  @{@"type_name":@"艺术",@"type_child":@[@"美术",@"陶艺",@"书法",@"手工制作"]
//    },
//  @{@"type_name":@"智力",@"type_child":@[@"象棋",@"围棋",@"全脑开发",@"识字速算",@"记忆力"]
//    },
//  @{@"type_name":@"舞蹈",@"type_child":@[@"拉丁舞",@"芭蕾舞",@"爵士舞",@"民族舞",@"架子鼓",@"古典舞"]
//        },
//  @{@"type_name":@"国学",@"type_child":@[@"经典诵读",@"国学讲习"]
//    },
//  @{@"type_name":@"英语",@"type_child":@[@"英语"]
//    }
//  ] mutableCopy];
}
-(void)requstInterseting{
    NSString *path = [NSString stringWithFormat:@"%@/interest-categories",kHeaderURL];
    __weak typeof(self)tempself = self;
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            _dataArray = [responseObject[@"data"] mutableCopy];
            [tempself reloadDataForSearchTable];
        }else{
            //            [TNToast showWithText:responseObject[@"message"]];
            
        }
    }];
}
-(void)reloadDataForSearchTable{

    MMTable * table = [MMTable tagWithTag:0];
    _handle.tableModel = table;
//    __weak __typeof(self) tempSelf = self;
    //刷新热门搜索区域数据
    if (_dataArray && _dataArray.count>0) {
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dataDic = obj;
            MMSection * section = [MMSection tagWithTag:0];
            UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 30)];
            view.backgroundColor = UIColorWithCode(0xebebeb);
            UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, kWidth, 29)];
            title.font = [UIFont italicSystemFontOfSize:17];
            title.backgroundColor = UIColorWithCode(0xebebeb);
            title.textColor = UIColorWithCode(0x666666);
            title.text = [NSString stringWithFormat:@"%@", dataDic[@"name"]];
            [view addSubview:title];
            section.headerView = view;
            section.heightForHeader = 38;
//            UIView * footView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 5)];
//            footView1.backgroundColor = [UIColor whiteColor];
//            UIView * footView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 15)];
//            footView2.backgroundColor = UIColorWithCode(0xeeeeee);
//            UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 5, kWidth, 0.5)];
//            line1.backgroundColor = UIColorWithCode(0xcccccc);
//            UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 14, kWidth, 0.5)];
//            line2.backgroundColor = UIColorWithCode(0xcccccc);
//            [footView2 addSubview:footView1];
//            [footView2 addSubview:line1];
//            [footView2 addSubview:line2];
//            section.footerView = footView2;
//            section.heightForFooter = 15;
            [table addSection:section];
            
            //      将热门搜索的值每四个绑定为一组
            NSInteger icount=0;
            NSMutableArray *classAry = [dataDic[@"sub_categories"] mutableCopy];
            NSMutableArray * tempArray = [[NSMutableArray alloc]init];
            for (int i=0; i<classAry.count; i++) {
                icount++;
                [tempArray addObject:classAry[i]];
                if (icount==4) {
                    MMRow * row = [MMRow rowWithTag:0
                                            rowInfo:tempArray
                                         rowActions:^(NSDictionary * temp,NSNumber* isSelceted){;
                                             
                                             if (isSelceted.boolValue) {
                                                 [_interestingsSet addObject:temp];
                                             }else{
                                                 [_interestingsSet removeObject:temp];
                                             }
                                         }
                                             height:45
                                    reuseIdentifier:@"TNDiscoverHotSearchCell"];
                    [section addRow:row];
                    icount = 0;
                    tempArray = [[NSMutableArray alloc]init];
                }
            }
            if (tempArray.count>0){
                MMRow * row = [MMRow rowWithTag:0
                                        rowInfo:tempArray
                                     rowActions:^(NSDictionary * temp,NSNumber* isSelceted){
                                         //                                     tempSelf.page = 1;
//                                         [self writeDataWithContent:tempStr];
                                         //                                     [tempSelf requestDataWithContent:tempStr];
                                         
                                         if (isSelceted.boolValue) {
                                             [_interestingsSet addObject:temp];
                                         }else{
                                             [_interestingsSet removeObject:temp];
                                         }
                                     }
                                         height:45
                                reuseIdentifier:@"TNDiscoverHotSearchCell"];
                [section addRow:row];
            }
        }];
       
    }
    [_tableview reloadData];
}
  

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)reclaimedKeyboard{
    [self.view endEditing:YES];
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
