
//
//  Created by kiri on 13-5-28.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    TNAlbumFakeAssetTypeCamera
} TNAlbumFakeAssetType;

@interface TNAlbumFakeAsset : NSObject

@property (nonatomic, readonly) TNAlbumFakeAssetType type;
@property (nonatomic, readonly, strong) UIImage *thumbnail;

+ (id)assetWithType:(TNAlbumFakeAssetType)type thumbnail:(UIImage *)thumbnail;

@end
