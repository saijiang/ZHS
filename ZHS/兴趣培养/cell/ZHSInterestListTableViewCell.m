//
//  ZHSInterestListTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 16/7/14.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSInterestListTableViewCell.h"
@interface ZHSInterestListTableViewCell () <MMTableCell>
@property (weak, nonatomic) IBOutlet UIImageView *Image;

@end
@implementation ZHSInterestListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)handleCellWithRow:(MMRow *)row{
     int value = (arc4random() % 4) + 1;
    _Image.image = [UIImage imageNamed:[NSString stringWithFormat:@"interesting_list%d",value]];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
