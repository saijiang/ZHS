//
//  TNFlowUtil.m
//  Tuhu
//
//  Created by DengQiang on 14/10/23.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import "TNFlowUtil.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TNRequestManager.h"
#import "TNAppContext.h"
#import "ZHSLoginViewController.h"
#import "TNMainTabBarControllerDelegate.h"
//#import "TNLocationManager.h"
#import "TNLoadViewController.h"
#import "AppDelegate.h"
#import "ZHSMoreViewController.h"
#import"ZHSMyCenterViewController.h"
#import "ZHSSchoolbagViewController.h"
#import "ZHSMyCenterViewController.h"
#import "ZHSSchoolbagViewController.h"
#import "TNTabBarController.h"
#import "ZHSInterestCultivationViewController.h"
#define kUserDefaultGuideViewMaxCountTokenPrefix @"kUserDefaultGuideViewMaxCountToken"

@interface TNGuideTapGestureRecognizer : UITapGestureRecognizer

@end

@implementation TNGuideTapGestureRecognizer

- (id)init
{
    return [self initWithTarget:self action:@selector(didTap:)];
}

- (void)didTap:(UIGestureRecognizer *)gr
{
    if (gr.view.superview) {
        [TNViewUtil animateWithAnimations:^{
            gr.view.alpha = 0;
        } completion:^(BOOL finished) {
            [gr.view removeFromSuperview];
        }];
    }
}
@end

@implementation TNFlowUtil

+ (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rootViewController
{
    TNNavigationController *nav = [[TNNavigationController alloc] initWithNavigationBarClass:[TNNavigationBar class] toolbarClass:NULL];
    [nav setViewControllers:@[rootViewController]];
    return nav;
}

+ (UIViewController *)visibleViewController
{
    UIViewController *root = [[UIApplication sharedApplication].delegate window].rootViewController;
    if (root) {
        if (root.presentedViewController) {
            return root.presentedViewController;
        }
        
        root = [TNApplication sharedApplication].rootViewController;
        if ([root isKindOfClass:[UINavigationController class]]) {
            return [(UINavigationController *)root visibleViewController];
        } else if ([root isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = (UITabBarController *)root;
            return [tabBarController.selectedViewController isKindOfClass:[UINavigationController class]] ? [(UINavigationController *)tabBarController.selectedViewController visibleViewController] : tabBarController.selectedViewController;
        } else {
            return root;
        }
    }
    return nil;
}

+ (void)startFlowWithStoryboardName:(NSString *)storyboardName navigationController:(UINavigationController *)navigationController animated:(BOOL)animated
{
    return [self startFlowWithStoryboardName:storyboardName identifier:nil preparation:nil navigationController:navigationController animated:animated];
}

+ (void)startFlowWithStoryboardName:(NSString *)storyboardName identifier:(NSString *)identifier preparation:(void (^)(id))preparation
               navigationController:(UINavigationController *)navigationController animated:(BOOL)animated
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    TNViewController *vc = identifier ? [storyboard instantiateViewControllerWithIdentifier:identifier] : [storyboard instantiateInitialViewController];
    if (preparation) {
        preparation(vc);
    }
    [navigationController pushViewController:vc animated:animated];
}

+ (void)presentFlowWithStoryboardName:(NSString *)storyboardName presentingViewController:(UIViewController *)presentingViewController nestInNavigationController:(BOOL)isNestInNavigationController animated:(BOOL)animated completion:(void (^)(void))completion
{
    return [self presentFlowWithStoryboardName:storyboardName identifier:nil preparation:nil presentingViewController:presentingViewController nestInNavigationController:isNestInNavigationController animated:animated completion:completion];
}

+ (void)presentFlowWithStoryboardName:(NSString *)storyboardName identifier:(NSString *)identifier preparation:(void (^)(id destinationViewController))preparation
             presentingViewController:(UIViewController *)presentingViewController nestInNavigationController:(BOOL)isNestInNavigationController animated:(BOOL)animated completion:(void (^)(void))completion
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    TNViewController *vc = identifier ? [storyboard instantiateViewControllerWithIdentifier:identifier] : [storyboard instantiateInitialViewController];
    if (preparation) {
        preparation(vc);
    }
    
    [presentingViewController presentViewController:isNestInNavigationController ? [self navigationControllerWithRootViewController:vc] : vc animated:animated completion:completion];
}

