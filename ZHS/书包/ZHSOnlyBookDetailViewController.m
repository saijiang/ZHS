//
//  ZHSOnlyBookDetailViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/5/14.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSOnlyBookDetailViewController.h"
#import "ZHSSchoolbag.h"
#import "ZHSBooks.h"
#import "ZHSShoolbagDetailViewController.h"
#import "ZHSMyCenterOfPrepaidViewController.h"

@interface ZHSOnlyBookDetailViewController ()
{
    ZHSBooks *_book;
    NSMutableArray *_tuiJianSchoolbagsArray;
}

@property (weak, nonatomic) IBOutlet UIButton *collectBtn;


@property (weak, nonatomic) IBOutlet UIButton *liJiJieYue;



@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UILabel *bookName;
@property (weak, nonatomic) IBOutlet UILabel *boonISBN;
@property (weak, nonatomic) IBOutlet UILabel *bookWriter;
@property (weak, nonatomic) IBOutlet UILabel *bookOfPublishingCompany;
@property (weak, nonatomic) IBOutlet UILabel *booktext;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentView_H;

@end

@implementation ZHSOnlyBookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    _tuiJianSchoolbagsArray = [@[] mutableCopy];

//    self.navigationController.navigationItem.title = @"详情";
    self.navigationItem.title = @"详情";
}
-(void)initView{
    if ([self.cancelCollection isEqualToString:@"yes"]) {
        [self.collectBtn setTitle:@"取消收藏" forState:UIControlStateNormal];
    }
    TNUser *user = [TNAppContext currentContext].user;
    if (!user.school_class_info.count) {
        [self.liJiJieYue setTitle:@"加入班级" forState:UIControlStateNormal];
    }
}
-(void)initData{
    _book = self.schoolbag.books_list[0];
    [self.bookImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kUrl,_book.images[0][@"large"]]]];
    self.bookName.text =  _book.title;

    self.boonISBN.text = [NSString stringWithFormat:@"ISBN:%@", _book.isbn];
    self.bookWriter.text = [NSString stringWithFormat:@"作者:%@", _book.authors.firstObject[@"name"]];
    self.bookOfPublishingCompany.text = [NSString stringWithFormat:@"出版社:%@", _book.press];
    self.booktext.text =  _book.summary.length ? _book.summary : @"不好意思，小编还没来得及编辑……";
    self.contentView_H.constant = ([[TNAppContext currentContext]heightFordetailText:_book.summary andWidth:kWidth-36 andFontOfSize:14.0f]+400)<kHight-120?kHight-120:([[TNAppContext currentContext]heightFordetailText:_book.summary andWidth:kWidth-36 andFontOfSize:14.0f]+400);

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ============ 收藏
- (IBAction)collection:(id)sender {
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
    }];}
#pragma mark ============ 预借

- (IBAction)pre_borrow:(id)sender {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
