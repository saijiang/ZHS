//
//  ZHSMyCollectionTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/17.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSMyCollectionTableViewCell.h"
#import "ZHSSchoolbag.h"
#import "UIImageView+WebCache.h"
#import "ZHSBooks.h"

@interface ZHSMyCollectionTableViewCell()<MMTableCell>
{
    NSArray *_actions;
    NSArray * _dataAry;

}
#pragma mark ========图片的描边

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *miaobianV;





@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *schoolbages;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageviews;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lables;

@end
@implementation ZHSMyCollectionTableViewCell


- (void)awakeFromNib {
    // Initialization code
    [_schoolbages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapimageView:)];
        [obj addGestureRecognizer:gr];
    }];
    [self.miaobianV enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = obj;
        view.layer.borderColor = [[TNAppContext currentContext] getColor:@"#ececec"].CGColor;
        view.layer.borderWidth = 1;
        
        UIImageView*image = _imageviews[idx];
        image.layer.borderWidth = 1;
        image.layer.borderColor = [[TNAppContext currentContext] getColor:@"#e3e2e2"].CGColor;
    }];
}
-(void)didTapimageView:(UITapGestureRecognizer*)tap{
    void (^block)(ZHSSchoolbag*) = _actions[0];
    if (block) {
        block(_dataAry[tap.view.tag-1]);
    }
}
-(void)handleCellWithRow:(MMRow *)row{
    NSArray * dataAry = row.rowInfo;
    _dataAry = row.rowInfo;
    _actions = row.rowActions;
    [dataAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHSSchoolbag *schoolbag = obj;
        ((UILabel*)_lables[idx]).text = schoolbag.title;
        ZHSBooks *book;
        if (idx>=schoolbag.books_list.count) {
            book = schoolbag.books_list[0];
        }else{
            book = schoolbag.books_list[idx];
        }
        NSString*imageString = [NSString stringWithFormat:@"http://admin.cctvzhs.com%@",book.images[0][@"small"]];
        [(UIImageView*)_imageviews[idx] sd_setImageWithURL:[NSURL URLWithString: imageString] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
        ((UIView*)_schoolbages[idx]).hidden = NO;
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
