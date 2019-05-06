
//  Created by kiri on 13-5-28.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNAlbumFakeAsset.h"

@interface TNAlbumFakeAsset ()

@property (nonatomic) TNAlbumFakeAssetType type;
@property (nonatomic, strong) UIImage *thumbnail;

@end

@implementation TNAlbumFakeAsset

+ (id)assetWithType:(TNAlbumFakeAssetType)type thumbnail:(UIImage *)thumbnail
{
    TNAlbumFakeAsset *asset = [[TNAlbumFakeAsset alloc] init];
    asset.type = type;
    asset.thumbnail = thumbnail;
    return asset;
}

- (void)dealloc
{
    self.thumbnail = nil;

}

@end
