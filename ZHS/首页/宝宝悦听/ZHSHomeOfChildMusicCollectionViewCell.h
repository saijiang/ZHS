//
//  ZHSHomeOfChildMusicCollectionViewCell.h
//  ZHS
//
//  Created by 邢小迪 on 16/1/2.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHSBooks;
@interface ZHSHomeOfChildMusicCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *playImage;

- (void)handleCellWithData:(ZHSBooks *)cellData;

@end
