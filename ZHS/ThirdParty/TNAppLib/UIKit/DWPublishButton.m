//
//  DWPublishButton.m
//  DWCustomTabBarDemo
//
//  Created by Damon on 10/20/15.
//  Copyright © 2015 damonwong. All rights reserved.
//

#import "DWPublishButton.h"
#import "TNRootViewController.h"
#import "ZHSCopySinaViewController.h"
#import "TNUser.h"
#import "ZHSFindYourTeacherViewController.h"
#import "ZHSMyCenterOfPrepaidViewController.h"
#import "ZHSHomeViewController.h"

@interface DWPublishButton ()

@end

@implementation DWPublishButton


#pragma mark -
#pragma mark - Private Methods

//上下结构的 button
- (void)layoutSubviews
{
    [super layoutSubviews];
    // 控件大小,间距大小
    CGFloat const imageViewEdge   = self.bounds.size.width * 0.8;
    CGFloat const centerOfView    = self.bounds.size.width * 0.5;
    CGFloat const labelLineHeight = self.titleLabel.font.lineHeight;
    CGFloat const verticalMarginT = self.bounds.size.height - labelLineHeight - imageViewEdge;
    CGFloat const verticalMargin  = verticalMarginT / 2;
    
    // imageView 和 titleLabel 中心的 Y 值
    CGFloat const centerOfImageView  = verticalMargin + imageViewEdge * 0.5;
    CGFloat const centerOfTitleLabel = imageViewEdge  + verticalMargin * 2 + labelLineHeight * 0.5 + 5;
    //imageView position 位置
    
    self.imageView.bounds = CGRectMake(0, 0, imageViewEdge, imageViewEdge);
    self.imageView.center = CGPointMake(centerOfView, centerOfImageView);
    
    //title position 位置
    
    self.titleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, labelLineHeight);
    self.titleLabel.center = CGPointMake(centerOfView, centerOfTitleLabel);
    
}

#pragma mark -
#pragma mark - Life Cycle

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
    }
    
    return self;
}

#pragma mark -
#pragma mark - Public Methods

+(instancetype)publishButton{
    
    DWPublishButton *button = [[DWPublishButton alloc]init];
    
    [button setImage:[UIImage imageNamed:@"sina_fabu"] forState:UIControlStateNormal];
    [button setTitle:@"" forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:9.5];
    if (kDevice_Is_iPhoneX) {
        button.frame = CGRectMake(0, 0, 72, 72);
    }
    else
    [button sizeToFit];
    
    [button addTarget:button action:@selector(clickPublish) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
    
}


#pragma mark -
#pragma mark - Event Response

- (void)clickPublish {
    UITabBarController *tabBarController = (UITabBarController*)((TNRootViewController *)self.window.rootViewController).rootViewController;
    UIViewController *viewController = ((UINavigationController*)tabBarController.selectedViewController).visibleViewController;
    TNUser *user = [TNAppContext currentContext].user;
    if (!([user.school_info[@"name"] length] && [user.school_class_info[@"name"] length])) {
        TNBlockAlertView *blockAlert = [[TNBlockAlertView alloc]initWithTitle:nil
                                                                      message:@"您还没有加入班级，请先加去班级"
                                                                     delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//        [blockAlert setBlockForOk:^{
//            ZHSFindYourTeacherViewController*vc = [ZHSFindYourTeacherViewController new];
//            vc.isCanBack = YES;
//            [viewController.navigationController pushViewController:vc animated:YES];
//        }];
        [blockAlert setBlockForCancel:^{
            ZHSFindYourTeacherViewController*vc = [ZHSFindYourTeacherViewController new];
            vc.isCanBack = YES;
            [viewController.navigationController pushViewController:vc animated:YES];
            
            UINavigationController *navVC = tabBarController.viewControllers[0];
            ZHSHomeViewController*homeVC = navVC.viewControllers[0];
            if ([homeVC.view.subviews containsObject:homeVC.zhishiView]) {
                [homeVC.zhishiView removeFromSuperview];
            }
        }];
        [blockAlert show];
    }else{
        UINavigationController *navVC = tabBarController.viewControllers[0];
        ZHSHomeViewController*homeVC = navVC.viewControllers[0];
        if ([homeVC.view.subviews containsObject:homeVC.zhishiView]) {
            [homeVC.zhishiView removeFromSuperview];
        }
        if (![user.payment_status isEqualToString:@"paid"]) {
            [viewController.navigationController pushViewController:[ZHSMyCenterOfPrepaidViewController new] animated:YES];
        }else{
            [viewController presentViewController:[ZHSCopySinaViewController new] animated:YES completion:nil];

        }
    }
}

#pragma mark - UIActionSheetDelegate

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    NSLog(@"buttonIndex = %ld", buttonIndex);
//}





@end
