//
//  TNImageListView.m
//  TTXClient
//
//  Created by kiri on 13-8-12.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNImageListView.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "TNRequestManager.h"
#import "TNNumberUtil.h"

#define kLoadingIndicatorTagInPage 2

@interface TNImageItemView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, readonly) BOOL zoomed;
@property (nonatomic) BOOL zoomEnabled;
@property (nonatomic) CGFloat preferredZoomScale;

- (void)setImage:(UIImage *)image;
- (void)setImageId:(NSString *)imageId placeholderImage:(UIImage *)placeholderImage;
- (void)setImageURL:(NSURL *)imageURL placeholderImage:(UIImage *)placeholderImage;
- (void)resetZoomScale;

@end

@implementation TNImageItemView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.zoomEnabled = YES;
        self.delegate = self;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.imageView];
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGSize size = self.frame.size;
        CGSize loadingIndicatorSize = self.loadingIndicator.frame.size;
        self.loadingIndicator.frame = CGRectMake((size.width - loadingIndicatorSize.width) / 2, (size.height - loadingIndicatorSize.height) / 2, loadingIndicatorSize.width, loadingIndicatorSize.height);
        self.loadingIndicator.hidesWhenStopped = YES;
        self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.loadingIndicator];
    }
    return self;
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    if (!self.zoomEnabled) {
        self.imageView.frame = (CGRect){CGPointZero, boundsSize};
        self.scrollEnabled = NO;
        self.contentOffset = CGPointZero;
        return;
    }
    
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)resetZoomScale
{
    if (self.imageView.image) {
        self.zoomScale = self.preferredZoomScale;
        [self centerScrollViewContents];
    } else {
        self.zoomScale = self.preferredZoomScale;
    }
}

- (BOOL)zoomed
{
    return ![TNNumberUtil float:self.zoomScale isEqual:self.minimumZoomScale] && ![TNNumberUtil float:self.maximumZoomScale isEqual:self.minimumZoomScale];
}

- (void)setZoomEnabled:(BOOL)zoomEnabled
{
    if (_zoomEnabled != zoomEnabled) {
        _zoomEnabled = zoomEnabled;
        [self setImage:self.imageView.image];
    }
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;

    if (image == nil || CGSizeEqualToSize(image.size, CGSizeZero)) {
        self.maximumZoomScale = 1.f;
        self.minimumZoomScale = 1.f;
        self.zoomScale = 1.f;
        return;
    }
    
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.contentSize = image.size;
    
    CGFloat scaleW = self.frame.size.width / image.size.width;
    CGFloat scaleH = self.frame.size.height / image.size.height;
    CGFloat minScale = MIN(scaleW, scaleH);
    CGFloat maxScale = MAX(scaleW, scaleH);
    self.minimumZoomScale = MIN(minScale, 1.0f);
    if (self.zoomEnabled) {
        self.maximumZoomScale = MAX(maxScale, 2.0f);
        self.preferredZoomScale = scaleW;
    } else {
        self.preferredZoomScale = self.minimumZoomScale;
        self.maximumZoomScale = self.minimumZoomScale;
    }
    
    [self resetZoomScale];
}

- (void)setImageId:(NSString *)imageId placeholderImage:(UIImage *)placeholderImage
{
    NSURL *url = [[TNRequestManager defaultManager] imageURLWithPath:imageId];
    [self setImageURL:url placeholderImage:placeholderImage];
}

- (void)setImageName:(NSString *)imageName
{
    [self setImage:[UIImage imageNamed:imageName]];
}

- (void)setImageURL:(NSURL *)imageURL placeholderImage:(UIImage *)placeholderImage
{
    [self setImage:placeholderImage];
    if (imageURL) {
        [self.loadingIndicator startAnimating];
        UIActivityIndicatorView *loadingIndicator = self.loadingIndicator;
        __weak typeof(self) weakSelf = self;
        
        [self.imageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [loadingIndicator stopAnimating];
            if (image) {
                [weakSelf setImage:image];
            }
        }];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

- (void)zoomToNextLevel
{
    if (self.zoomEnabled) {
        CGFloat minScale = [TNNumberUtil float:self.preferredZoomScale isEqual:self.maximumZoomScale] ? self.minimumZoomScale : self.preferredZoomScale;
        if (self.zoomScale < minScale) {
            [self setZoomScale:minScale animated:YES];
            return;
        }
        
        if ([TNNumberUtil float:self.zoomScale isEqual:self.maximumZoomScale]) {
            [self setZoomScale:minScale animated:YES];
        } else {
            [self setZoomScale:self.maximumZoomScale animated:YES];
        }
    }
}

@end


@interface TNImageListView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageIndicator;
@property (nonatomic, strong) NSArray *tags;

@end

@implementation TNImageListView

- (void)initProperties
{
    self.showPageIndicator = NO;
    self.showLoadingIndicator = NO;
    self.zoomEnabled = YES;
    self.scrollEnabled = YES;
    self.tapEnabled = YES;
    self.doubleTapEnabled = YES;
    self.longPressEnabled = YES;
    self.pageSpacing = 20.f;
    
    CGRect frame = self.bounds;
    if (!CGRectIsEmpty(frame)) {
        frame.origin.x = - self.pageSpacing / 2;
        frame.size.width += self.pageSpacing;
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceHorizontal = YES;
    [self addSubview:self.scrollView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewTapped:)];
    [self.scrollView addGestureRecognizer:tapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewLongPressed:)];
    [self.scrollView addGestureRecognizer:longPressRecognizer];
    
    self.pageIndicator = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 56.f + self.pageIndicatorTopInset, self.frame.size.width, 36.f)];
    self.pageIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.pageIndicator.hidden = !self.showPageIndicator;
    self.pageIndicator.hidesForSinglePage = YES;
    [self.pageIndicator addTarget:self action:@selector(pageIndicatorDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageIndicator];
}

