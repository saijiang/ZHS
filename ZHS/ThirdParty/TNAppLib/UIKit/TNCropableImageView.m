	//
//  LLScrollView.m
//  LLTest
//
//  Created by Mr.Wang(Wang Zhao) on 13-12-19.
//  Copyright (c) 2013年 Mr.Wang(Wang Zhao). All rights reserved.
//

#import "TNCropableImageView.h"

#define DEFAULT_MIN_SIDE_MAX_WIDTH 1024

@interface TNCropableScrollView : UIScrollView

@end

@interface TNCropableImageView () <UIScrollViewDelegate>

@property (nonatomic, strong) TNCropableScrollView* scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) CGFloat preferredZoomScale;

-(void)resetZoomScale;
-(void)centerScrollViewContents;
@end

@implementation TNCropableImageView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initUi];
}

-(void)initUi
{
    if(self.minSideMaxWidth < kVerySmallValue) {
        self.minSideMaxWidth = self.width;
    }
    
    if(!self.scrollView) {
        self.scrollView = [[TNCropableScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.clipsToBounds = NO;
        self.scrollView.delegate = self;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
    }
    
    if(!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.clipsToBounds = NO;
        [self.scrollView addSubview:self.imageView];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

#pragma mark -
-(void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    if (image == nil || CGSizeEqualToSize(image.size, CGSizeZero)) {
        self.scrollView.maximumZoomScale = 1.f;
        self.scrollView.minimumZoomScale = 1.f;
        self.scrollView.zoomScale = 1.f;
        return;
    }
    
    self.scrollView.frame = CGRectMake((self.width - self.minSideMaxWidth) / 2, (self.height - self.minSideMaxWidth) / 2, self.minSideMaxWidth, self.minSideMaxWidth);
    self.scrollView.contentSize = image.size;
    self.imageView.frame = (CGRect){CGPointZero, image.size};
    
    CGFloat scaleMinW = self.minSideMaxWidth / image.size.width;
    CGFloat scaleMinH = self.minSideMaxWidth / image.size.height;
    CGFloat minScale = MAX(scaleMinW, scaleMinH);
    
    CGFloat scaleMaxW = self.width / image.size.width;
    CGFloat scaleMaxH = self.height / image.size.height;
    self.preferredZoomScale = MAX(minScale, MIN(scaleMaxW, scaleMaxH));
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = MAX(self.preferredZoomScale, minScale * 2);
    
    [self resetZoomScale];
    self.scrollView.contentOffset = CGPointMake((self.imageView.width - self.minSideMaxWidth) / 2, (self.imageView.height - self.minSideMaxWidth) / 2);
}

-(UIImage *)image
{
    return self.imageView.image;
}

#pragma mark -
-(void)resetZoomScale
{
    if (self.imageView.image) {
        self.scrollView.zoomScale = self.preferredZoomScale;
        [self centerScrollViewContents];
    } else {
        self.scrollView.zoomScale = self.preferredZoomScale;
    }
}

-(void)centerScrollViewContents
{
    self.imageView.origin = CGPointZero;
}

#pragma mark -
- (UIImage *)croppedImage
{
    return [self cropImageInRect:self.scrollView.frame];
}

- (UIImage*)cropImageInRect:(CGRect)rect
{
    CGFloat left = rect.origin.x - self.scrollView.left + self.scrollView.contentOffset.x;
    CGFloat top = rect.origin.y - self.scrollView.top + self.scrollView.contentOffset.y;
    
    CGFloat scale = self.scrollView.zoomScale * self.image.scale;
    CGSize imageSize = rect.size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGRect drawRect = CGRectMake(-left, -top, self.image.size.width * scale, self.image.size.height * scale);
    [self.image drawInRect:drawRect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (self == view) {
        return self.scrollView;
    }
    return view;
}

@end

@implementation TNCropableScrollView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self.superview pointInside:point withEvent:event];
}

@end
