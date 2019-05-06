//
//  TNTableViewCell.h
//  WeZone
//
//  Created by kiri on 2013-10-29.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNTag.h"

@interface TNTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *highlightedImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UIImageView *disclosureView;

- (void)prepareWithTag:(TNRowTag *)tag;

- (BOOL)useGlobalBackground;

@end