- (void)initAfterCreate
{
    if (self.imageList) {
        [self reloadData];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initProperties];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame imageList:nil];
}

- (id)initWithFrame:(CGRect)frame imageList:(NSArray *)imageList
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
        self.imageList = imageList;
        [self initAfterCreate];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initAfterCreate];
}

#pragma mark - UIScrollViewDelegate
- (void)setImageAtPgaeIndex:(NSInteger)index forView:(TNImageItemView *)view overwrite:(BOOL)isOverwrite
{
    if (index < 0 || !view || ![view isKindOfClass:[TNImageItemView class]] || index >= self.tags.count) {
        return;
    }
    if (!isOverwrite && view.imageView.image) {
        return;
    }
    id imageObj = [self.tags objectAtIndex:index];
    if (!imageObj) {
        return;
    }
    
    if ([imageObj isKindOfClass:[NSString class]]) {
        [view setImageName:imageObj];
    } else if ([imageObj isKindOfClass:[NSURL class]]) {
        [view setImageURL:imageObj placeholderImage:self.placeholderImage];
    } else if ([imageObj isKindOfClass:[UIImage class]]) {
        [view setImage:imageObj];
    }
}

- (void)resetImageWithCenterIndex:(NSInteger)index
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (index - 1 == idx || index + 1 == idx || index == idx) {
            [self setImageAtPgaeIndex:idx forView:obj overwrite:NO];
        } else {
            if ([obj isKindOfClass:[TNImageItemView class]]) {
                [(TNImageItemView *)obj setImage:nil];
            }
        }
    }];
}

- (void)resetZoomScale
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TNImageItemView class]] && idx != self.currentPageIndex) {
            [(TNImageItemView *)obj resetZoomScale];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.zoomEnabled) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
    int currentPageIndex = (int)(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width + 0.5);
    [self resetImageWithCenterIndex:currentPageIndex];
    [self resetZoomScale];
}

- (void)imageListViewDidEndScroll
{
    int currentPageIndex = (int)(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width + 0.5);
    if (currentPageIndex != self.currentPageIndex) {
        _currentPageIndex = currentPageIndex;
        self.pageIndicator.currentPage = currentPageIndex;
        if ([self.delegate respondsToSelector:@selector(imageListView:didMoveToPageAtIndex:)]) {
            [self.delegate imageListView:self didMoveToPageAtIndex:currentPageIndex];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(imageListViewWillBeginDragging:)]) {
        [self.delegate imageListViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(imageListViewWillBeginDecelerating:)]) {
        [self.delegate imageListViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self imageListViewDidEndScroll];
    if ([self.delegate respondsToSelector:@selector(imageListViewDidEndDecelerating:)]) {
        [self.delegate imageListViewDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(imageListViewDidEndDragging:willDecelerate:)]) {
        [self.delegate imageListViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self imageListViewDidEndScroll];
}

- (void)itemViewTapped:(UITapGestureRecognizer *)sender
{
    if (self.tapEnabled) {
        if ([self.delegate respondsToSelector:@selector(imageListView:didTapPageAtIndex:)]) {
            [self.delegate imageListView:self didTapPageAtIndex:self.currentPageIndex < self.numberOfPages ? self.currentPageIndex : NSNotFound];
        }
    }
}

- (void)itemViewDoubleTapped:(UITapGestureRecognizer *)sender
{
    if (self.doubleTapEnabled) {
        TNImageItemView *itemView = (TNImageItemView *)[self pageAtIndex:self.currentPageIndex];
        [itemView zoomToNextLevel];
    }
}

- (void)itemViewLongPressed:(UITapGestureRecognizer *)sender
{
    if (self.longPressEnabled) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            if([self.delegate respondsToSelector:@selector(imageListView:didLongPressPageAtIndex:)]) {
                [self.delegate imageListView:self didLongPressPageAtIndex:self.currentPageIndex < self.numberOfPages ? self.currentPageIndex : NSNotFound];
            }
        }
    }
}

