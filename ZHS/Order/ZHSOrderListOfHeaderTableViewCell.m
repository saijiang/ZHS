//
//  ZHSOrderListOfHeaderTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/18.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSOrderListOfHeaderTableViewCell.h"

@interface ZHSOrderListOfHeaderTableViewCell()<MMTableCell>
{
    NSMutableArray*_actions;
}
@end
@implementation ZHSOrderListOfHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(void)handleCellWithRow:(MMRow *)row{
    _actions  = row.rowActions;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)backto:(id)sender {
    void(^block)() = _actions[0];
    if (block) {
        block();
    }
}

@end
