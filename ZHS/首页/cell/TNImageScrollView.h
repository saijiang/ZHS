//
//  TNImageScrollView.h
//  Tuhu
//
//  Created by tuhu on 15/5/5.
//  Copyright (c) 2015年 telenav. All rights reserved.
//

#import <UIKit/UIKit.h>
 typedef void(^block)(NSInteger linkNumber) ;
@interface TNImageScrollView : UIView<UIScrollViewDelegate>
@property(nonatomic,copy) block block;
@property(nonatomic,assign)CGFloat with;
@property(nonatomic,assign)CGFloat heights;
@property(nonatomic,assign)CGFloat separateDistance;
@property(nonatomic,assign)BOOL autoRun;
@property(nonatomic,assign)BOOL pageControlOpen;
@property(nonatomic,assign)BOOL titleHidden;
@property(nonatomic,assign)BOOL isCycel;
@property(nonatomic,strong)NSArray *titles;
@property(nonatomic,assign)BOOL isPlay;

@property(nonatomic,strong) UIScrollView  *scrollView;

@property(nonatomic,assign)BOOL isContentModeOfFit;

@property(nonatomic,assign)CGFloat titleFont;
@property(nonatomic,strong)UIColor* titleColor;


- (void) Ary:(NSArray*)array;
//-(void)setImageArray:(NSArray*)imageArray;

@end