+ (BOOL)startPhotoPickerWithPresentingViewController:(UIViewController *)presentingViewController defaultToFrontCamera:(BOOL)defaultToFrontCamera animated:(BOOL)animated completion:(void (^)(UIImagePickerController *, BOOL, UIImage *))completion
{
    void (^wrapper)(UIImagePickerController *picker, BOOL isCancel, NSDictionary *mediaInfo) = completion != nil ? ^(UIImagePickerController *picker, BOOL isCancel, NSDictionary *mediaInfo){
        if (isCancel) {
            completion(picker, isCancel, nil);
        } else {
            UIImage *image = [mediaInfo objectForKey:UIImagePickerControllerEditedImage];
//              UIImage *image = [mediaInfo objectForKey:UIImagePickerControllerOriginalImage];
            if (!image) {
                image = [mediaInfo objectForKey:UIImagePickerControllerOriginalImage];
            }
            completion(picker, isCancel, image);
        }
    } : nil;
    
    return [self startPhotoPickerWithPresentingViewController:presentingViewController defaultToFrontCamera:defaultToFrontCamera animated:animated completionWithMediaInfo:wrapper];
}

+ (BOOL)startPhotoPickerWithPresentingViewController:(UIViewController *)presentingViewController defaultToFrontCamera:(BOOL)defaultToFrontCamera animated:(BOOL)animated completionWithMediaInfo:(void (^)(UIImagePickerController *, BOOL, NSDictionary *))completion
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO || !completion) {
        return NO;
    }
    
    TNBlockImagePickerViewController *vc = [TNBlockImagePickerViewController new];
    vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    vc.mediaTypes = [NSArray arrayWithObjects:(__bridge NSString *)kUTTypeImage, nil];
//    vc.allowsEditing = YES;
    vc.showsCameraControls = YES;
    vc.cameraDevice = defaultToFrontCamera ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
    vc.completion = completion;
    
    [presentingViewController presentViewController:vc animated:animated completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }];
    return YES;
}

+ (BOOL)startAlbumPickerWithPresentingViewController:(UIViewController *)presentingViewController animated:(BOOL)animated completion:(void (^)(UIImagePickerController *, BOOL, UIImage *))completion
{
    return [self startAlbumPickerWithPresentingViewController:presentingViewController dismissingViewController:presentingViewController animated:animated completion:completion];
}

+ (BOOL)startAlbumPickerWithPresentingViewController:(UIViewController *)presentingViewController dismissingViewController:(UIViewController *)dismissingViewController animated:(BOOL)animated completion:(void (^)(UIImagePickerController *, BOOL, UIImage *))completion
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO || !completion) {
        return NO;
    }
    
    TNBlockImagePickerViewController *vc = [TNBlockImagePickerViewController new];
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.mediaTypes = [NSArray arrayWithObjects:(__bridge NSString *)kUTTypeImage, nil];
    vc.allowsEditing = NO;
    vc.completion = completion != nil ? ^(TNBlockImagePickerViewController *picker, BOOL isCancel, NSDictionary *mediaInfo) {
        if (isCancel) {
            completion(picker, isCancel, nil);
        } else {
            completion(picker, isCancel, [mediaInfo objectForKey:UIImagePickerControllerOriginalImage]);
        }
    } : nil;
    
    [presentingViewController presentViewController:vc animated:animated completion:nil];
    return YES;
}

+ (void)showGuideWithView:(UIView *)guideView token:(NSString *)token
{
    [self showGuideWithView:guideView maxCount:1 token:token tapToHide:YES];
}

