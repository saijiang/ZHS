//
//  TNLoadMoreCell.m
//  WeZone
//
//  Created by kiri on 2013-10-31.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNLoadMoreCell.h"

@interface TNLoadMoreCell ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation TNLoadMoreCell

- (void)prepareWithTag:(TNRowTag *)tag
{
    [self.activityIndicator startAnimating];
}

@end
