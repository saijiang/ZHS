//
//  ZHSBorrowLogsDetailViewController.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/14.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSBorrowLogsDetailViewController.h"
#import "ZHSBorrowLog.h"
#import "ZHSBooks.h"
#import "MMLineBorderButton.h"
#import "ZHSMyQRViewController.h"
#import "ZHSMyYiJianJieYueViewController.h"

@interface ZHSBorrowLogsDetailViewController ()<MMTableViewHandleDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(strong,nonatomic)MMTableViewHandle *handle;
@property (weak, nonatomic) IBOutlet MMLineBorderButton *cancle;
@property (weak, nonatomic) IBOutlet MMLineBorderButton *qushuCode;
@property (weak, nonatomic) IBOutlet MMLineBorderButton *qushu;

@end

@implementation ZHSBorrowLogsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createLeftBarItemWithImage];
    if (self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = NO;
    }

    self.navigationItem.title = self.borrowlog.schoolbag.title;
    ZHSBorrowLog*log = _borrowlog;
    if ([log.status isEqualToString:@"borrowed"]) {

    }
    if ([log.status isEqualToString:@"finished"]) {

    }
    if ([log.status isEqualToString:@"pre-borrow"]) {
        self.bottomView.hidden = NO;
    }


}
-(void)initData{
    _handle = [MMTableViewHandle handleWithTableView:_tableview];
    [_handle registerTableCellNibWithIdentifier:@"ZHSBookImagsTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagDetailMiaoShuTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagWenanTableViewCell"];
    [_handle registerTableCellNibWithIdentifier:@"ZHSSchoolbagPLTableViewCell"];
    
    
    _handle.delegate = self;
    [self reloadBorrowLogsData];
}
-(void)reloadBorrowLogsData{
    MMTable *table = [MMTable tagWithTag:0];
    MMSection*section_1 = [MMSection tagWithTag:0];
    NSMutableArray *bookimages = [@[] mutableCopy];
    
    [_borrowlog.schoolbag.books_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHSBooks *book = obj;
        [bookimages addObject:[NSString stringWithFormat:@"%@%@",kUrl,book.images[0][@"small"]]];
    }];
    if (kIsBookMode) {
        NSArray*list = ((ZHSBooks*)_borrowlog.schoolbag.books_list[0]).images;
        NSMutableArray *imagesurlAry = [@[] mutableCopy];
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *imageurl = obj[@"small"];
            [imagesurlAry addObject:[NSString stringWithFormat:@"%@%@",kUrl,imageurl]];
        }];
        bookimages = imagesurlAry;
    }
    MMRow *row_1_1 = [MMRow rowWithTag:0 rowInfo:bookimages rowActions:nil height:165 reuseIdentifier:@"ZHSBookImagsTableViewCell"];
    [section_1 addRow:row_1_1];
    
    
    
    /* 遍历拼接书目的名字 */
    __block NSMutableString *shumuStr  = [@"" mutableCopy];
    [self.borrowlog.schoolbag.books_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHSBooks *book = obj;
        if (idx == _borrowlog.schoolbag.books_list.count-1) {
            [shumuStr appendFormat:@"%@",book.title];
        }else
            [shumuStr appendFormat:@"%@、",book.title];
    }];
    /* 遍历拼接主题的名字 */
