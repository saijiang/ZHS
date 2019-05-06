//
//  TNViewController.m
//  WeZone
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNViewController.h"
#import "TNNavigationController.h"
#import "TNLogger.h"
#import "UIDevice+TNAppLib.h"

typedef NS_ENUM(NSInteger, TNViewControllerState) {
    TNViewControllerStateNone = 0,
    TNViewControllerStateWillAppear,
    TNViewControllerStateDidAppear,
    TNViewControllerStateWillDisappear,
    TNViewControllerStateDidDisappear,
};

@interface TNViewController () <UITextFieldDelegate, UITextViewDelegate>
{
    NSTimeInterval _timeIntervalForLogger;

}

@property (nonatomic) BOOL firstAppeared;
@property (nonatomic) TNViewControllerState state;

@property (nonatomic, weak) UIImageView *navbarHairlineImageView;
@property (nonatomic, weak) UIImageView *globalBackgroundView;

@end

@implementation TNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.firstAppeared = YES;
    self.navigationBarHidden = NO;
    self.tabBarHidden = YES;
    self.navigationItem.backBarButtonItem = nil;
//    self.hidesBottomBarWhenPushed = YES;
//    self.navigationItem.hidesBackButton = YES;
    [self initView];
    [self initData];
    [self addTapGestureRecognizerToView];
    
    if (self.view) {
        [self configureView];
    }
    
    self.state = TNViewControllerStateNone;
    
    if (self.useGlobalBackground) {
        if (self.globalBackgroundView == nil) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"global_view_bg"]];
            imageView.frame = self.view.bounds;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.view insertSubview:imageView atIndex:0];
            self.globalBackgroundView = imageView;
        }
    }
}
-(void)addTapGestureRecognizerToView{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reclaimedKeyboard)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
- (void)reclaimedKeyboard
{
//    [self.mobileTextField resignFirstResponder];
//    [self.repeatPasswordTextField resignFirstResponder ];
    
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.state == TNViewControllerStateWillAppear || self.state == TNViewControllerStateDidAppear) {
        return;
    }
    self.state = TNViewControllerStateWillAppear;
    
    if (self.navigationController.navigationBarHidden != self.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:self.isNavigationBarHidden animated:animated];
    }
    if (self.tabBarController.tabBar.hidden != self.isTabBarHidden) {
        self.tabBarController.tabBar.hidden = self.isTabBarHidden;
    }
    
    if (self.navbarColor) {
        if ([UIDevice currentDevice].majorSystemVersion < 7) {
            self.navigationController.navigationBar.tintColor = self.navbarColor;
        } else {
            self.navigationController.navigationBar.barTintColor = self.navbarColor;
        }
    } else {
        if ([UIDevice currentDevice].majorSystemVersion < 7) {
            self.navigationController.navigationBar.tintColor = [UINavigationBar appearance].tintColor;
        }
    }
    
    if (self.navigationBarBottomLineHidden) {
        if ([UIDevice currentDevice].majorSystemVersion < 7) {
            
        } else {
            self.navbarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
            self.navbarHairlineImageView.hidden = YES;
        }
    }
    
    [[TNApplication sharedApplication] refreshStatusBar];
    [[TNLogger sharedLogger] logViewAppear:NSStringFromClass([self class])];
    _timeIntervalForLogger = [NSDate timeIntervalSinceReferenceDate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if (self.navigationController.viewControllers.count >1) {
//        self.tabBarHidden =YES;
//    }else {
//        self.tabBarHidden =NO;
//        self.tabBarController.tabBar.hidden = NO;
//    }
    if (self.state == TNViewControllerStateDidAppear) {
        return;
    }
    self.state = TNViewControllerStateDidAppear;
    
    if (self.observeKeyboardChangeFrameNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    if (self.firstAppeared) {
        self.firstAppeared = NO;
        [self viewDidFirstAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if (self.state == TNViewControllerStateNone || self.state == TNViewControllerStateDidDisappear || self.state == TNViewControllerStateWillDisappear) {
        return;
    }
    
    self.state = TNViewControllerStateWillDisappear;
    _timeIntervalForLogger = [NSDate timeIntervalSinceReferenceDate] - _timeIntervalForLogger;
    if (self.navbarColor) {
        if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
            self.navigationController.navigationBar.barTintColor = [UINavigationBar appearance].barTintColor;
        }
    }
    if (self.navigationBarBottomLineHidden) {
        if ([UIDevice currentDevice].majorSystemVersion < 7) {
            
        } else {
            self.navbarHairlineImageView.hidden = NO;
        }
    }
    
    [[TNLogger sharedLogger] logViewDisappear:NSStringFromClass([self class]) duration:_timeIntervalForLogger];

}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
    if (self.state == TNViewControllerStateNone || self.state == TNViewControllerStateDidDisappear) {
        return;
    }
    self.state = TNViewControllerStateDidDisappear;
}

- (IBAction)backButtonDidClick:(id)sender {
    if (self.navigationController.viewControllers.firstObject == self || self.navigationController == nil) {
        id shownSideViewController = [TNApplication sharedApplication].shownSideViewController;
        if (shownSideViewController != nil && (shownSideViewController == self.navigationController || shownSideViewController == self)) {
            [[TNApplication sharedApplication] hideSideViewController];
            return;
        }
        if (self.presentingViewController) {
            UIWindow *window = self.view.window;
            window.userInteractionEnabled = NO;
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                window.userInteractionEnabled = YES;
            }];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)homeButtonDidClick:(id)sender {
    if (self.presentingViewController) {
        UIWindow *window = self.view.window;
        window.userInteractionEnabled = NO;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            window.userInteractionEnabled = YES;
        }];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)leftSidebarButtonDidClick:(id)sender
{
    [[TNApplication sharedApplication] setLeftSidebarHidden:![TNApplication sharedApplication].isLeftSidebarHidden animated:YES];
}

- (IBAction)rightSidebarButtonDidClick:(id)sender
{
    [[TNApplication sharedApplication] setRightSidebarHidden:![TNApplication sharedApplication].isRightSidebarHidden animated:YES];
}

- (BOOL)isViewAppeared
{
    return self.state == TNViewControllerStateDidAppear;
}

- (void)configureView
{
}

- (void)viewDidFirstAppear:(BOOL)animated
{
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)showActionSheet:(TNActionSheet *)actionSheet
{
    [self.view endEditing:YES];
    if (self.view.window) {
        [actionSheet showInView:self.view.window];
    } else {
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

#pragma mark - UITextInputView
- (void)keyboardWillShow:(NSNotification *)notification
{
    
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGPoint pt = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    pt = [self.view.window convertPoint:pt toView:self.view];
    UIViewAnimationCurve curve = [notification.userInfo integerForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSTimeInterval duration = [notification.userInfo doubleForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration delay:0 options:curve << 16 animations:^{
    if (pt.y < 480) {
        self.view.height = self.view.height + pt.y;
        }else
        self.view.height =pt.y;
    } completion:nil];
}

- (UIScrollView *)scrollViewForTextInputView:(UIView *)textInputView
{
    return nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self textInputViewDidBeginEditing:textField];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self textInputViewDidBeginEditing:textView];
}

- (void)textInputViewDidBeginEditing:(UIView *)textInputView
{
    UIScrollView *scrollView = [self scrollViewForTextInputView:textInputView];
    if (scrollView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect rect = [scrollView convertRect:textInputView.frame fromView:textInputView.superview];
            CGFloat y = rect.origin.y;
            if (scrollView.height > rect.size.height) {
                y = y - (scrollView.height - rect.size.height) / 2;
            }
            y = MIN(y, scrollView.contentSize.height + scrollView.contentInset.bottom + scrollView.contentInset.top - scrollView.height);
            y = MAX(0, y);
            [scrollView setContentOffset:CGPointMake(0, y) animated:YES];
        });
    }
}

