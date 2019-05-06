//
//  TNImagePreviewManager.m
//  TTXClient
//
//  Created by Mr.Wang(Wang Zhao) on 13-9-4.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNImagePreviewManager.h"
#import "TNImageListView.h"
#import "TNToast.h"
#import "TNApplication.h"

@interface TNImagePreviewManager () <UIActionSheetDelegate>

@property (nonatomic, strong) TNImageListView *imageListView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSArray * fromViewList;

@end

@implementation TNImagePreviewManager 

+ (TNImagePreviewManager *)defaultManager
{
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (void)showImages:(NSArray *)imageList placeholderImage:(UIImage *)placeholderImage atIndex:(NSInteger)index fromViewList:(NSArray *)viewList
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:window.bounds];
        self.backgroundView.backgroundColor = [UIColor blackColor];
    }
    if(!self.imageListView)
    {
        self.imageListView = [[TNImageListView alloc] initWithFrame:window.bounds imageList:imageList];
    }
    self.fromViewList = viewList;
    self.imageListView.backgroundColor = [UIColor clearColor]; // [UIColor colorWithWhite:0.f alpha:0.7f];
    self.imageListView.currentPageIndex = index;
    self.imageListView.showPageIndicator = YES;
    self.imageListView.showLoadingIndicator = YES;
    self.imageListView.delegate = self;
    self.imageListView.placeholderImage = placeholderImage;
    
    UIView *fromView = viewList == nil || viewList.count > index ? [viewList objectAtIndex:index] : self.imageListView;
    UIView *toView = self.imageListView;
    
    CGPoint fromCenter = [fromView.superview convertPoint:fromView.center toView:window];
    CGPoint toCenter = toView.center;
    self.imageListView.transform = CGAffineTransformMake(fromView.frame.size.width / toView.frame.size.width, 0 ,0, fromView.frame.size.height / toView.frame.size.height, fromCenter.x - toCenter.x, fromCenter.y - toCenter.y);
    
    window.userInteractionEnabled = NO;
    self.imageListView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    [window addSubview:self.backgroundView];
    [window addSubview:self.imageListView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_START_SHOW_IMAGES object:nil];
    [[TNApplication sharedApplication] setStatusBarHidden:TNApplicationStatusBarHiddenNone style:UIStatusBarStyleDefault withAnimation:UIStatusBarAnimationFade animationDuration:TNAnimateDurationNormal];
    [UIView animateWithDuration:TNAnimateDurationNormal delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.imageListView.alpha = 1.0;
        self.backgroundView.alpha = 1.0;
         self.imageListView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        window.userInteractionEnabled = YES;
    }];
}

- (void)imageListView:(TNImageListView*)imageListView didTapPageAtIndex:(NSInteger)pageIndex;
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    UIView *fromView = self.imageListView;
    UIView *toView = self.fromViewList.count > pageIndex ? [self.fromViewList objectAtIndex:pageIndex] : self.imageListView;
    CGPoint fromCenter = [fromView.superview convertPoint:fromView.center toView:window];
    CGPoint toCenter = [toView.superview convertPoint:toView.center toView:window];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_END_SHOW_IMAGES object:nil];
    [[TNApplication sharedApplication] resetStatusBarWithAnimated:YES animationDuration:TNAnimateDurationNormal];
    window.userInteractionEnabled = NO;
//    self.imageListView.alpha = 1.0;
    [UIView animateWithDuration:TNAnimateDurationNormal delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.imageListView.alpha = 0.0;
        self.backgroundView.alpha = 0.0;
        self.imageListView.transform = CGAffineTransformMake(toView.frame.size.width / fromView.frame.size.width, 0, 0, toView.frame.size.height / fromView.frame.size.height, toCenter.x - fromCenter.x, toCenter.y - fromCenter.y);
    } completion:^(BOOL finished) {
        self.imageListView.delegate = nil;
        [self.imageListView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        self.imageListView = nil;
        window.userInteractionEnabled = YES;
    }];
    
}

- (void)imageListView:(TNImageListView*)imageListView didLongPressPageAtIndex:(NSInteger)pageIndex
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存照片", nil];
    [actionSheet showInView:self.imageListView];
}

- (void) savePhoto
{
    UIImage *image = [self.imageListView imageAtIndex:self.imageListView.currentPageIndex];
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [TNToast showWithText:@"保存成功"];
        });
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self savePhoto];
            break;
        }
    }
}


@end