+ (void)showGuideWithView:(UIView *)guideView maxCount:(int)maxCount token:(NSString *)token tapToHide:(BOOL)tapToHide
{
    if (token) {
        NSString *key = [kUserDefaultGuideViewMaxCountTokenPrefix stringByAppendingString:token];
        NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:key];
        if (count >= maxCount) {
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:count + 1 forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (guideView.superview == nil) {
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        guideView.alpha = 0.f;
        guideView.frame = window.bounds;
        [window addSubview:guideView];
    }
    guideView.hidden = NO;
    if (tapToHide) {
        guideView.userInteractionEnabled = YES;
        BOOL hasGestureRecognizer = NO;
        if (guideView.gestureRecognizers.count > 0) {
            for (UIGestureRecognizer *gr in guideView.gestureRecognizers) {
                if ([gr isKindOfClass:[TNGuideTapGestureRecognizer class]]) {
                    hasGestureRecognizer = YES;
                    break;
                }
            }
        }
        if (!hasGestureRecognizer) {
            [guideView addGestureRecognizer:[TNGuideTapGestureRecognizer new]];
        }
    }
    [TNViewUtil animateWithAnimations:^{
        guideView.alpha = 1.f;
    }];
}

#pragma mark - WebView
+ (void)startWebViewFromSidebarWithURL:(NSURL *)url title:(NSString *)title position:(TNSideViewPosition)position
{
    TNWebViewController *vc = [TNNibUtil loadMainObjectFromNib:@"TNWebViewController"];
    [vc prepareWithURL:url title:title backType:TNWebViewBackTypeBack];
    [[TNApplication sharedApplication] showSideViewController:vc fromPosition:position];
}

+ (void)startWebViewWithURL:(NSURL *)url title:(NSString *)title backType:(TNWebViewBackType)backType navigationController:(UINavigationController *)navigationController animated:(BOOL)animated
{
    TNWebViewController *vc = [TNNibUtil loadMainObjectFromNib:@"TNWebViewController"];
    [vc prepareWithURL:url title:title backType:backType];
    [navigationController pushViewController:vc animated:animated];
}

+ (void)presentWebViewWithURL:(NSURL *)url title:(NSString *)title presentingViewController:(UIViewController *)presentingViewController animated:(BOOL)animated
{
    TNWebViewController *vc = [TNNibUtil loadMainObjectFromNib:@"TNWebViewController"];
    [vc prepareWithURL:url title:title backType:TNWebViewBackTypeBack];
    [presentingViewController presentViewController:[self navigationControllerWithRootViewController:vc] animated:animated completion:nil];
}

#pragma mark - Load Resources

+ (void)startBackdoor
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (vc.presentedViewController) {
        [vc dismissViewControllerAnimated:YES completion:^{
            [vc presentViewController:[UIStoryboard storyboardWithName:@"TNBackdoor" bundle:nil].instantiateInitialViewController animated:YES completion:nil];
        }];
    } else {
        [vc presentViewController:[UIStoryboard storyboardWithName:@"TNBackdoor" bundle:nil].instantiateInitialViewController animated:YES completion:nil];
    }
}

+ (void)handleSplashDidLoad
{
//    void (^blockedNetworkErrorHandler)(void) = ^{
//        TNBlockAlertView *alert = [[TNBlockAlertView alloc] initWithTitle:TNLStr(@"network_error_alert_title") message:TNLStr(@"network_error") delegate:nil cancelButtonTitle:TNLStr(@"quit") otherButtonTitles:TNLStr(@"network_error_alert_retry_button"), nil];
//#if DEBUG
//        [alert addButtonWithTitle:@"～番外篇～"];
//        [alert setBlock:^{
//            [self startBackdoor];
//        } atButtonIndex:2];
//#endif
//        [alert setBlockForOk:^{
//            [self handleSplashDidLoad];
//        }];
//        [alert setBlockForCancel:^{
//            exit(0);
//        }];
//        [alert show];
//    };
   
    TNRequestManager *requestManager = [TNRequestManager defaultManager];
    // init server list
    requestManager.serviceURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",kHeaderURL]];
    requestManager.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",kHeaderURL]];
//    requestManager.serviceURL = [NSURL URLWithString:@"http://api.tuhu.cn"];
//    requestManager.imageURL = [NSURL URLWithString:@"http://api.tuhu.cn"];
    requestManager.websiteURL = [NSURL URLWithString:@"http://www.wudiniao.com"];
//#warning 进入首页还是车型选择页面
//如果无用户数据 则跳转至车型选择页面
//    if ([TNAppContext currentContext].car == nil) {
//        [[TNApplication sharedApplication] setRootViewController:[self navigationControllerWithRootViewController:[TNNibUtil loadMainObjectFromNib:@"TNFirstSelectCarViewController"]] animated:YES];
//    } else {
//    跳转至主页面
//        [self startMainFlow];
//    }
    //    跳转至引导页面还是首页
        AppDelegate* appDelegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
        if (appDelegate.isCurrentVersion)
        {
    TNLoadViewController* loadVC=[TNNibUtil loadMainObjectFromNib:@"TNLoadViewController"];
    [[TNApplication sharedApplication] setRootViewController:loadVC animated:YES];
        }
        else
        {
            if (![TNAppContext currentContext].user.token) {
                
                [self handleMainFlowWillLoadWithCompletion:^{
                    TNApplication *app = [TNApplication sharedApplication];
                    UITabBarController *tabVc = [TNTabBarController new];
                    
                    UIViewController *tab1 = [self navigationControllerWithRootViewController:[ZHSLoginViewController new]];
                    tabVc.viewControllers = @[tab1];
                    tabVc.delegate = [TNMainTabBarControllerDelegate sharedInstance];
                    [app setRootViewController:tabVc animated:YES];
                }];
            }else{

                [self startMainFlow];
            }
            //                ZHSLoginViewController*vc = [ZHSLoginViewController new];
//                [[TNApplication sharedApplication] setRootViewController:vc animated:YES];


        }

}

