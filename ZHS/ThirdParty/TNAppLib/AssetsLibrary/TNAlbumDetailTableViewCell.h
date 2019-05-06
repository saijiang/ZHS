
//  Created by kiri on 13-5-27.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNTableViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@class TNAlbumDetailTableViewCell;
@protocol TNAlbumDetailTableViewCellDelegate <NSObject>

- (BOOL)albumDetailTableViewCell:(TNAlbumDetailTableViewCell *)cell checkSelectImageEnable:(ALAsset*)asset;
- (void)albumDetailTableViewCell:(TNAlbumDetailTableViewCell *)cell disTapImage:(ALAsset*)asset select:(BOOL)selected;
@end

@interface TNAlbumDetailTableViewCell : TNTableViewCell

@property (nonatomic, weak) id<TNAlbumDetailTableViewCellDelegate> delegate;

@property(nonatomic, strong) NSArray* assets;

- (void)setImageSelected:(BOOL)isSelected atIndex:(NSUInteger)index;

@end
