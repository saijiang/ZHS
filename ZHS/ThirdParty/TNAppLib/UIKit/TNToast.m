//
//  TNToast.m
//  WeZone
//
//  Created by kiri on 2013-11-20.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNToast.h"
#import "SDWebImageManager.h"
#import "UIView+TNAppLib.h"
#import "TNAppLibMacros.h"
#import "TNNibUtil.h"
#import "UIDevice+TNAppLib.h"
#import "TNApplication.h"

typedef NS_ENUM(NSInteger, TNToastType) {
    TNToastTypeText = 1,
    TNToastTypeLoading,
};

#define kContentViewAutoresizeMask (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin)

@interface TNToast ()
{
    BOOL showing;
    BOOL hiding;
}

@property (nonatomic, strong) UIView *view;

@property (nonatomic) TNToastType type;
@property (nonatomic, copy) void (^preparationForShowing)(TNToast *toast);
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, weak) UIActivityIndicatorView *loadingIndicatorView;
@property (nonatomic) BOOL adjustUserInteractionDisabledImage;

@end

@implementation TNToast

- (id)init
{
    if (self = [super init]) {
        showing = NO;
        hiding = NO;
        self.adjustUserInteractionDisabledImage = YES;
        self.duration = 0.0;
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (UIViewAutoresizing)contentViewAutoresizingMask
{
    return kContentViewAutoresizeMask;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)show
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self show];
        });
        return;
    }
    
    if (showing) {
        return;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.view.frame = window.bounds;
    if ([TNApplication sharedApplication].keyboardTop > 0) {
        self.view.height = [TNApplication sharedApplication].keyboardTop;
    }
    
    showing = YES;
    if (self.view.superview) {
        if ([self.view.superview.subviews lastObject] != self.view) {
            self.view.alpha = 0.f;
            
            if (self.preparationForShowing) {
                __weak typeof(self) weakSelf = self;
                self.preparationForShowing(weakSelf);
            }
            
            [self.view.superview bringSubviewToFront:self.view];
            [UIView animateWithDuration:TNAnimateDurationNormal delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.view.alpha = 1.f;
            } completion:^(BOOL finished) {
                showing = NO;
            }];
        } else {
            showing = NO;
        }
        return;
    }
    
    self.view.alpha = 0.f;
    self.view.userInteractionEnabled = self.blockUserInteraction;
    if (self.blockUserInteraction && self.adjustUserInteractionDisabledImage) {
        self.view.backgroundColor = [UIColor clearColor];
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }
    
    if (self.preparationForShowing) {
        __weak typeof(self) weakSelf = self;
        self.preparationForShowing(weakSelf);
    }
    
    UIView *contentView = self.contentView;
    if (!CGSizeEqualToSize(CGSizeZero, self.contentSize)) {
        contentView.size = self.contentSize;
    }
    
    UIEdgeInsets insets = self.contentInsets;
    contentView.top = (self.view.height + insets.top - insets.bottom - contentView.height) / 2;
    contentView.left = (self.view.width + insets.left - insets.right - contentView.width) / 2;
    
    [window addSubview:self.view];
    
    [UIView animateWithDuration:TNAnimateDurationNormal delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.alpha = 1.f;
    } completion:^(BOOL finished) {
        showing = NO;
        if (self.duration > kVerySmallValue) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hide];
            });
        }
    }];
}

- (void)hide
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hide];
        });
        return;
    }
    
    if (hiding) {
        return;
    }
    
    hiding = YES;
    if (self.view.superview) {
        [UIView animateWithDuration:TNAnimateDurationNormal delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.alpha = 0.f;
        } completion:^(BOOL finished) {
            hiding = NO;
            [self.view removeFromSuperview];
        }];
    } else {
        hiding = NO;
    }
}

