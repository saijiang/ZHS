//
//  ZHSIndexTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/16.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSPictureBookMuseumTableViewCell.h"
#import "TNImageScrollView.h"
#import "ZHSSchoolbag.h"
#import "ZHSBooks.h"
#import "UIImageView+WebCache.h"
@interface ZHSPictureBookMuseumTableViewCell()<MMTableCell>
{
    ZHSSchoolbag *_schoolbag;
}

@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UILabel *jianToulable;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIView *scrollImageView;


@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *tagsL;
@property (weak, nonatomic) IBOutlet UILabel *rankL;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *stars;

@end
@implementation ZHSPictureBookMuseumTableViewCell

- (void)awakeFromNib {
    // Initialization code
#warning 书包列表cell中向右的箭头
//    [_button setTitle: [NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-right"] forState:UIControlStateNormal];
//    [_button.titleLabel setFont:[UIFont fontAwesomeFontOfSize:25]];

    TNImageScrollView *images = [[TNImageScrollView alloc] initWithFrame:CGRectMake(0, 0, kWidth, self.scrollImageView.frame.size.height)];
    images.with =105.0f;
    images.heights = 132.0f;
    images.separateDistance = 15.0f;
    images.autoRun = NO;
    images.isCycel = NO;
    images.pageControlOpen = NO;
    images.titleHidden = NO;
    if (kIsBookMode) {
        images.titleHidden = YES;
    }
    images.titleColor = [[TNAppContext currentContext] getColor:@"#323232"];
    images.titleFont = 11.0f;

    [self.scrollImageView addSubview:images];
}
-(void)handleCellWithRow:(MMRow *)row{
//    self.rightView.frame = CGRectMake(kWidth, 0, 35, self.rightView.frame.size.height-1);
//    [UIView animateWithDuration:1 animations:^{
//        self.rightView.frame = CGRectMake(kWidth-35, 0, 35, self.rightView.frame.size.height-1);
//    }];
    
    ZHSSchoolbag *schoolbag = row.rowInfo;
    _schoolbag = schoolbag;
    
    _titleL.text = schoolbag.title;
    //    self.ageL.text =
    __block NSMutableString *str = [@"" mutableCopy];
//    __weak typeof(self) tempSelf = self;
    [schoolbag.tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
//        if ([dic[@"category"] isEqualToString:@"age"]) {
//            tempSelf.ageL.text = [NSString stringWithFormat:@"适合年龄：%@",dic[@"name"]];
//        }
        
//        if ([dic[@"category"] isEqualToString:@"theme"]) {
            [ str appendFormat:@"%@、" ,dic[@"name"]];
//        }
    }];
    self.tagsL.text = str.length?[str substringToIndex:str.length-1]:@"";
    self.rankL.text = [NSString stringWithFormat:@"%@分",schoolbag.ranking];
    NSInteger rank = schoolbag.ranking.integerValue;
    if ((rank%2) == 0) {
        [self.stars enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx>=(rank/2)) {
                ((UIImageView*)obj).hidden = YES;
            }
            
        }];
    }else{
        [self.stars enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            int num = (int)rank/2/1;
            if (idx == num) {
                ((UIImageView*)obj).image = [UIImage imageNamed:@"star_half"];
            }
            if (idx> num) {
                ((UIImageView*)obj).hidden = YES;
            }
            
        }];
    }

    
    TNImageScrollView * images = (TNImageScrollView*)self.scrollImageView.subviews[0];
    __block NSMutableArray *imageurls = [@[] mutableCopy];
    __block NSMutableArray *strAry = [@[] mutableCopy];
    images.block = row.rowActions[0];
    
//    // 定义一个数组 当是书包模式的时候放的是绘本的数组  当是单本书模式的时候 放的是一本书图片的数组
//    NSArray *list = @[];
//    if (kIsBookMode) {
//        list = ((ZHSBooks*)_schoolbag.books_list[0]).images;
//    }else{
//        list = _schoolbag.books_list;
//    }
    [_schoolbag.books_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHSBooks *BOOK = obj;
        [strAry addObject:BOOK.title];
        NSString *str;
        if (BOOK.images.count) {
            str = BOOK.images[0][@"small"];
        }
        [imageurls addObject:[NSString stringWithFormat:@"%@%@",kUrl,str]];

    }];
    if (kIsBookMode) {
        NSArray*list = ((ZHSBooks*)_schoolbag.books_list[0]).images;
        NSMutableArray *imagesurlAry = [@[] mutableCopy];
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *imageurl = obj[@"small"];
            [imagesurlAry addObject:[NSString stringWithFormat:@"%@%@",kUrl,imageurl]];
        }];
        imageurls = imagesurlAry;
    }
    UIScrollView *scroll = images.scrollView;
    UIView *view = (UIView*)images.subviews[0] ;
    if (view.subviews.count) {
        if (scroll.subviews.count/2 == strAry.count) {
            [scroll.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = obj;
                [imageView sd_setImageWithURL:[NSURL URLWithString:imageurls[(idx)/2]] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
            }
            if ([obj isKindOfClass:[UILabel class]]) {
                UILabel *lable = obj;
                lable.text = strAry[(idx-1)/2];
                }
        }];
        }else{
            [scroll removeFromSuperview];
            images.titles = strAry;
            [images Ary:imageurls];

        }
    }else{
        images.titles = strAry;
        [images Ary:imageurls];
    }


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
