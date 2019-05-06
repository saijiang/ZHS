//
//  ZHSSchoolbagDetailMiaoShuTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/19.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSSchoolbagDetailMiaoShuTableViewCell.h"

#import "ZHSSchoolbag.h"

@interface ZHSSchoolbagDetailMiaoShuTableViewCell ()<MMTableCell>
@property (weak, nonatomic) IBOutlet UILabel *titleL;

@property (weak, nonatomic) IBOutlet UILabel *des;

@end
@implementation ZHSSchoolbagDetailMiaoShuTableViewCell

- (void)awakeFromNib {
    // Initialization code

    

}
-(void)handleCellWithRow:(MMRow *)row{
    ZHSSchoolbag*bag = row.rowInfo;
    _titleL.text = bag.title;
    _des.text = bag.descriptions;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
