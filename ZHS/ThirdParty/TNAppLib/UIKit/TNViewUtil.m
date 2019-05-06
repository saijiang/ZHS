//
//  TNViewUtil.m
//  TNAppLib
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNViewUtil.h"
#import "UIDevice+TNAppLib.h"
#import "UIView+TNAppLib.h"

@interface TNViewUtilWebView : UIWebView <UIWebViewDelegate>

@property (nonatomic, copy) void (^contentHeightCompletion)(CGFloat height);

- (void)calcSizeWithHtmlString:(NSString *)htmlString baseURL:(NSURL *)baseURL completion:(void (^)(CGFloat height))completion;

@end

@implementation TNViewUtilWebView

- (void)calcSizeWithHtmlString:(NSString *)htmlString baseURL:(NSURL *)baseURL completion:(void (^)(CGFloat height))completion
{
    self.delegate = self;
    self.height = 1.f;
    self.scrollView.contentInset = [TNViewUtil justifiedWebViewContentInset];
    self.contentHeightCompletion = completion;
    UIViewController *vc = [[UIApplication sharedApplication].delegate window].rootViewController;
    [vc.view addSubview:self];
    [self loadHTMLString:htmlString baseURL:baseURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.contentHeightCompletion) {
        CGFloat height = self.scrollView.contentSize.height + self.scrollView.contentInset.top + self.scrollView.contentInset.bottom;
        self.contentHeightCompletion(height);
    }
    
    self.delegate = nil;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.contentHeightCompletion) {
        self.contentHeightCompletion(0.f);
    }
    
    self.delegate = nil;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
}

@end

@implementation TNViewUtil

+ (UIView *)snapshotViewForView:(UIView *)srcView afterScreenUpdates:(BOOL)afterUpdates
{
    if ([[UIDevice currentDevice] majorSystemVersion] < 7) {
        return [[UIImageView alloc] initWithImage:[self snapshotForView:srcView afterScreenUpdates:afterUpdates]];
    } else {
        return [srcView snapshotViewAfterScreenUpdates:afterUpdates];
    }
}

+ (UIImage *)snapshotForView:(UIView *)srcView afterScreenUpdates:(BOOL)afterUpdates
{
    UIGraphicsBeginImageContextWithOptions(srcView.bounds.size, NO, [UIScreen mainScreen].scale);
    if ([srcView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [srcView drawViewHierarchyInRect:srcView.bounds afterScreenUpdates:afterUpdates];
    } else {
        [srcView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

+ (CGFloat)heightWithLabel:(UILabel *)label
{
    return [self sizeWithString:label.text font:label.font maxWidth:label.width maxLine:label.numberOfLines lineBreakMode:label.lineBreakMode].height;
}

+ (CGSize)sizeWithLabel:(UILabel *)label maxWidth:(CGFloat)maxWidth
{
    return [label textRectForBounds:CGRectMake(0, 0, maxWidth, CGFLOAT_MAX) limitedToNumberOfLines:label.numberOfLines].size;
}

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    return [self sizeWithString:string font:font maxWidth:maxWidth maxLine:0];
}

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth maxLine:(NSInteger)maxLine
{
    return [self sizeWithString:string font:font maxWidth:maxWidth maxLine:maxLine lineBreakMode:NSLineBreakByTruncatingTail];
}

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth maxLine:(NSInteger)maxLine lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, maxWidth, 0.f)];
    label.numberOfLines = maxLine;
    label.font = font;
    label.lineBreakMode = lineBreakMode;
    label.text = string;
    return [label textRectForBounds:CGRectMake(0.f, 0.f, maxWidth, CGFLOAT_MAX) limitedToNumberOfLines:maxLine].size;
}

+ (CGSize)sizeWithAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth
{
    return [self sizeWithAttributedString:attributedString maxWidth:maxWidth maxLine:0];
}

+ (CGSize)sizeWithAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth maxLine:(NSInteger)maxLine
{
    return [self sizeWithAttributedString:attributedString maxWidth:maxWidth maxLine:maxLine lineBreakMode:NSLineBreakByTruncatingTail];
}

