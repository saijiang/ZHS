//
//  ZHSBookTitleTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/10.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSBookTitleTableViewCell.h"
#import "ZHSBooks.h"
#import "ZHSSchoolbag.h"

@interface ZHSBookTitleTableViewCell ()<MMTableCell>
{
    NSArray *books;
    NSInteger flog;// 标记当前的是数组的哪一个
    NSArray *_actions;
}
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWith;

@end
@implementation ZHSBookTitleTableViewCell
- (IBAction)rightClick:(id)sender {
    flog++;
    if (flog == books.count) {
        flog = 0;
    }
    self.titleL.text = [(ZHSBooks*)books[flog] title];
    
    void (^block)(NSInteger flog,ZHSBooks*book) = _actions[0];
    if (block) {
        block(flog,(ZHSBooks*)books[flog]);
    }
    
}
- (IBAction)leftClick:(id)sender {
    flog--;
    if (flog<0) {
        flog = books.count-1;
    }
    self.titleL.text = [(ZHSBooks*)books[flog] title];
    void (^block)(NSInteger flog,ZHSBooks*book) = _actions[0];
    if (block) {
        block(flog,(ZHSBooks*)books[flog]);
    }

}

- (void)awakeFromNib {
    // Initialization code
//    flog = 0;
//    self.titleL.text = [(ZHSBooks*)books[flog] title];

}
-(void)handleCellWithRow:(MMRow *)row{
    ZHSSchoolbag *schoolbag = row.rowInfo[@"data"];
    _actions = row.rowActions;
    flog = [row.rowInfo[@"num"] integerValue];
    books = schoolbag.books_list;
    self.titleL.text = [(ZHSBooks*)books[flog] title];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