#pragma mark - UIPageControl Events
- (void)pageIndicatorDidChangeValue:(UIPageControl *)sender
{
    [self setCurrentPageIndex:sender.currentPage animated:YES];
}

#pragma mark - Public Methods
- (void)setShowPageIndicator:(BOOL)showPageIndicator
{
    if (_showPageIndicator != showPageIndicator) {
        _showPageIndicator = showPageIndicator;
        self.pageIndicator.hidden = !showPageIndicator;
        
        // for ios7 hidesForSinglePage
        if (self.pageIndicator.numberOfPages < 2) {
            self.pageIndicator.hidden = YES;
        }
    }
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    [self setCurrentPageIndex:currentPageIndex animated:NO];
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex animated:(BOOL)animated
{
    if (self.currentPageIndex != currentPageIndex) {
        self.pageIndicator.currentPage = currentPageIndex;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * currentPageIndex, 0) animated:animated];
        if (!animated) {
            [self scrollViewDidEndScrollingAnimation:self.scrollView];
        }
    }
}

- (NSInteger)numberOfPages
{
    return self.pageIndicator.numberOfPages;
}

- (BOOL)zoomed
{
    TNImageItemView *itemView = (TNImageItemView *)[self pageAtIndex:self.currentPageIndex];
    return itemView && itemView.zoomed;
}

- (BOOL)isDragging
{
    return self.scrollView.isDragging;
}

- (BOOL)scrollEnabled
{
    return self.scrollView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    [self.scrollView setScrollEnabled:scrollEnabled];
}

- (void)setZoomEnabled:(BOOL)zoomEnabled
{
    if (_zoomEnabled != zoomEnabled) {
        _zoomEnabled = zoomEnabled;
        for (TNImageItemView *itemView in self.scrollView.subviews) {
            if ([itemView isKindOfClass:[TNImageItemView class]]) {
                [itemView setZoomEnabled:zoomEnabled];
            }
        }
    }
}

- (void)setPageSpacing:(CGFloat)pageSpacing
{
    if (![TNNumberUtil float:_pageSpacing isEqual:pageSpacing]) {
        _pageSpacing = pageSpacing;
        if (self.scrollView) {
            CGRect frame = self.frame;
            if (!CGRectIsEmpty(frame)) {
                frame.origin.x = - self.pageSpacing / 2;
                frame.size.width += self.pageSpacing;
            }
            self.scrollView.frame = frame;
        }
    }
}

- (UIView *)pageAtIndex:(NSInteger)pageIndex
{
    if (pageIndex >= 0 && pageIndex < self.scrollView.subviews.count) {
        TNImageItemView *itemView = [self.scrollView.subviews objectAtIndex:pageIndex];
        if ([itemView isKindOfClass:[TNImageItemView class]]) {
            return itemView;
        }
    }
    return nil;
}

- (UIImage *)imageAtIndex:(NSInteger)pageIndex
{
    return [(TNImageItemView *)[self pageAtIndex:pageIndex] imageView].image;
}

- (void)reloadData
{
    self.tags = [NSArray arrayWithArray:self.imageList];
    self.pageIndicator.numberOfPages = self.tags.count;
    
    // for ios7 hidesForSinglePage
    self.pageIndicator.hidden = !self.showPageIndicator || self.pageIndicator.numberOfPages < 2;
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.numberOfPages == 0) {
        return;
    }
    self.scrollView.scrollEnabled = self.numberOfPages > 1;
    
    self.pageIndicator.frame = CGRectMake(0, self.frame.size.height - 56.f + self.pageIndicatorTopInset, self.frame.size.width, 36.f);
    CGFloat offsetX = self.pageSpacing / 2;
    CGFloat pageWidth = self.scrollView.frame.size.width - self.pageSpacing;
    for (int i = 0; i < self.tags.count; i++) {
        TNImageItemView *itemView = [[TNImageItemView alloc] initWithFrame:CGRectMake(offsetX, 0, pageWidth, self.scrollView.frame.size.height)];
        itemView.zoomEnabled = self.zoomEnabled;
        itemView.imageView.contentMode = self.imageContentMode;
        itemView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        itemView.loadingIndicator.hidden = !self.showLoadingIndicator;
        [self.scrollView addSubview:itemView];
        offsetX += self.scrollView.frame.size.width;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.numberOfPages * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    if (self.currentPageIndex >= self.numberOfPages) {
        self.currentPageIndex = self.numberOfPages - 1;
    }
    if (self.currentPageIndex >= 0) {
        [self.scrollView setContentOffset:CGPointMake(self.currentPageIndex * self.scrollView.frame.size.width, 0)];
    }
    [self resetImageWithCenterIndex:self.currentPageIndex];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.frame.size.height);
}

@end