+ (CGSize)sizeWithAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth maxLine:(NSInteger)maxLine lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, maxWidth, 0.f)];
    label.numberOfLines = maxLine;
    label.lineBreakMode = lineBreakMode;
    label.attributedText = attributedString;
    return [label textRectForBounds:CGRectMake(0.f, 0.f, maxWidth, CGFLOAT_MAX) limitedToNumberOfLines:maxLine].size;
}

+ (void)heightWithHtmlString:(NSString *)htmlString baseURL:(NSURL *)baseURL maxWidth:(CGFloat)maxWidth completion:(void (^)(CGFloat))completion
{
    TNViewUtilWebView *web = [[TNViewUtilWebView alloc] initWithFrame:CGRectMake(0, -10, maxWidth, 1)];
    [web calcSizeWithHtmlString:htmlString baseURL:baseURL completion:completion];
}

+ (void)prepareDynamicLabel:(UILabel *)label withBelowUIView:(NSArray *)belowUIViews withContainers:(NSArray *)containers
{
    CGFloat originalHeight = label.height;
    
    CGSize size = [self sizeWithString:label.text font:label.font maxWidth:label.width];
    
    CGFloat newHeight = size.height;
    
    CGFloat delta = newHeight - originalHeight;
    
    for(UIView* tempView in belowUIViews)
    {
        CGRect frame = tempView.frame;
        frame.origin.y = frame.origin.y + delta;
        tempView.frame = frame;
    }
    
    for(UIView* tempView in containers)
    {
        CGRect frame = tempView.frame;
        frame.size.height = frame.size.height + delta;
        tempView.frame = frame;
    }
    
    label.height = newHeight;
}

+ (void)prepareDynamicLabel:(UILabel *)label withBelowUIView:(NSArray *)belowUIViews withContainers:(NSArray *)containers maxLine:(int)maxLine
{
    CGFloat originalHeight = label.height;
    
    CGSize size = [self sizeWithString:label.text font:label.font maxWidth:label.width maxLine:maxLine];
    
    CGFloat newHeight = size.height;
    
    CGFloat delta = newHeight - originalHeight;
    
    for(UIView* tempView in belowUIViews)
    {
        CGRect frame = tempView.frame;
        frame.origin.y = frame.origin.y + delta;
        tempView.frame = frame;
    }
    
    for(UIView* tempView in containers)
    {
        CGRect frame = tempView.frame;
        frame.size.height = frame.size.height + delta;
        tempView.frame = frame;
    }
    
    label.height = newHeight;
}

+ (void)prepareDynamicLabel:(UILabel *)label withRightUIView:(NSArray *)rightUIViews
{
    CGFloat originalWidth = label.width;
    CGSize newSize = [self sizeWithString:label.text font:label.font maxWidth:MAXFLOAT];
    
    CGFloat newWidth = newSize.width;
    
    CGFloat delta = newWidth - originalWidth;
    
    for(UIView *tempView in rightUIViews)
    {
        CGRect frame = tempView.frame;
        frame.origin.x = frame.origin.x + delta;
        tempView.frame = frame;
    }
    
    label.width = newWidth;
}

/**
 * calculate number of lines
 */
+ (NSInteger)calculateNumberOfLinesWithString:(NSString *)string font:(UIFont *)font width:(CGFloat)width
{
    CGSize size = [self sizeWithString:string font:font maxWidth:width];
    return (NSInteger) (size.height/font.lineHeight);
}

#pragma mark - badge
+ (void)justifyBadgeViewWithBaseline:(CGFloat)referenceX alignment:(NSTextAlignment)alignment maxWidth:(CGFloat)maxWidth backgroundView:(UIView *)backgroundView label:(UILabel *)label
{
    CGFloat minDelta = backgroundView.height / 4;
    CGFloat maxDelta = backgroundView.height / 2;
    CGFloat minWidth = backgroundView.height;
    CGFloat w = [self sizeWithString:label.text font:label.font maxWidth:maxWidth - minDelta maxLine:1].width;
    label.width = w;
    if (w + minDelta < minWidth) {
        backgroundView.width = minWidth;
    } else {
        backgroundView.width = MIN(maxWidth, w + maxDelta);
    }
    
    switch (alignment) {
        case NSTextAlignmentLeft:
        {
            backgroundView.left = referenceX;
            break;
        }
        case NSTextAlignmentCenter:
        {
            backgroundView.left = referenceX - backgroundView.width / 2;
            break;
        }
        case NSTextAlignmentRight:
        {
            backgroundView.left = referenceX - backgroundView.width;
            break;
        }
        default:
            break;
    }
    label.left = backgroundView.left + (backgroundView.width - label.width) / 2;
}