//    __block NSMutableString *nianlingStr  = [@"" mutableCopy];
    __block NSMutableString *zhutiStr  = [@"" mutableCopy];
    [self.borrowlog.schoolbag.tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
//        if ([dic[@"category"] isEqualToString:@"age"]) {
//            [nianlingStr appendString:dic[@"name"]];
//        }
//        if ([dic[@"category"] isEqualToString:@"theme"]) {
            [ zhutiStr appendFormat:@"%@、" ,dic[@"name"]];
//        }
        
    }];
    
    MMRow *r1 = [MMRow rowWithTag:0 rowInfo:@{@"title":@"「书包详情」",@"content":@"NO"} rowActions:nil height:39 reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
    [section_1 addRow:r1];
    NSString *status;
    NSMutableDictionary *dic = [@{} mutableCopy];
    NSMutableDictionary *dic1 = [@{} mutableCopy];

    if ([_borrowlog.status isEqualToString:@"pre-borrow"]) {
        status = @"已预借";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate*date= [formatter dateFromString:(NSString*)_borrowlog.created_at];
        NSDate *date1 = [NSDate dateWithTimeInterval:2*24*60*60 sinceDate:date];
        [dic setValue:@"预借时间" forKey:@"title"];
        [dic1 setValue:@"预借截止" forKey:@"title"];
        [dic setValue:[(NSString*)_borrowlog.created_at  substringToIndex:10] forKey:@"content"];
        [dic1 setValue:[[NSString stringWithFormat:@"%@",date1]  substringToIndex:10] forKey:@"content"];

    }else if ([_borrowlog.status isEqualToString:@"borrowed"]){
        status = @"借阅中";
        [dic setValue:@"借阅时间" forKey:@"title"];
        [dic1 setValue:@"借阅截止" forKey:@"title"];
        [dic setValue:[(NSString*)_borrowlog.borrow_start  substringToIndex:10] forKey:@"content"];
        [dic1 setValue:[(NSString*)_borrowlog.borrow_end  substringToIndex:10] forKey:@"content"];
    }else if ([_borrowlog.status isEqualToString:@"finished"]){
        if (_borrowlog.return_at) {
            status = @"已归还";
            [dic setValue:@"借阅时间" forKey:@"title"];
            [dic1 setValue:@"归还时间" forKey:@"title"];
            [dic setValue:[(NSString*)_borrowlog.borrow_start  substringToIndex:10] forKey:@"content"];
            [dic1 setValue:[(NSString*)_borrowlog.return_at  substringToIndex:10] forKey:@"content"];
        }else{
        status = @"取消预借";
                [dic setValue:@"预借时间" forKey:@"title"];
                [dic1 setValue:@"取消时间" forKey:@"title"];
                [dic setValue:[(NSString*)_borrowlog.created_at  substringToIndex:10] forKey:@"content"];
                [dic1 setValue:[(NSString*)_borrowlog.updated_at  substringToIndex:10] forKey:@"content"];
            }
    }else if ([_borrowlog.status isEqualToString:@"overdue"]){
        status = @"逾期未还";
        [dic setValue:@"借阅时间" forKey:@"title"];
        [dic1 setValue:@"借阅截止" forKey:@"title"];
        [dic setValue:[(NSString*)_borrowlog.borrow_start  substringToIndex:10] forKey:@"content"];
        [dic1 setValue:[(NSString*)_borrowlog.borrow_end  substringToIndex:10] forKey:@"content"];
    }
    

    NSArray *dataArray = @[@{@"title":@"书    目",@"content":shumuStr},@{@"title":@"适合年级",@"content":self.borrowlog.schoolbag.class_level},@{@"title":@"书包标签",@"content":zhutiStr.length?[zhutiStr substringToIndex:zhutiStr.length-1]:@""},@{@"title":@"借阅状态",@"content":status},dic,dic1];
    [dataArray enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        NSDictionary *dic = obj;
        CGFloat H =[[TNAppContext currentContext] heightFordetailText:dic[@"content"] andWidth:kWidth-108 andFontOfSize:14.0f];
        MMRow *row = [MMRow rowWithTag:0 rowInfo:dic rowActions:nil height:MAX(39, H+21) reuseIdentifier:@"ZHSSchoolbagDetailHeaderTableViewCell"];
        [section_1 addRow:row];
    }];
    
    
    
//    [_borrowlogs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        MMRow *row = [MMRow rowWithTag:0 rowInfo:obj rowActions:nil height:160 reuseIdentifier:@"ZHSMyJieYueJiLuTableViewCell"];
//        [section addRow:row];
//        
//    }];
//    
//    
//    MMRow *row2 = [MMRow rowWithTag:0 rowInfo:nil rowActions:nil height:160 reuseIdentifier:@"ZHSMyJieYueJiLuLastTableViewCell"];
//    [section addRow:row2];
//    section.heightForFooter = 10;
    [table addSections:@[section_1]];
    _handle.tableModel = table;
    [_handle reloadTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancle:(id)sender {
    NSString *path = [NSString stringWithFormat:@"%@/my-center/pre-borrow/cancel",kHeaderURL];
    __weak typeof(self)tempSelf = self;
    [[THRequstManager sharedManager] asynPOST:path parameters:@{@"borrow_code":_borrowlog.borrow_code} withCompeletBlock:^(id responseObject, THRequstErrorCode code, NSError *error) {
        if (code == 1) {
            [TNToast showWithText:@"取消成功"];
            self.navigationController.navigationBar.hidden = YES;
            [tempSelf.navigationController popToRootViewControllerAnimated:YES];

        }
    }];
}
- (IBAction)qushu:(id)sender {
    [self.navigationController pushViewController:[ZHSMyYiJianJieYueViewController new] animated:YES];

}
- (IBAction)qushuCode:(id)sender {
    ZHSMyQRViewController *vc = [ZHSMyQRViewController new];
    vc.qushuCode = _borrowlog.borrow_code;
    [self.navigationController pushViewController:vc animated:YES];
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
