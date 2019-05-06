//
//  TNSplashViewController.m
//  WeZone
//
//  Created by DengQiang on 14-7-2.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNSplashViewController.h"

@interface TNSplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *splashImageView;

@end

@implementation TNSplashViewController

- (void)configureView
{
    [super configureView];
    self.navigationBarHidden = NO;
    if (kWidth == 320) {
        if (kHight == 480) {
            self.splashImageView.image = [UIImage imageNamed:@"lanunch-1"];
        }else{
            self.splashImageView.image = [UIImage imageNamed:@"lanunch-2"];
        }
    }else if (kWidth == 375){
        self.splashImageView.image = [UIImage imageNamed:@"lanunch-3"];

    }else{
        self.splashImageView.image = [UIImage imageNamed:@"lanunch-4"];
    }
}

@end
