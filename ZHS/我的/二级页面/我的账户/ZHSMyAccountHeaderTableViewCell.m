//
//  ZHSMyAccountHeaderTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/21.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSMyAccountHeaderTableViewCell.h"
@interface ZHSMyAccountHeaderTableViewCell()<MMTableCell>
@property (weak, nonatomic) IBOutlet UILabel *riqi;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *qian;
@property (weak, nonatomic) IBOutlet UILabel *miaoshu;

@end
@implementation ZHSMyAccountHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(void)handleCellWithRow:(MMRow *)row{
    NSDictionary *dic = row.rowInfo;
    _riqi.text = [dic[@"when"][@"date"] substringWithRange:NSMakeRange(5, 5)];
    _time.text = [dic[@"when"][@"date"] substringWithRange:NSMakeRange(10, 6)];
    _qian.text = dic[@"money"];
    _miaoshu.text = dic[@"description"];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