+ (void)handleMainFlowDidLoad
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *launchOptions = [TNApplication sharedApplication].launchOptions;
        if (launchOptions) {
//            NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//            if (remoteNotif.count > 0) {
//                [[TNMessageManager defaultManager] handleRemoteNotification:remoteNotif appActive:NO];
//            }
//            
//            UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
//            if (localNotif) {
//                [[TNMessageManager defaultManager] handleLocalNotification:localNotif appActive:NO];
//            }
        }
        /*
        [[TNLocationManager defaultManager] locateOnceWithAccuracy:kCLLocationAccuracyBest completion:nil];
         */
    });
}

+ (void)handleMainFlowWillLoadWithCompletion:(void (^)(void))completion
{
    __block NSInteger count = 0;
    BasicBlock action = ^{
        if (count == 0) {
            count--;    // prevent executing duplicately.
            
            // TODO: init
            
            if (completion) {
                completion();
            }
        }
    };
    
    action();
}

#pragma mark - Flow
//闪图
+ (void)startApplicationEntry
{
//      [self startMainFlow];
    [[TNApplication sharedApplication] setRootViewController:[[NSBundle mainBundle] loadNibNamed:@"TNSplashViewController" owner:nil options:nil][0] animated:NO];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self handleSplashDidLoad];
//    });
}

