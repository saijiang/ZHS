//
//  ZHSMyAccountViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/21.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSMyAccountViewController.h"
#import "ZHSMyCenterOfPrepaidViewController.h"
#import "ZHSMyYishouyiViewController.h"

@interface ZHSMyAccountViewController ()<MMTableViewHandleDelegate>
{
    __block NSMutableArray *logs;
}

@property (weak, nonatomic) IBOutlet UILabel *yishouyi;
@property (weak, nonatomic) IBOutlet UILabel *daishouyi;
@property (weak, nonatomic) IBOutlet UILabel *yanjin;
@property (weak, nonatomic) IBOutlet UILabel *yajinmiaoshuLable;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *jianbianView;
@property(strong,nonatomic)MMTableViewHandle *handle;

@end

@implementation ZHSMyAccountViewController
- (IBAction)tap:(UITapGestureRecognizer*)sender {
    switch (sender.view.tag) {
        case 1:
        {
            ZHSMyCenterOfPrepaidViewController *vc = [ZHSMyCenterOfPrepaidViewController new];
            vc.money =  [self.yanjin.text substringFromIndex:1];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
//            [self.navigationController pushViewController:[ZHSMyYishouyiViewController new] animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.navigationBarHidden = YES;
    [self createLeftBarItemWithImage];
    self.navigationItem.title = @"我的账户";
//    _isback = NO;
    [((UIView*)(self.jianbianView[0])).layer insertSublayer:[self shadowAsInverseWithStartPoint:CGPointMake(0.5, 0) andEndPoint:CGPointMake(0.5, 1) startColor:@"#67c758" endColor:@"#ffffff" view:self.jianbianView[0]] atIndex:0];
    [((UIView*)(self.jianbianView[1])).layer insertSublayer:[self shadowAsInverseWithStartPoint:CGPointMake(0.5, 0) andEndPoint:CGPointMake(0.5, 1) startColor:@"#67c758" endColor:@"#ffffff" view:self.jianbianView[1]] atIndex:0];
    [self requestData];
    [self requestMonry];
    logs = [@[] mutableCopy];
    TNUser *user = [TNAppContext currentContext].user;
    if ([user.payment_status isEqualToString:@"not_paid"]) {
        self.yajinmiaoshuLable.text = @"押金（未付）";
    }
    if ([user.payment_status isEqualToString:@"paid"]) {
        self.yajinmiaoshuLable.text = @"押金（已付）";
    }

}
-(void)requestData{
    NSString *path = [NSString stringWithFormat:@"%@/my-center/my-payment-log",kHeaderURL];
    __weak typeof(self)tempself = self;
    [[THRequstManager sharedManager] asynGET:path  withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            [responseObject[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [logs addObject:obj];
            }];
            [tempself requestMyAccountList];
        }
    }];
}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSMyAccountHeaderTableViewCell"];
    //    [_handle registerTableCellNibWithIdentifier:@"ZHSMyJieYueJiLuLastTableViewCell"];
    
    
    _handle.delegate = self;
    
    
}
-(void)requestMonry{
    NSString *path = [NSString stringWithFormat:@"%@/my-center/pay-acount",kHeaderURL];
    [[THRequstManager sharedManager] asynGET:path withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            if ([responseObject[@"data"][@"money"] length]) {
                self.yanjin.text = [NSString stringWithFormat:@"￥%@",responseObject[@"data"][@"money"]];
            }
        }
    }];
}
-(void)requestMyAccountList{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection *section = [MMSection tagWithTag:0];
    for (int i = 0; i <logs.count; i ++) {
        MMRow *row = [MMRow rowWithTag:0 rowInfo:logs[i] rowActions:nil height:58 reuseIdentifier:@"ZHSMyAccountHeaderTableViewCell"];
        [section addRow:row];
    }
    [table addSections:@[section]];
    _handle.tableModel = table;
    [_handle reloadTable];
 
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


- (CAGradientLayer *)shadowAsInverseWithStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint startColor:(NSString*)startColor endColor:(NSString*)endColor view:(UIView*)view
{
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    CGRect newGradientLayerFrame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    gradientLayer.frame = newGradientLayerFrame;
    
    //添加渐变的颜色组合
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[[[TNAppContext currentContext] getColor:startColor] colorWithAlphaComponent:0.7]CGColor],
                            (id)[[[[TNAppContext currentContext] getColor:endColor] colorWithAlphaComponent:0.7]CGColor],(id)[[[[TNAppContext currentContext] getColor:startColor] colorWithAlphaComponent:0.7]CGColor],
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:1],
                               nil];
    
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    return gradientLayer;
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
