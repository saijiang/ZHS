//
//  TNImageycleTableViewCell.m
//  Paopao
//
//  Created by 邢小迪 on 15/9/21.
//  Copyright © 2015年 telenav. All rights reserved.
//

#import "TNImageycleTableViewCell.h"
#import "TNImageScrollView.h"
#import "TNH5ViewController.h"
#import "ZHSHomeViewController.h"
#import "ZHSSchoolbag.h"
#import "UIImageView+WebCache.h"
@interface TNImageycleTableViewCell ()<MMTableCell>
{
    NSMutableArray*_rowInfo;
//    MMRow *_row;
}
@property (weak, nonatomic) IBOutlet UIView *diview;

@end
@implementation TNImageycleTableViewCell

- (void)awakeFromNib {
    // Initialization code
    TNImageScrollView *images = [[TNImageScrollView alloc] initWithFrame:CGRectMake(0, 0, kWidth, self.diview.frame.size.height)];
    images.with = kWidth;
    images.heights = 140;
    images.isCycel = YES;
    images.isContentModeOfFit = NO;
    [self.diview addSubview:images];
}
-(void)handleCellWithRow:(MMRow *)row
{
//    _row = row;
    if ([row.rowInfo isKindOfClass:[ZHSSchoolbag class]]) {
        return;
    }
    _rowInfo = row.rowInfo[@"data"];
    TNImageScrollView * images = (TNImageScrollView*)self.diview.subviews[0];
    __block NSMutableArray *aryImage = [@[] mutableCopy];
    [_rowInfo enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [aryImage addObject:obj[@"image_url"]];
//        obj[@"title"] = [NSString stringWithFormat:@"标题%ld",idx];
    }];
    ZHSHomeViewController *vc = row.rowInfo[@"VC"];
    if (!vc) {
        images.isContentModeOfFit = YES;

    }
    images.block = ^(NSInteger linkNumber){
        if (vc) {
        DLog(@"linkNumber ==========   %ld",(long)linkNumber);
        if ((NSDictionary*)_rowInfo[linkNumber-1][@"links"]) {
            DLog(@"linkString ==========   %@",(NSDictionary*)_rowInfo[linkNumber-1][@"links"]);
                TNH5ViewController *h5 = [TNH5ViewController new];
                h5.titleString =((NSDictionary*)_rowInfo[linkNumber-1])[@"title"];
                h5.urlString = ((NSDictionary*)_rowInfo[linkNumber-1])[@"links"];
                [vc.navigationController pushViewController:h5 animated:YES];
            }
        }
        
    };
    UIView *view = (UIView*)images.subviews[0] ;
    if (view.subviews.count) {
        UIScrollView *scroll = images.scrollView;
        [scroll.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( [obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = obj;
                if (idx == 0) {
                    [imageView sd_setImageWithURL:[NSURL URLWithString:aryImage.lastObject] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
                }else if (idx == scroll.subviews.count-1) {
                    [imageView sd_setImageWithURL:[NSURL URLWithString:aryImage.firstObject] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
                }else{
                    [imageView sd_setImageWithURL:[NSURL URLWithString:aryImage[idx-1]] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
                }
            }
        }];
        
    }else{
        [images Ary:aryImage];
    }

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
