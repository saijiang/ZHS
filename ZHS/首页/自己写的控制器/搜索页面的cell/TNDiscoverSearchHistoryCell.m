//
//  TNDiscoverSearchHistoryCell.m
//  searchDemo
//
//  Created by marcus on 15/7/21.
//  Copyright (c) 2015年 marcus. All rights reserved.
//

#import "TNDiscoverSearchHistoryCell.h"
#import "MMLib.h"

@interface TNDiscoverSearchHistoryCell() <MMTableCell>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation TNDiscoverSearchHistoryCell

-(void)handleCellWithRow:(MMRow *)row{
    NSString * title = row.rowInfo;
    _titleLabel.text = title;
}

- (void)awakeFromNib {
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
