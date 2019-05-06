//
//  ZHSOrderAddressTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 16/7/12.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSOrderAddressTableViewCell.h"
@interface ZHSOrderAddressTableViewCell () <MMTableCell>

@end
@implementation ZHSOrderAddressTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)handleCellWithRow:(MMRow *)row{
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
