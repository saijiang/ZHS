
//  Created by kiri on 13-5-27.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNAlbumFolderTableViewCell.h"
#import "UIView+TNAppLib.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TNNibUtil.h"
#import "TNViewUtil.h"

#define kNameNumberInsetWidth 8.f
#define kMaxLabelWidth  220.f

@interface TNAlbumFolderTableViewCell ()

@property (retain, nonatomic) IBOutlet UIImageView *posterImageView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation TNAlbumFolderTableViewCell

+ (id)cellFromNib:(NSString *)nibName withTableView:(UITableView *)tableView
{
    if (nibName.length == 0) {
        nibName = NSStringFromClass(self);
    }
    id cell = [tableView dequeueReusableCellWithIdentifier:nibName];
    if (cell == nil) {
        cell = [TNNibUtil loadObjectWithClass:self fromNib:nibName];
    }
    return cell;
}


-(void)prepareWithTag:(TNRowTag *)tag
{
    ALAssetsGroup *group = tag.data;
    self.posterImageView.image = [UIImage imageWithCGImage:group.posterImage];
    self.numberLabel.text = [NSString stringWithFormat:@"(%@)", @(group.numberOfAssets)];
    self.nameLabel.size = [TNViewUtil sizeWithLabel:self.nameLabel maxWidth:kMaxLabelWidth];
    self.numberLabel.left = self.nameLabel.right + kNameNumberInsetWidth;
    self.numberLabel.size = [TNViewUtil sizeWithLabel:self.numberLabel maxWidth:kMaxLabelWidth - kNameNumberInsetWidth - self.nameLabel.width];
}

@end
