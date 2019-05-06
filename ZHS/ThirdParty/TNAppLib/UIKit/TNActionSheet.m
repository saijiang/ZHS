//
//  TNActionSheet.m
//  WeZone
//
//  Created by DengQiang on 14-9-15.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNActionSheet.h"
#import "TNNibUtil.h"

#define kPositionSingle @"s"
#define kPositionTop @"t"
#define kPositionMiddle @"m"
#define kPositionBottom @"b"

#define kGroupInterval 8.f

@interface TNActionSheet ()

@property (weak, nonatomic) UIView *maskView;
@property (weak, nonatomic) UIView *contentView;

@property (nonatomic, copy) void (^titleLabelConfigurationHandler)(UILabel *label);
@property (nonatomic, copy) void (^actionButtonConfigurationHandler)(UIButton *button, TNAlertAction *action, NSInteger index);

@property (nonatomic) BOOL showing;
@property (nonatomic) BOOL hiding;

@property (nonatomic, weak) UIView *viewForShow;

@end

@implementation TNActionSheet

+ (instancetype)actionSheetWithTitle:(NSString *)title actions:(NSArray *)actions
{
    return [self actionSheetWithTitle:title actions:actions hasCancel:YES];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title actions:(NSArray *)actions hasCancel:(BOOL)hasCancel
{
    return [self actionSheetWithTitle:title actions:actions hasCancel:hasCancel viewForShow:[UIApplication sharedApplication].keyWindow];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title actions:(NSArray *)actions hasCancel:(BOOL)hasCancel viewForShow:(UIView *)viewForShow
{
    TNActionSheet *as = [[TNActionSheet alloc] initWithFrame:viewForShow.bounds];
    as.title = title;
    as.actions = actions;
    as.viewForShow = viewForShow;
    as.hasCancel = hasCancel;
    return as;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        maskView.alpha = 0;
        maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4f];
        maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMaskView:)];
        [maskView addGestureRecognizer:gr];
        [self addSubview:maskView];
        self.clipsToBounds = YES;
        self.maskView = maskView;
    }
    return self;
}

- (void)show
{
    [self showInView:self.viewForShow];
}

- (void)showInView:(UIView *)view
{
    if (view != nil) {
        self.viewForShow = view;
    } else if (self.viewForShow == nil) {
        self.viewForShow = [UIApplication sharedApplication].keyWindow;
    }
    self.frame = self.viewForShow.bounds;
    [self reloadData];
    self.contentView.top = self.height;
    
    if (self.viewForShow == nil) {
        return;
    }
    
    if (self.showing) {
        return;
    }
    
    self.showing = YES;
    [self.viewForShow addSubview:self];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.maskView.alpha = 1;
        self.contentView.bottom = self.height;
    } completion:^(BOOL finished) {
        self.showing = NO;
    }];
}

- (void)hide
{
    if (self.superview == nil) {
        self.hiding = NO;
        return;
    }
    
    if (self.hiding) {
        return;
    }
    
    self.hiding = YES;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.maskView.alpha = 0;
        self.contentView.top = self.height;
    } completion:^(BOOL finished) {
        self.hiding = NO;
        [self removeFromSuperview];
    }];
}

