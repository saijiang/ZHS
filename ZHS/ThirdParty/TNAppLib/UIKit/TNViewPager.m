//
//  TNViewPager.m
//  WeZone
//
//  Created by Mr.Wang(Wang Zhao) on 14-1-3.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNViewPager.h"

@interface TNViewPager()  <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

/*!
 * @{resueIndentifier, TNViewPagerCell}
 */
@property (nonatomic, strong) NSMutableArray* reuseViews;

/*!
 * 最多3个。
 */
@property (nonatomic, strong) NSMutableArray* contentViews;

@property (nonatomic) CGFloat pageWidth;
@property (nonatomic) CGFloat pageHeight;

/*!
 *
 */
@property (nonatomic) NSUInteger pageCount;

@property (nonatomic) NSTimer* timer;
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic) BOOL isAutoScrolling;
@end

@implementation TNViewPager

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if(newWindow)
    {
        [self initUi];
        [self resetAutoScroll];
    }
    else
    {
        [self.timer invalidate];
    }
}

- (void)initUi
{
    BOOL needInit = !self.scrollView || !self.pageControl;
    if(needInit)
    {
        [self insertSubview:[UIView new] atIndex:0];//经测试 ios7 有个bug。如果UIViewController勾选了 “Ajust Scroll View Insets”，不管scrollView是否是该controller的根View的直接子view，只要该scrollView的父View的第一个子View是ScrollView，那么这个scrollView的contentInset的top会被加64。
        
        self.reuseViews = [NSMutableArray array];
        self.contentViews = [NSMutableArray array];
        if(!self.scrollView)
        {
            self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
            self.scrollView.contentSize = CGSizeMake(self.pageWidth * 3, self.pageHeight);
            self.scrollView.contentOffset = CGPointMake(self.pageWidth, 0);
            self.scrollView.pagingEnabled = YES;
            self.scrollView.autoresizesSubviews = NO;
            self.scrollView.showsVerticalScrollIndicator = NO;
            self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.scrollView.delegate = self;
            [self addSubview:self.scrollView];
        }
        
        if(!self.pageControl)
        {
            self.pageControl = [UIPageControl new];
            self.pageControl.frame = CGRectMake(0, self.height * 0.8, self.width, self.height * 0.2);
            self.pageControl.userInteractionEnabled = NO;
            [self addSubview:self.pageControl];
            self.pageIndex = 0;
        }
    }
    [self reloadData];
}

- (CGFloat)pageWidth
{
    return self.width;
}

- (CGFloat)pageHeight
{
    return self.height;
}

- (UIView*)viewAtPage:(NSInteger)page
{
    UIView* view = [self.dataResource viewPager:self pageAtIndex:page];
    if(view.restorationIdentifier.length > 0)
    {
        if(![self.reuseViews containsObject:view])
        {
            [self.reuseViews addObject:view];
        }
    }
    return view;
}

- (void)setPageCount:(NSUInteger)pageCount
{
    _pageCount = pageCount;
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.hidden = pageCount <= 1 || !self.showPageControl;
}

- (void)setPageIndex:(NSInteger)pageIndex
{
    _pageIndex = pageIndex;
    self.pageControl.currentPage = pageIndex;
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    _showPageControl = showPageControl;
    self.pageControl.hidden = self.pageCount <= 1 || showPageControl;
}

- (void)reloadData
{
    self.pageCount = [self.dataResource numberOfPages];
    self.pageControl.hidden = self.pageCount <= 1 || !self.showPageControl;
    if(self.pageIndex >= self.pageCount)
    {
        self.pageIndex = self.pageCount - 1;
    }
    [self loadView];
}

