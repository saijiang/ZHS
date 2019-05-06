
//  Created by kiri on 13-5-27.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNAlbumDetailTableViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TNAlbumFakeAsset.h"

@interface TNAlbumDetailTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *imageViewContainer;
@property (weak, nonatomic) IBOutlet UIView *overlayViewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageSelectMarkView0;
@property (weak, nonatomic) IBOutlet UIImageView *imageSelectMarkView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageSelectMarkView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageSelectMarkView3;

@property (strong,nonatomic) NSArray* markViews;

- (IBAction)imageViewDidTap:(id)sender;

@end

@implementation TNAlbumDetailTableViewCell

- (void)setImageSelected:(BOOL)isSelected atIndex:(NSUInteger)index
{
    if(self.markViews.count > 0 && index < self.markViews.count)
    {
        ((UIImageView*)self.markViews[index]).highlighted = isSelected;
    }
}

-(BOOL)isImageSelectedAtIndex:(NSUInteger)index
{
    if(index < self.markViews.count)
    {
        return ((UIImageView*)self.markViews[index]).highlighted;
    }
    return NO;
}

-(void)prepareWithTag:(TNRowTag *)tag
{
    self.markViews = @[self.imageSelectMarkView0, self.imageSelectMarkView1, self.imageSelectMarkView2, self.imageSelectMarkView3];
    
    for (int i = 1; i < 5; i++) {
        [self.imageViewContainer viewWithTag:i].hidden = YES;
        [self.overlayViewContainer viewWithTag:i].hidden = YES;
    }
    
    self.assets = tag.data;
    [self.assets enumerateObjectsUsingBlock:^(id asset, NSUInteger idx, BOOL *stop) {
        [self.overlayViewContainer viewWithTag:idx + 1].hidden = NO;
        UIImageView *imageView = (UIImageView *)[self.imageViewContainer viewWithTag:idx + 1];
        imageView.hidden = NO;
        if ([asset isKindOfClass:[TNAlbumFakeAsset class]]) {
            imageView.image = ((TNAlbumFakeAsset *)asset).thumbnail;
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            imageView.image = [UIImage imageWithCGImage:((ALAsset *)asset).thumbnail];
        }
        UITapGestureRecognizer* gestureRecoginizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidTap:)];
        [imageView addGestureRecognizer: gestureRecoginizer];
    }];
}

- (IBAction)imageViewDidTap:(id)sender {
    NSInteger index = ((UITapGestureRecognizer *)sender).view.tag - 1;
    
    if(index >= self.assets.count)
    {
        return ;
    }
    
    ALAsset* asset = self.assets[index];
    if([self isImageSelectedAtIndex:index])
    {
        [self setImageSelected:NO atIndex:index];
        if([self.delegate respondsToSelector:@selector(albumDetailTableViewCell:disTapImage:select:)])
        {
            [self.delegate albumDetailTableViewCell:self disTapImage:asset select:NO];
        }
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(albumDetailTableViewCell:checkSelectImageEnable:)])
        {
            if([self.delegate albumDetailTableViewCell:self checkSelectImageEnable:asset])
            {
                [self setImageSelected:YES atIndex:index];
                if([self.delegate respondsToSelector:@selector(albumDetailTableViewCell:disTapImage:select:)])
                {
                    [self.delegate albumDetailTableViewCell:self disTapImage:asset select:YES];
                }
            }
        }
        else
        {
            [self setImageSelected:YES atIndex:index];
        }
    }

}



@end