//
//  TNOrderPickerView.m
//  Tuhu
//
//  Created by DengQiang on 14/11/5.
//  Copyright (c) 2014年 telenav. All rights reserved.
//****************************************************************************************
// LAST UPDATE: 2015-08-24   （门店排序）ZengFangYun
//****************************************************************************************

#import "TNOrderPickerView.h"
#import "TNNibUtil.h"

@interface TNOrderPickerView () <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *orders;

@end

@implementation TNOrderPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.orders = [NSMutableArray arrayWithObjects:
                   @{@"name": @"默认排序", @"code":@"HuShi"},
                   @{@"name": @"评分最高", @"code": @"ranking"},
                   @{@"name": @"借阅最多", @"code": @"qty_borrow"},nil];

}

-(void)reloadOrderDataWithShopType:(NSMutableArray*)dataAry{
    if (!dataAry) {
        self.orders = [NSMutableArray arrayWithObjects:
                       @{@"name": @"默认排序", @"code":@"HuShi"},
                       @{@"name": @"评分最高", @"code": @"ranking"},
                       @{@"name": @"借阅最多", @"code": @"qty_borrow"},nil];
    }else
    self.orders = dataAry;
//    if (type == 1) {//轮胎和保养的
//        self.orders = [NSMutableArray arrayWithObjects:
//                       @{@"name": @"默认排序", @"code":@"HuShi"},
//                       @{@"name": @"附近优先"},
//                       @{@"name": @"评分最高", @"code": @"Grade"},
//                       @{@"name": @"累计安装", @"code": @"Install"},
//                       @{@"name": @"技术等级", @"code": @"Skill"},nil];
//        
//    }else if(type == 2){//美容
//        self.orders = [NSMutableArray arrayWithObjects:
//                       @{@"name": @"附近优先"},
//                       @{@"name": @"评分最高", @"code": @"Grade"},
//                       @{@"name": @"累计安装", @"code": @"Install"},nil];
//    }
    [_tableView reloadData];
}

+ (TNOrderPickerView *)viewFromNib
{
    TNOrderPickerView *orderView = [TNNibUtil loadMainObjectFromNib:@"TNOrderPickerView"];
    return orderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.textColor = kTNTextColor0;
        cell.textLabel.font = [UIFont systemFontOfSize:14.f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = self.orders[indexPath.row][@"name"];
    if ([self.orders[indexPath.row][@"name"] isEqualToString:_selectTitle]) {
        cell.textLabel.textColor = kNaverColr;
    }else{
         cell.textLabel.textColor = kTNTextColor0;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orders.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = kNaverColr;
    if ([self.delegate respondsToSelector:@selector(orderPickerView:didSelectOrderWithName:code:)]) {
        NSDictionary *info = self.orders[indexPath.row];
        [self.delegate orderPickerView:self didSelectOrderWithName:info[@"name"] code:info[@"cate"]?info[@"cate"]:info[@"code"]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor = kTNTextColor0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (CGSize)contentSize{
    return self.tableView.contentSize;
}


@end
