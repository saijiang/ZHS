//
//  ZHSSchoolbagForBookTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/4.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSSchoolbagForBookTableViewCell.h"
@interface ZHSSchoolbagForBookTableViewCell() <MMTableCell>

@property (weak, nonatomic) IBOutlet UIView *xianView;
@end

@implementation ZHSSchoolbagForBookTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _xianView.layer.cornerRadius = 5.0f;
    _xianView.layer.borderColor = [[[TNAppContext currentContext] getColor:@"#646464"] CGColor];
    _xianView.layer.borderWidth = 0.5;
}
-(void)handleCellWithRow:(MMRow *)row{
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
