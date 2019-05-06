//
//  TNBlockImagePickerViewController.m
//  TNAppLib
//
//  Created by kiri on 2013-11-18.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNBlockImagePickerViewController.h"

@interface TNBlockImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation TNBlockImagePickerViewController

- (id)init
{
    if (self = [super init]) {
        self.delegate = self;
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    }
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.completion) {
        __weak typeof(self) weakSelf = self;
        self.completion(weakSelf, NO, info);
    } else {
        if (picker.presentingViewController) {
            UIViewController *vc = picker.presentingViewController;
            [picker dismissViewControllerAnimated:YES completion:^{
                if ([vc respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [vc setNeedsStatusBarAppearanceUpdate];
                }
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.completion) {
        __weak typeof(self) weakSelf = self;
        self.completion(weakSelf, YES, nil);
    } else {
        if (picker.presentingViewController) {
            UIViewController *vc = picker.presentingViewController;
            [picker dismissViewControllerAnimated:YES completion:^{
                if ([vc respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [vc setNeedsStatusBarAppearanceUpdate];
                }
            }];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{   
    NSString *classStr = NSStringFromClass([self class]);
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1 && [classStr isEqualToString:@"PLUICameraViewController"]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.topViewController && [NSStringFromClass(self.topViewController.class) hasPrefix:@"TN"]) {
        return self.topViewController.preferredStatusBarStyle;
    }
    
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    if (self.topViewController && [NSStringFromClass(self.topViewController.class) hasPrefix:@"TN"]) {
        return self.topViewController.prefersStatusBarHidden;
    }
    
    NSString *classStr = NSStringFromClass([self class]);
    if ([classStr isEqualToString:@"PLUICameraViewController"]) {
        return YES;
    }
    
    return NO;
}

@end