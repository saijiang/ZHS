//
//  ZHSOrderInputTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/18.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSOrderInputTableViewCell.h"

@interface ZHSOrderInputTableViewCell()<MMTableCell,UITextFieldDelegate>
{
    NSMutableArray*_actions;
}

@end
@implementation ZHSOrderInputTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.inputTF.delegate = self;
}
-(void)handleCellWithRow:(MMRow *)row{
    self.titleLable.text = row.rowInfo[0];
    _actions = row.rowActions;
    if (((NSArray*)row.rowInfo).count>1) {
        self.inputTF.text = row.rowInfo[1];
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([self.titleLable.text isEqualToString:@"绘 本 馆"]) {
        [self.inputTF resignFirstResponder];
        void (^block)() = _actions[1];
        if (block) {
            block();
        }
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    void (^block)(NSString *text) = _actions[0];
    if (block) {
        block(textField.text);
    }
}
@end