- (void)prepareForLeftSidebar
{
    self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"navbar_sidebar"];
    self.navigationItem.leftBarButtonItem.action = @selector(leftSidebarButtonDidClick:);
}

#pragma mark - Common Bg
- (BOOL)useGlobalBackground
{
    return NO;
}

//zfy-------
-(void)createLeftBarItemWithTitle:(NSString *)title{
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
}
-(void)createLeftBarItemWithImage{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];

    self.navigationItem.leftBarButtonItem = backButton;
}

-(void)createRightBarItemWithTitle:(NSString *)title font:(CGFloat)fontSize{
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(clickRightSender:)];
    [rightBarButton
     setTitleTextAttributes:[NSDictionary
                             dictionaryWithObjectsAndKeys:[UIFont
                                                           systemFontOfSize:fontSize], NSFontAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}
-(void)createRightBarItemWithTitle:(NSString *)title{
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(clickRightSender:)];

    self.navigationItem.rightBarButtonItem = rightBarButton;
}

-(void)createRightBarItemWithImage:(NSString *)imageName{
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:@selector(clickRightSender:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

-(void)clickRightSender:(UIButton *)sender{}
+ (UIImage *)drawImage:(CGSize)imageSize setColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return pressedColorImg;
}
-(void)initView{
    
}
-(void)initData{
    
}
@end
