//
//  ZHSTheFourPieceTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/18.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSTheFourPieceTableViewCell.h"

@interface ZHSTheFourPieceTableViewCell ()<MMTableCell>
{
    NSArray *_actions;
}
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *views;



@end
@implementation ZHSTheFourPieceTableViewCell

- (void)awakeFromNib {
    // Initialization code
    for (UIView *view in self.views) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
        tapGestureRecognizer.cancelsTouchesInView = NO;
        //将触摸事件添加到当前view
        [view addGestureRecognizer:tapGestureRecognizer];
    }
}
-(void)tapGestureRecognizer:(UITapGestureRecognizer*)tap{
    void(^block)() = _actions[tap.view.tag-1];
    if (block) {
        block();
    }
    
}
-(void)handleCellWithRow:(MMRow *)row{
    _actions = row.rowActions;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
