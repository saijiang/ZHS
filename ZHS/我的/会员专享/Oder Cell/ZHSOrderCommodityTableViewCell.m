//
//  ZHSOrderCommodityTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 16/7/12.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSOrderCommodityTableViewCell.h"
@interface ZHSOrderCommodityTableViewCell ()<MMTableCell>
@property (weak, nonatomic) IBOutlet UIImageView *commodityImage;

@end
@implementation ZHSOrderCommodityTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.commodityImage.layer.borderWidth = 1;
    self.commodityImage.layer.borderColor = [[TNAppContext currentContext] getColor:@"#e3e2e2"].CGColor;
}
-(void)handleCellWithRow:(MMRow *)row{
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
