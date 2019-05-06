//
//  ZHSOrderlistTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/18.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSOrderlistTableViewCell.h"

@interface ZHSOrderlistTableViewCell()<MMTableCell>

@property (weak, nonatomic) IBOutlet UILabel *TitleLable;
@property (weak, nonatomic) IBOutlet UIImageView *duihaoImage;
@end

@implementation ZHSOrderlistTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(void)handleCellWithRow:(MMRow *)row{

    NSDictionary *dic = row.rowInfo;
    self.TitleLable.text = dic[@"name"];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.duihaoImage.hidden = NO;
    }else{
        self.duihaoImage.hidden = YES;

    }
    // Configure the view for the selected state
}

@end
