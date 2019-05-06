//
//  ZHSSchoolbagPLTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/19.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSSchoolbagPLTableViewCell.h"

@interface ZHSSchoolbagPLTableViewCell ()<MMTableCell>
@property (weak, nonatomic) IBOutlet UIButton *pinglunBack;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *stars;
@end
@implementation ZHSSchoolbagPLTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    [_pinglunBack setTitle: [NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-right"] forState:UIControlStateNormal];
//    [_pinglunBack.titleLabel setFont:[UIFont fontAwesomeFontOfSize:30]];
//    for (UIButton*btn in _stars) {
//        [btn setTitle: [NSString fontAwesomeIconStringForIconIdentifier:@"fa-star"] forState:UIControlStateNormal];
//        [btn.titleLabel setFont:[UIFont fontAwesomeFontOfSize:13]];
//    }
}
-(void)handleCellWithRow:(MMRow *)row
{

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