- (void)loadView
{
    NSUInteger pageCount = self.pageCount;
    
    if(pageCount == 0)
    {
        return;
    }
    
    if([self isOnePageAndScrollDisable])
    {
        [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.contentViews removeAllObjects];
        UIView* view = [self viewAtPage:0];
        [self.contentViews addObject:view];
        [self.scrollView addSubview:view];
        view.frame = CGRectMake(0, 0, self.pageWidth, self.pageHeight);
        [self checkAndAddTapGesture:view];
        [_scrollView setContentOffset:CGPointMake(0, 0)];
    }
    else
    {
        [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.contentViews removeAllObjects];
        [self.contentViews addObject:[self viewAtPage:[self getFixedIndex:self.pageIndex - 1]]];
        [self.contentViews addObject:[self viewAtPage:[self getFixedIndex:self.pageIndex]]];
        [self.contentViews addObject:[self viewAtPage:[self getFixedIndex:self.pageIndex + 1]]];
        [self.contentViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView* view = obj;
            view.frame = CGRectMake(self.pageWidth * idx, 0, self.pageWidth, self.pageHeight);
            [self checkAndAddTapGesture:view];
            [self.scrollView addSubview:view];
        }];
        [_scrollView setContentOffset:CGPointMake(self.pageWidth, 0)];
    }
}

- (void)checkAndAddTapGesture:(UIView*)view
{
    NSUInteger tapIndex = NSNotFound;
    if(view.gestureRecognizers.count > 0)
    {
        tapIndex = [view.gestureRecognizers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isKindOfClass:[UITapGestureRecognizer class]])
            {
                return YES;
            }
            return NO;
        }];

    }
    if(tapIndex == NSNotFound)
    {
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [view addGestureRecognizer:tapGesture];
    }
}

- (NSInteger)getFixedIndex:(NSInteger)index
{
    NSUInteger pageCount = self.pageCount;
    if(pageCount == 0)
    {
        return 0;
    }
    
    if(index < 0)
    {
        index += pageCount;
    }
    else if(index >= pageCount)
    {
        index -= pageCount;
    }
    else
    {
        return index;
    }
    return [self getFixedIndex:index];
}

- (id)dequeueReusableViewWithIdentifier:(NSString *)identifier
{
    if(identifier.length == 0)
    {
        return nil;
    }
    
    NSUInteger index = [self.reuseViews indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        UIView* cellTemp = obj;
        if([cellTemp.restorationIdentifier isEqualToString:identifier])
        {
            if(![self.contentViews containsObject:cellTemp])
            {
                return YES;
            }
        }
        return NO;
    }];
    
    return index == NSNotFound ? nil : self.reuseViews[index];
}

- (void)onTap
{
    if([self.delegate respondsToSelector:@selector(viewPager:didClickAtIndex:)])
    {
        [self.delegate viewPager:self didClickAtIndex:self.pageIndex];
    }
}

#pragma mark -
- (BOOL) isOnePageAndScrollDisable
{
    return !self.onePageScrollEnable && self.pageCount == 1;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if([self isOnePageAndScrollDisable])
    {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        return;
    }
    else
    {
        CGFloat x = scrollView.contentOffset.x;
        
        if(!self.scrollCircularly)
        {
            if(self.pageIndex == 0)
            {
                if(x < self.pageWidth)
                {
                    [self.scrollView setContentOffset:CGPointMake(self.pageWidth, 0) animated:NO];
                    return ;
                }
            }
            
            if(self.pageIndex == self.pageCount - 1)
            {
                if(x > self.pageWidth)
                {
                    [self.scrollView setContentOffset:CGPointMake(self.pageWidth, 0) animated:NO];
                    return ;
                }
            }
        }
        
        if(x >= (self.pageWidth * 2)) {
            self.pageIndex = [self getFixedIndex:self.pageIndex + 1];
            [self loadView];
        }
        
        if(x <= 0) {
            self.pageIndex = [self getFixedIndex:self.pageIndex - 1];
            [self loadView];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self resetAutoScroll];
}

- (void)resetAutoScroll
{
    if(self.isAutoScrolling)
    {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
    }
}

#pragma mark -
- (void)scrollToNextPage
{
    if(![self isOnePageAndScrollDisable])
    {
        [self.scrollView scrollRectToVisible:CGRectMake(self.pageWidth * 2, 0, self.pageWidth, self.pageHeight) animated:YES];
    }
}

- (void)startAutoScroll:(NSTimeInterval)timeInterval
{
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
    self.isAutoScrolling = YES;
    self.timeInterval = timeInterval;
}

- (void)stopAutoScroll
{
    [self.timer invalidate];
    self.timer = nil;
    self.isAutoScrolling = NO;
}

@end