+ (void)justifyBadgeViewWithBaseline:(CGFloat)referenceX alignment:(NSTextAlignment)alignment maxWidth:(CGFloat)maxWidth containerView:(UIView *)containerView label:(UILabel *)label
{
    CGFloat minDelta = containerView.height / 4;
    CGFloat maxDelta = containerView.height / 2;
    CGFloat minWidth = containerView.height;
    CGFloat w = [self sizeWithString:label.text font:label.font maxWidth:maxWidth - minDelta maxLine:1].width;
    label.width = w;
    if (w + minDelta < minWidth) {
        containerView.width = minWidth;
    } else {
        containerView.width = MIN(maxWidth, w + maxDelta);
    }
    
    switch (alignment) {
        case NSTextAlignmentLeft:
        {
            containerView.left = referenceX;
            break;
        }
        case NSTextAlignmentCenter:
        {
            containerView.left = referenceX - containerView.width / 2;
            break;
        }
        case NSTextAlignmentRight:
        {
            containerView.left = referenceX - containerView.width;
            break;
        }
        default:
            break;
    }
    label.left = (containerView.width - label.width) / 2;
}

#pragma mark - Content Inset
+ (UIEdgeInsets)justifiedWebViewContentInset
{
    return UIEdgeInsetsMake(-8, -8, -8, -8);
}

+ (UIEdgeInsets)justifiedTextViewContentInset
{
    return UIEdgeInsetsZero;
}

+ (void)setTitle:(NSString *)title forButton:(UIButton *)button
{
    button.titleLabel.text = title;
    [button setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Animation
+ (void)animateWithAnimations:(void (^)(void))animations
{
    [self animateWithDuration:TNAnimateDurationNormal animations:animations];
}

+ (void)animateWithAnimations:(void (^)(void))animations completion:(void (^)(BOOL))completion
{
    [self animateWithDuration:TNAnimateDurationNormal animations:animations completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations
{
    [self animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animations completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion
{
    [self animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animations completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
}

+ (void)setUserMaskLayerWithView:(UIView *)view
{
    if (view.layer.mask == nil) {
        
        int width = view.width;
        
        switch (width) {
            case 18:
            {
                [self setMaskLayerWithImage:[UIImage imageNamed:@"common_mask_round_18"] forView:view];
                break;
            }
            case 60:
            {
                [self setMaskLayerWithImage:[UIImage imageNamed:@"common_mask_round_60"] forView:view];
                break;
            }
            case 70:
            {
                [self setMaskLayerWithImage:[UIImage imageNamed:@"common_mask_round_70"] forView:view];
                break;
            }
            case 40:
            {
                [self setMaskLayerWithImage:[UIImage imageNamed:@"common_mask_round_40"] forView:view];
                break;
            }
            case 36:
            {
                [self setMaskLayerWithImage:[UIImage imageNamed:@"common_mask_round_36"] forView:view];
                break;
            }
            case 110:
            {
                [self setMaskLayerWithImage:[UIImage imageNamed:@"common_mask_round_110"] forView:view];
                break;
            }
            default:
            {
                [self setMaskLayerWithImage:[UIImage imageNamed:@"common_mask_round"] forView:view];
                break;
            }
        }
        
        
    }
}

+ (void)setMaskLayerWithImage:(UIImage *)image forView:(UIView *)view
{
    [self setMaskLayerWithImage:image forView:view replaceCurrentMask:NO];
}

+ (void)setMaskLayerWithImage:(UIImage *)image forView:(UIView *)view replaceCurrentMask:(BOOL)replaceCurrentMask
{
    if (!replaceCurrentMask && view.layer.mask != nil) {
        return;
    }
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.contents = (id)image.CGImage;
    maskLayer.frame = view.bounds;
    maskLayer.contentsScale = [UIScreen mainScreen].scale;
    maskLayer.position = CGPointMake(view.width / 2, view.height / 2);
    view.layer.mask = maskLayer;
}

#pragma mark - TableView
+ (void)hideFooterSeperatorWithTableView:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

@end