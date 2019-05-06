//
//  TNImageListView.h
//  TTXClient
//
//  Created by kiri on 13-8-12.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//
#import <UIKit/UIKit.h>

#define kImageViewTagInPage 1

@class TNImageListView;
@protocol TNImageListViewDelegate <NSObject>

@optional
- (void)imageListView:(TNImageListView *)imageListView didMoveToPageAtIndex:(NSInteger)pageIndex;

- (void)imageListView:(TNImageListView*)imageListView didTapPageAtIndex:(NSInteger)pageIndex;

- (void)imageListView:(TNImageListView*)imageListView didLongPressPageAtIndex:(NSInteger)pageIndex;

- (void)imageListViewWillBeginDragging:(TNImageListView*)imageListView;

- (void)imageListViewDidEndDragging:(TNImageListView*)imageListView willDecelerate:(BOOL)willDecelerate;

- (void)imageListViewWillBeginDecelerating:(TNImageListView*)imageListView;

- (void)imageListViewDidEndDecelerating:(TNImageListView*)imageListView;

@end

@interface TNImageListView : UIView

@property (nonatomic, weak) IBOutlet id<TNImageListViewDelegate> delegate;

// default is NO.
@property (nonatomic) BOOL showPageIndicator;

@property (nonatomic, readonly, strong) UIPageControl *pageIndicator;

@property (nonatomic) CGFloat pageIndicatorTopInset;

@property (nonatomic) UIViewContentMode imageContentMode;

@property (nonatomic,copy) UIImage *placeholderImage;

// default is NO.
@property (nonatomic) BOOL showLoadingIndicator;

// An array of imageName(NSString) or UIImage or NSURL.
@property (nonatomic, strong) NSArray *imageList;

@property (nonatomic) NSInteger currentPageIndex;

@property (nonatomic, readonly) NSInteger numberOfPages;

// Whether or not the current page is zoomed.
@property (nonatomic, readonly) BOOL zoomed;

// A Boolean value that indicates whether the user is scrolling the view with his finger.
@property (nonatomic, readonly) BOOL isDragging;

// default is YES.
@property (nonatomic) BOOL tapEnabled;

// default is YES.
@property (nonatomic) BOOL doubleTapEnabled;

// default is YES.
@property (nonatomic) BOOL longPressEnabled;

// default is YES.
@property (nonatomic) BOOL scrollEnabled;

// default is YES
@property (nonatomic) BOOL zoomEnabled;

// A CGFloat value that determines the gap between the pages.
// default is 20.
@property (nonatomic) CGFloat pageSpacing;

- (id)initWithFrame:(CGRect)frame imageList:(NSArray *)imageList;

- (UIView *)pageAtIndex:(NSInteger)pageIndex;

- (UIImage *)imageAtIndex:(NSInteger)pageIndex;

/**
 * Set the current center page and optionally animate the transition.
 * <b>Only animate if the distance between the actual page and the informed
 * is one. Example: If is one page 1 and you inform page 3, will not animate.</b>
 */
- (void)setCurrentPageIndex:(NSInteger)currentPageIndex animated:(BOOL)animated;

- (void)reloadData;

@end