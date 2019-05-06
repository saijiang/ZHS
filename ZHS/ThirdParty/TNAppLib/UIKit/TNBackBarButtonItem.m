//
//  TNBackBarButtonItem.m
//  WeZone
//
//  Created by DengQiang on 14-7-31.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNBackBarButtonItem.h"

@interface TNBackBarButtonItem ()

@property (nonatomic, weak) UIViewController *vc;

@end

@implementation TNBackBarButtonItem

- (id)initWithViewController:(UIViewController *)viewController
{
    if (self = [super initWithImage:[UIImage imageNamed:@"Blue_03"] style:UIBarButtonItemStyleDone target:nil action:NULL]) {
        self.imageInsets = UIEdgeInsetsMake(0, -6, 0, 0);
        self.target = self;
        self.action = @selector(backButtonDidClick:);
        self.vc = viewController;
    }
    return self;
}

- (void)dealloc
{
    self.target = nil;
    self.action = NULL;
}

- (IBAction)backButtonDidClick:(id)sender {
    if (self.vc.navigationController.viewControllers.firstObject == self.vc || self.vc.navigationController == nil) {
        id shownSideViewController = [TNApplication sharedApplication].shownSideViewController;
        if (shownSideViewController != nil && (shownSideViewController == self.vc.navigationController || shownSideViewController == self.vc)) {
            [[TNApplication sharedApplication] hideSideViewController];
            return;
        }
        if (self.vc.presentingViewController) {
            UIWindow *window = self.vc.view.window;
            window.userInteractionEnabled = NO;
            [self.vc.presentingViewController dismissViewControllerAnimated:YES completion:^{
                window.userInteractionEnabled = YES;
            }];
        }
    } else {
        [self.vc.navigationController popViewControllerAnimated:YES];
    }
}

@end