//显示首页
+ (void)startMainFlow
{
    [self handleMainFlowWillLoadWithCompletion:^{
        TNApplication *app = [TNApplication sharedApplication];
        TNTabBarController *tabVc = [TNTabBarController new];

//        [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
//        [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
        UIViewController *tab1 = [self navigationControllerWithRootViewController:[ZHSHomeViewController new]] ;
        tab1.tabBarItem.title = @"首页";
        tab1.tabBarItem.image = [[UIImage imageNamed:@"home_nol"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tab1.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        
        UIViewController *tab2 = [self navigationControllerWithRootViewController:[ZHSSchoolbagViewController new]];
        tab2.tabBarItem.title = @"绘本馆";
        tab2.tabBarItem.image = [[UIImage imageNamed:@"tree_nol"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tab2.tabBarItem.selectedImage = [[UIImage imageNamed:@"tree_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        UIViewController *tab5 = [self navigationControllerWithRootViewController:[ZHSMyCenterViewController new]];
        tab5.tabBarItem.title  = @"";
        tab5.tabBarItem.image = [[UIImage imageNamed:@"fabu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tab5.tabBarItem.selectedImage = [[UIImage imageNamed:@"fabu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tab5.tabBarItem.imageInsets = UIEdgeInsetsMake(0, -5.5, -11, -5.5);

        UIViewController *tab4 = [self navigationControllerWithRootViewController:[ZHSInterestCultivationViewController new]];
        tab4.tabBarItem.title = @"兴趣培养";
        tab4.tabBarItem.image =  [[UIImage imageNamed:@"Interest_nol"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tab4.tabBarItem.selectedImage =  [[UIImage  imageNamed:@"Interest_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIViewController *tab3 = [self navigationControllerWithRootViewController:[ZHSMyCenterViewController new]];
        tab3.tabBarItem.title = @"我的";
        tab3.tabBarItem.image = [[UIImage imageNamed:@"mysife_nol"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tab3.tabBarItem.selectedImage = [[UIImage imageNamed:@"mysife_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        


        
        tabVc.tabBar.tintColor =kNaverColr;
        tabVc.viewControllers = @[tab1, tab2, tab4, tab3];
       
        tabVc.delegate = [TNMainTabBarControllerDelegate sharedInstance];
        [app setRootViewController:tabVc animated:YES];
        
        
        //小红点(我的)
//        UIImageView *dotImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xiaohongdian"]];
//        dotImage.tag = 123456;
//        CGRect tabFrame = tabVc.tabBar.frame;
//        CGFloat x = ceilf(0.908 * tabFrame.size.width);
//        CGFloat y = ceilf(0.10 * tabFrame.size.height);
//        dotImage.frame = CGRectMake(x, y, 9, 9);
//        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isSeeHD"]) {
//            dotImage.hidden = NO;
//        }else{
//            dotImage.hidden = YES;
//        }
//        [tabVc.tabBar addSubview:dotImage];
        
        
        //小红点(发现)
//        UIImageView *dotImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fabu"]];
//        dotImage1.tag = 12345678;
//        CGRect tabFrame1 = tabVc.tabBar.frame;
//        CGFloat x1 = ceilf(0.908 * tabFrame1.size.width)/2;
//        CGFloat y1 = ceilf(0.10 * tabFrame1.size.height);
//        dotImage1.frame = CGRectMake(x1, y1, 70, 70);
//        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"isDiscover"]) {
//            dotImage1.hidden = NO;
//        }else{
//            dotImage1.hidden = YES;
//        }
//        [tabVc.tabBar addSubview:dotImage1];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          
            [self handleMainFlowDidLoad];
        });
    }];

}

+ (UITabBarController *)mainTabBarController
{
    UITabBarController *tab = (UITabBarController *)[TNApplication sharedApplication].rootViewController;
    if ([tab isKindOfClass:[UITabBarController class]]) {
        return tab;
    }
    return nil;
}

+ (ZHSSchoolbagViewController *)startGoSchoolbag
{
    [[self mainTabBarController] setSelectedIndex:1];
    return [(UINavigationController *)[[self mainTabBarController] selectedViewController] viewControllers].firstObject;
}
+ (ZHSHomeViewController *)startGoHome{
    [[self mainTabBarController] setSelectedIndex:0];
    return [(UINavigationController *)[[self mainTabBarController] selectedViewController] viewControllers].firstObject;}
+ (ZHSMyCenterViewController *)startPersonCenter
{
    
//        [NSThread sleepForTimeInterval:2.0f];
    [[self mainTabBarController] setSelectedIndex:2];
    return [(UINavigationController *)[[self mainTabBarController] selectedViewController] viewControllers].firstObject;
}

#pragma mark - Alert

+ (void)showNetworkErrorWithResponse:(TNResponse *)response
{
    if (response.isSuccess) {
        return;
    }
    
    [TNToast showNetworkError];
}

+ (void)showNetworkErrorWithResponse:(TNResponse *)response retryBlock:(void (^)(void))retryBlock
{
    [self showNetworkErrorWithResponse:response retryBlock:retryBlock cancelBlock:nil];
}

+ (void)showNetworkErrorWithResponse:(TNResponse *)response retryBlock:(void (^)(void))retryBlock cancelBlock:(void (^)(void))cancelBlock
{
    if (response.isSuccess) {
        return;
    }
    if (response) {
        [TNToast showNetworkError];
    } else {
        [self showNetworkErrorAlertWithRetryBlock:retryBlock cancelBlock:cancelBlock];
    }
}

+ (void)showNetworkErrorAlertWithRetryBlock:(void (^)(void))retryBlock cancelBlock:(void (^)(void))cancelBlock
{
    NSString *message = TNLStr(@"network_error_alert_retry_message");
    TNBlockAlertView *alert = [[TNBlockAlertView alloc] initWithTitle:TNLStr(@"network_error_alert_title") message:message delegate:nil cancelButtonTitle:TNLStr(@"cancel") otherButtonTitles:TNLStr(@"network_error_alert_retry_button"), nil];
    [alert setBlockForOk:retryBlock];
    [alert setBlockForCancel:cancelBlock];
    [alert show];
}


#pragma mark - Login
+ (void)presentLoginWithCompletion:(void (^)(UIViewController *))completion presentingViewController:(UIViewController *)presentingViewController animated:(BOOL)animated
{
//    void (^wrapper)(UIViewController *) = ^(UIViewController *controller){
//        UITabBarController *tabVc = [self mainTabBarController];
//        if (tabVc.viewControllers.count > 1) {
//            UINavigationController *nav = tabVc.viewControllers[1];
//            PPPersonViewController *person = nav.viewControllers.firstObject;
//            if ([person isKindOfClass:[PPPersonViewController class]]) {
//            }
//        }
//        if (completion) {
//            completion(controller);
//        }
//    };
    ZHSLoginViewController *vc = [[ZHSLoginViewController alloc] init];
    if (completion) {
//        [vc prepareWithCompletion:wrapper];
    } else {
//        [vc prepareWithCompletion:completion];
    }
    [presentingViewController presentViewController:[self navigationControllerWithRootViewController:vc] animated:animated completion:nil];
}




#pragma mark - Settings
+ (void)startAboutWithNavigationController:(UINavigationController *)nav animated:(BOOL)animated
{
    [nav pushViewController:[TNNibUtil loadMainObjectFromNib:@"TNAboutViewController"] animated:animated];
}






+ (void)startShopListWithNavigationController:(UINavigationController *)nav animated:(BOOL)animated
{
    [nav pushViewController:[TNNibUtil loadMainObjectFromNib:@"TNShopListViewController"] animated:animated];
}








@end
