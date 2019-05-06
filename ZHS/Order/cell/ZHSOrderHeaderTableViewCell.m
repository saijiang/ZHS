//
//  ZHSOrderHeaderTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/18.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSOrderHeaderTableViewCell.h"
@interface ZHSOrderHeaderTableViewCell()<MMTableCell>

@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@end
@implementation ZHSOrderHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(void)handleCellWithRow:(MMRow *)row{
    self.titleLable.text = row.rowInfo;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
