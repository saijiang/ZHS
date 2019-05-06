//
//  ZHSTheFivePieceTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/11/18.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSTheFivePieceTableViewCell.h"
#import "UIImageView+WebCache.h"
@interface ZHSTheFivePieceTableViewCell ()<MMTableCell>
{
    NSArray *_actions;
}
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *images;

@end 
@implementation ZHSTheFivePieceTableViewCell

- (void)awakeFromNib {
    // Initialization code
    for (UIView *view in self.images) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
        tapGestureRecognizer.cancelsTouchesInView = NO;
        //将触摸事件添加到当前view
        [view addGestureRecognizer:tapGestureRecognizer];
    }
}
-(void)tapGestureRecognizer:(UITapGestureRecognizer*)tap{
    void(^block)() = _actions[tap.view.tag-1];
    if (block) {
        block();
    }
    
}
-(void)handleCellWithRow:(MMRow *)row{
    NSMutableArray *dataAry = row.rowInfo;
    _actions = row.rowActions;
    [dataAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dataDic = obj;
        [_images[[dataDic[@"position"] integerValue]-1] sd_setImageWithURL:[NSURL URLWithString:dataDic[@"image_url"]] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CAGradientLayer *)shadowAsInverseWithStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint
{
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    CGRect newGradientLayerFrame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height*(75/140));
    gradientLayer.frame = newGradientLayerFrame;
    
    //添加渐变的颜色组合
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[[[TNAppContext currentContext] getColor:@"#E6E5E5"] colorWithAlphaComponent:1]CGColor],
                            (id)[[UIColor whiteColor]CGColor],
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:1],
                               
                               nil];
    
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    return gradientLayer;
}
@end
