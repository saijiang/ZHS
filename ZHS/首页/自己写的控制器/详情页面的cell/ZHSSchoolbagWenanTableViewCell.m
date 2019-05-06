//
//  ZHSSchoolbagWenanTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/19.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSSchoolbagWenanTableViewCell.h"
@interface ZHSSchoolbagWenanTableViewCell ()<MMTableCell>

@property (weak, nonatomic) IBOutlet UILabel *sumylable;
@end
@implementation ZHSSchoolbagWenanTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
-(void)handleCellWithRow:(MMRow *)row{
    self.sumylable.text = ((NSString*)row.rowInfo).length?((NSString*)row.rowInfo):@"不好意思，小编还没来得及编辑……";
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
