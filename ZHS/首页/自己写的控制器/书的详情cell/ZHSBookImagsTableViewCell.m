//
//  ZHSBookImagsTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/11.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSBookImagsTableViewCell.h"
#import "TNImageScrollView.h"
#import "UIImageView+WebCache.h"
@interface ZHSBookImagsTableViewCell ()<MMTableCell>
@property (weak, nonatomic) IBOutlet UIView *imageviews;

@end

@implementation ZHSBookImagsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    TNImageScrollView *images = [[TNImageScrollView alloc] initWithFrame:CGRectMake(0, 0, kWidth, self.imageviews.frame.size.height)];
    images.with =105.0f;
    images.heights = 132.0f;
    images.separateDistance = 20.0f;
    images.autoRun = NO;
    images.isCycel = NO;
    images.titleHidden = YES;
    images.pageControlOpen = NO;
    images.isPlay = YES;
//    [images Ary:imageurls];

    [self.imageviews addSubview:images];

}
-(void)handleCellWithRow:(MMRow *)row{
    TNImageScrollView * images = (TNImageScrollView*)self.imageviews.subviews[0];
    __block NSMutableArray *imageurls = [@[] mutableCopy];
    imageurls = row.rowInfo;
//    [_schoolbag.books_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        ZHSBooks *BOOK = obj;
//        NSString *str = BOOK.images[@"large"];
//        [imageurls addObject:[NSString stringWithFormat:@"%@%@",kUrl,str]];
//    }];
    UIScrollView *scroll = images.scrollView;
    UIView *view = (UIView*)images.subviews[0] ;
    if (view.subviews.count) {
        if (scroll.subviews.count == imageurls.count) {
            [scroll.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = obj;
                    [imageView sd_setImageWithURL:[NSURL URLWithString:imageurls[(idx)]] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
                }
            }];
        }else{
            [scroll removeFromSuperview];
//            images.titles = strAry;
            [images Ary:imageurls];        }

    }else{
        [images Ary:imageurls];
    }

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
