//
//  TNBadgeView.h
//  WeZone
//
//  Created by Frank on 13-12-27.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNBadgeView : UIView

+ (TNBadgeView *)viewFromNib;

/*!
 * 更新Badge值，如果Badge值小于等于0，会直接将自己隐藏
 */
- (void)updateWithBadge:(NSInteger)badge;

@end
