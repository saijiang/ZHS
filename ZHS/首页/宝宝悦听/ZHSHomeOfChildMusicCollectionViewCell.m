//
//  ZHSHomeOfChildMusicCollectionViewCell.m
//  ZHS
//
//  Created by 邢小迪 on 16/1/2.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "ZHSHomeOfChildMusicCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "ZHSBooks.h"

@interface ZHSHomeOfChildMusicCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (weak, nonatomic) IBOutlet UILabel *title;
@end
@implementation ZHSHomeOfChildMusicCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)handleCellWithData:(ZHSBooks *)cellData
{
    if (cellData)
    {

            self.title.text = cellData.title;
            NSString *url = cellData.images[0][@"small"];
            [_image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kUrl,url] ]  placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
    }
}


@end
