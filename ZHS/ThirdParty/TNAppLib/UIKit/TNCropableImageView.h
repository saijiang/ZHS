//
//  TNCropableImageView.h
//  WeZone
//
//  Created by Mr.Wang(Wang Zhao) on 13-12-19.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNCropableImageView : UIView

@property (nonatomic,strong) UIImage* image;
@property (nonatomic) CGFloat minSideMaxWidth;

- (UIImage *)croppedImage;
- (UIImage*)cropImageInRect:(CGRect)rect;

@end
