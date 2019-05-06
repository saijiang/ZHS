//
//  ZHSTuiJianTableViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 15/12/2.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import "ZHSTuiJianTableViewCell.h"
@interface ZHSTuiJianTableViewCell ()<MMTableCell>
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UILabel *lable;

@end
@implementation ZHSTuiJianTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.leftView.layer addSublayer:[self shadowAsInverseWithStartPoint:CGPointMake(1, 0.5) andEndPoint:CGPointMake(0, 0.5) ]];
    [self.rightView.layer addSublayer:[self shadowAsInverseWithStartPoint:CGPointMake(0, 0.5) andEndPoint:CGPointMake(1, 0.5) ]];
    if (kIsBookMode) {
        _lable.text = @"推荐绘本";
    }
}
-(void)handleCellWithRow:(MMRow *)row{
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (CAGradientLayer *)shadowAsInverseWithStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint
{
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    CGRect newGradientLayerFrame = CGRectMake(0, 0, self.rightView.frame.size.width, self.rightView.frame.size.height);
    gradientLayer.frame = newGradientLayerFrame;
    
    //添加渐变的颜色组合
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[[[TNAppContext currentContext] getColor:@"#67c738"] colorWithAlphaComponent:1]CGColor],
                            (id)[[[TNAppContext currentContext] getColor:@"#EBEBEB"]CGColor],
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:1],

                               nil];
    
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    return gradientLayer;
}
@end