- (void)reloadData
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
    contentView.backgroundColor = self.title || self.titleView ? RGB(235, 235, 235) : [UIColor clearColor];
    
    __block CGFloat top = kGroupInterval;
    CGFloat left = 8;
    CGFloat width = contentView.width - left * 2;
    
    if (self.titleView) {
        self.titleView.origin = CGPointMake((contentView.width - self.titleView.width) / 2, 0);
        top = self.titleView.height;
        if (self.titleView.superview != contentView) {
            [self.titleView removeFromSuperview];
            [contentView addSubview:self.titleView];
        }
    } else if (self.title) {
        UIFont *titleFont = kTNFont(14.f);
        UIColor *titleColor = RGB(102, 102, 102);
        CGSize size = [TNViewUtil sizeWithString:self.title font:titleFont maxWidth:width];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(left + (width - size.width) / 2, top, size.width, size.height + 10.f)];
        label.numberOfLines = 0;
        label.font = titleFont;
        label.textColor = titleColor;
        label.text = self.title;
        if (size.height < titleFont.lineHeight * 1.5) {
            label.textAlignment = NSTextAlignmentCenter;
        } else {
            label.textAlignment = NSTextAlignmentLeft;
        }
        [contentView addSubview:label];
        
        if (self.titleLabelConfigurationHandler) {
            self.titleLabelConfigurationHandler(label);
        }
        
        top += label.height + kGroupInterval;
    }
    
    NSInteger cancelButtonIndex = NSNotFound;
    NSInteger otherButtonCount = self.actions.count;
    NSInteger lastOtherButtonIndex = otherButtonCount - 1;
    if (self.hasCancel) {
        cancelButtonIndex = self.actions.count - 1;
        otherButtonCount -= 1;
        lastOtherButtonIndex -= 1;
    }
    
    NSMutableDictionary *imageCache = [NSMutableDictionary dictionary];
    NSMutableDictionary *hilightedImageCache = [NSMutableDictionary dictionary];
    [self.actions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        TNAlertAction *action = obj;
        
        UIFont *buttonFont = kTNFont(22.f);
        UIColor *buttonColor = RGB(102, 102, 102);
        [button setTitle:action.title forState:UIControlStateNormal];
        [button setTitleColor:buttonColor forState:UIControlStateNormal];
        
        CGSize size = [TNViewUtil sizeWithString:action.title font:buttonFont maxWidth:width];
        UILabel *label = button.titleLabel;
        label.numberOfLines = 0;
        label.font = buttonFont;
        if (size.height < buttonFont.lineHeight * 1.5) {
            label.textAlignment = NSTextAlignmentCenter;
            button.titleEdgeInsets = UIEdgeInsetsZero;
        } else {
            label.textAlignment = NSTextAlignmentLeft;
            button.titleEdgeInsets = UIEdgeInsetsMake(0, (width - size.width) / 2, 0, (width - size.width) / 2);
        }
        button.frame = CGRectMake(left, top, width, size.height + 20.f);
        
        NSString *position = kPositionSingle;
        if (idx == cancelButtonIndex) {
        } else if (otherButtonCount < 2) {
        } else {
            if (idx == 0) {
                position = kPositionTop;
            } else if (idx == lastOtherButtonIndex) {
                position = kPositionBottom;
            } else {
                position = kPositionMiddle;
            }
        }
        
        UIImage *image = imageCache[position];
        if (image == nil) {
            image = [self createImageWithPosition:position fillColor:[UIColor whiteColor]];
            imageCache[position] = image;
        }
        
        UIImage *hilightedImage = hilightedImageCache[position];
        if (hilightedImage == nil) {
            hilightedImage = [self createImageWithPosition:position fillColor:RGB(245, 245, 245)];
            hilightedImageCache[position] = hilightedImage;
        }
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setBackgroundImage:hilightedImage forState:UIControlStateHighlighted];
        
        button.tag = idx;
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
        
        if (self.actionButtonConfigurationHandler) {
            self.actionButtonConfigurationHandler(button, action, idx);
        }
        
        top += button.height;
        if ([kPositionBottom isEqualToString:position] || [kPositionSingle isEqualToString:position]) {
            top += 8.f;
        }
    }];
    
    contentView.height = top;
    contentView.top = self.height;
    [self addSubview:contentView];
    self.contentView = contentView;
}

- (UIImage *)createImageWithPosition:(NSString *)position fillColor:(UIColor *)fillColor
{
    CGSize size = CGSizeMake(16, 16);
    CGFloat cornerRadius = 2.5f;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *path = nil;
    if ([kPositionSingle isEqualToString:position]) {
        path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    } else if ([kPositionMiddle isEqualToString:position]) {
        rect.size.height -= 0.5f;
        path = [UIBezierPath bezierPathWithRect:rect];
    } else if ([kPositionTop isEqualToString:position]) {
        rect.size.height -= 0.5f;
        path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    } else {
        path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    }
    [fillColor setFill];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(size.height / 2, size.width / 2, size.height / 2, size.width / 2)];
}

- (IBAction)didTapMaskView:(id)sender {
    [self hide];
}

- (IBAction)didClickButton:(id)sender {
    NSInteger index = [sender tag];
    if (index < 0 || index >= self.actions.count) {
        return;
    }
    
    TNAlertAction *action = [self.actions objectAtIndex:index];
    if ([action isEnabled] && action.handler) {
        __weak typeof(action) weakAction = action;
        action.handler(weakAction);
    }
    
    [self hide];
}

@end
