//
//  TNDiscoverHotSearchCell.m
//  searchDemo
//
//  Created by marcus on 15/7/21.
//  Copyright (c) 2015年 marcus. All rights reserved.
//

#import "TNDiscoverHotSearchCell.h"

#define TagAddValue 1000

@interface TNDiscoverHotSearchCell() <MMTableCell>
{
    NSMutableArray *_data;
}
@property (weak, nonatomic) IBOutlet UIView *rootView;

@property (copy, nonatomic) MMConditionTwoObjectBlock block;

@end

@implementation TNDiscoverHotSearchCell

-(void)handleCellWithRow:(MMRow *)row{
    NSMutableArray * array = row.rowInfo;
    _data =array;
    for (int i=0; i<array.count; i++) {
       UIButton * button = (UIButton*)[self.rootView viewWithTag:TagAddValue+i];
        if (button) {
            [button setTitle:array[i][@"name"] forState:UIControlStateNormal];
            button.tag = i+1;
            [button setBackgroundImage:[UIImage imageNamed:@"navbar"] forState:UIControlStateSelected];
            button.hidden = NO;
        }
    }
    _block = row.rowActions;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buttonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
//    if (sender.selected) {
//        sender.backgroundColor = UIColorWithCode(0x67c738);
//    }else{
//        sender.backgroundColor = [UIColor whiteColor];
//    }
    if (_block) {
        _block(_data[sender.tag-1],@(sender.selected));
    }
}

@end
