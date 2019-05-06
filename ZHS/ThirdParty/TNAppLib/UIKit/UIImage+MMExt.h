//
//  UIImageView+MMExt.h
//  ZHS
//
//  Created by 邢小迪 on 16/4/11.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MMExt)

+ (UIImage *) imageWithName:(NSString *) imageName;
+ (UIImage *) resizableImageWithName:(NSString *)imageName;
- (UIImage*) scaleImageWithSize:(CGSize)size;

@end