#pragma mark - UIKeyboardEvents
- (void)keyboardWillChangeFrame:(NSNotification *)noti
{
    CGPoint entPoint = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    UIViewAnimationCurve curve = [[noti.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    CGFloat duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration delay:0 options:curve << 16 animations:^{
        self.view.height = entPoint.y;
    } completion:nil];
}

#pragma mark - Toasts
+ (id)sharedLoadingToast
{
    static dispatch_once_t onceToken;
    static TNToast *toast = nil;
    dispatch_once(&onceToken, ^{
        toast = [self new];
        toast.type = TNToastTypeLoading;
        toast.blockUserInteraction = YES;
        
        UIView *view = [TNNibUtil loadObjectWithClass:[UIView class] fromNib:@"TNLoadingToast"];
        view.autoresizingMask = kContentViewAutoresizeMask;
        toast.contentView = view;
        [toast.view addSubview:view];
        toast.backgroundView = [view viewWithTag:2];
        toast.textLabel = (UILabel *)[view viewWithTag:3];
        toast.loadingIndicatorView = (UIActivityIndicatorView *)[view viewWithTag:4];
        
        toast.preparationForShowing = ^(TNToast *to) {
            [to.loadingIndicatorView startAnimating];
        };
    });
    return toast;
}

+ (id)toastWithText:(NSString *)text
{
    return [self toastWithText:text duration:1.5f blockUserInteraction:NO];
}

+ (id)toastWithText:(NSString *)text duration:(NSTimeInterval)duration blockUserInteraction:(BOOL)blockUserInteraction
{
    TNToast *toast = [self new];
    toast.type = TNToastTypeText;
    toast.duration = duration;
    toast.blockUserInteraction = blockUserInteraction;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 214.f, 84.f)];
    contentView.autoresizingMask = kContentViewAutoresizeMask;
    contentView.backgroundColor = [UIColor clearColor];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:contentView.bounds];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIImage *image = [UIImage imageNamed:@"common_toast_bg"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, image.size.width / 2, image.size.height / 2, image.size.width / 2)];
    bgView.image = image;
    bgView.alpha = 0.8f;
    [contentView addSubview:bgView];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.f, 12.f, 192.f, 60.f)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = kTNFont(16);
    textLabel.numberOfLines = 3;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.autoresizingMask = kContentViewAutoresizeMask;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = text;
    [contentView addSubview:textLabel];
    
    toast.textLabel = textLabel;
    
    [toast.view addSubview:contentView];
    toast.contentView = contentView;
    return toast;
}

+ (void)showLoadingToast
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; //显示
    [self showLoadingToastWithText:nil style:UIActivityIndicatorViewStyleGray adjustUserInteractionDisabledImage:YES blockUserInteraction:YES];
}

+ (void)showLoadingToastWithTransparentBackground
{
    [self showLoadingToastWithText:nil style:UIActivityIndicatorViewStyleGray adjustUserInteractionDisabledImage:NO blockUserInteraction:YES];
}

+ (void)showLoadingToastWithStyle:(UIActivityIndicatorViewStyle)style blockUserInteraction:(BOOL)blockUserInteraction
{
    [self showLoadingToastWithText:nil style:style adjustUserInteractionDisabledImage:YES blockUserInteraction:blockUserInteraction];
}

+ (void)showLoadingToastWithText:(NSString *)text
{
    [self showLoadingToastWithText:text style:UIActivityIndicatorViewStyleGray adjustUserInteractionDisabledImage:YES blockUserInteraction:YES];
}

+ (void)showLoadingToastWithText:(NSString *)text style:(UIActivityIndicatorViewStyle)style adjustUserInteractionDisabledImage:(BOOL)adjustUserInteractionDisabledImage blockUserInteraction:(BOOL)blockUserInteraction
{
    TNToast *loadingToast = [self sharedLoadingToast];
    loadingToast.blockUserInteraction = blockUserInteraction;
    loadingToast.loadingIndicatorView.activityIndicatorViewStyle = style;
    loadingToast.adjustUserInteractionDisabledImage = adjustUserInteractionDisabledImage;
    if (text.length > 0) {
        loadingToast.contentView.height = 100.f;
        loadingToast.loadingIndicatorView.top = 21.f;
        loadingToast.textLabel.text = text;
        loadingToast.textLabel.hidden = NO;
        loadingToast.backgroundView.hidden = NO;
    } else {
        loadingToast.contentView.height = 84.f;
        loadingToast.loadingIndicatorView.top = 32.f;
        loadingToast.textLabel.hidden = YES;
        loadingToast.backgroundView.hidden = YES;
    }
    [loadingToast show];
}

+ (void)hideLoadingToast
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; //显示
    [[self sharedLoadingToast] hide];
}

+ (void)showNetworkError
{
    [self showWithText:TNLStr(@"network_error")];
}

+ (void)showWithText:(NSString *)text
{
    [[self toastWithText:text] show];
}
+ (void)showWithText:(NSString *)text duration:(NSTimeInterval)duration{
    [self showWithText:text duration:duration blockUserInteraction:NO];
}

+ (void)showWithText:(NSString *)text duration:(NSTimeInterval)duration blockUserInteraction:(BOOL)blockUserInteraction
{
    [[self toastWithText:text duration:duration blockUserInteraction:blockUserInteraction] show];
}

@end