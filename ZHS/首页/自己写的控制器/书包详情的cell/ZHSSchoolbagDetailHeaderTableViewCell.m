//
//  ZHSSchoolbagDetailHeaderTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/19.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSSchoolbagDetailHeaderTableViewCell.h"
@interface ZHSSchoolbagDetailHeaderTableViewCell ()<MMTableCell>

@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *contentLable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *with;

@end
@implementation ZHSSchoolbagDetailHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code

}
-(void)handleCellWithRow:(MMRow *)row{
    NSDictionary *rowinfo = row.rowInfo;
    NSMutableString * contentStr = [@"" mutableCopy];
    if ([rowinfo[@"title"] isEqualToString:@"作者"]) {
        NSArray *ary = (NSArray*)rowinfo[@"content"];
        for (NSDictionary*dic in ary) {
            [contentStr appendFormat:@"%@  ",dic[@"name"]];
        }
    }else{
        contentStr = rowinfo[@"content"];
    }
    
    if ([contentStr isEqualToString:@"NO"]) {
        self.left.constant = 0;
        self.with.constant = 100;
        self.contentLable.text  = @"";
        self.titleLable.text =rowinfo[@"title"];
        self.titleLable.font = [UIFont systemFontOfSize:15];
    }else
    {
        self.contentLable.text  = contentStr;
        self.titleLable.text =[rowinfo[@"title"] stringByAppendingString:@"："];

    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
