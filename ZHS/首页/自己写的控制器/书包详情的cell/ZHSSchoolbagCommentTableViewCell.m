//
//  ZHSSchoolbagCommentTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/19.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSSchoolbagCommentTableViewCell.h"

@interface ZHSSchoolbagCommentTableViewCell() <MMTableCell>
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *stars;

@end

@implementation ZHSSchoolbagCommentTableViewCell

- (void)awakeFromNib {
//    for (UIButton*btn in _stars) {
//        [btn setTitle: [NSString fontAwesomeIconStringForIconIdentifier:@"fa-star"] forState:UIControlStateNormal];
//        [btn.titleLabel setFont:[UIFont fontAwesomeFontOfSize:10]];
//    }

}
-(void)handleCellWithRow:(MMRow *)row{
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
