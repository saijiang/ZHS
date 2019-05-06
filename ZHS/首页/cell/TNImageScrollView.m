//
//  TNImageScrollView.m
//  Tuhu
//
//  Created by tuhu on 15/5/5.
//  Copyright (c) 2015年 telenav. All rights reserved.
//

#import "TNImageScrollView.h"
#import "UIImageView+WebCache.h"
#import "TNH5ViewController.h"

#define kCount    [_array count]
#define kHeight   (self.frame.size.height)
#define kWidth1 ([[UIScreen mainScreen] bounds].size.width)

@implementation TNImageScrollView
{
    UIView *_view;
    UIPageControl *_pageControl;
    NSMutableArray *_array;
    NSTimer *_time;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //加一个定时器
        _pageControlOpen = YES;
        _titleHidden = YES;
        _isCycel = YES;
        _autoRun = NO;
        _isPlay = NO;
        _separateDistance = 0;
        _isContentModeOfFit = YES;
//        _time = [NSTimer scheduledTimerWithTimeInterval:6.5f target:self selector:@selector(showTime) userInfo:nil repeats:YES];
//        if (_autoRun) {
//            [_time fire];
//        }
        _view =[[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, self.frame.size.height)];
        _view.userInteractionEnabled = YES;
        [self addSubview:_view];
    }
    return self;
}

- (void) Ary:(NSArray*)array
{
    _array = [NSMutableArray arrayWithArray:array];
//    [_array addObjectsFromArray:@[[UIImage imageNamed:<#(nonnull NSString *)#>]]];
//    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [_array addObject:obj[@"url"]];
//    }];
//    NSArray *da = @[@"1",@"3",@"4",@"2"];
    
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    //显示内容区域的大小
    _scrollView.contentSize=CGSizeMake((self.with+self.separateDistance)*(_isCycel? kCount+2:kCount), self.frame.size.height);
    //设置是否能够整页翻动
    _scrollView.pagingEnabled=YES;
    //设置是否能够滚动
    _scrollView.scrollEnabled=YES;
    _scrollView.userInteractionEnabled = YES;
    //限定滚动方向
    _scrollView.directionalLockEnabled=YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.userInteractionEnabled = YES;
    //设置scrollView的代理
    _scrollView.delegate=self;
    
    for (int i = 0; i < [array count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i+1;
        if (_with == kWidth) {
            if (_isContentModeOfFit) {
                imageView.contentMode =  UIViewContentModeScaleAspectFit;
            }
        imageView.frame = CGRectMake((i+1) * (self.with+_separateDistance)+_separateDistance, 0, self.with, _titleHidden?self.heights:(self.heights));
        }else{
        imageView.contentMode =  UIViewContentModeScaleAspectFit;
        imageView.frame =  CGRectMake((i) * (self.with+_separateDistance)+_separateDistance, 0, self.with, _titleHidden?self.heights:(self.heights));
        }
        
//        imageView.image = [UIImage imageNamed:da[i]];
        [imageView sd_setImageWithURL:[NSURL URLWithString:array[i]] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
//        imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:array[i]]]];
//        imageView.frame = CGRectMake((i) * (self.with+_separateDistance)+_separateDistance, 0, self.with, _titleHidden?self.heights:(self.heights));
        imageView.userInteractionEnabled = YES;
        if (self.block) {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClick:)];
            [imageView addGestureRecognizer:tapGestureRecognizer];
            
        }
        [_scrollView addSubview:imageView];

        DLog(@"%@",array[i]);
        
        if (_titleHidden == NO) {
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake((i) * (self.with+_separateDistance)+_separateDistance, self.heights+3, self.with, 15)];
            lable.text =_titles[i];
                lable.textColor = self.titleColor?self.titleColor: [[TNAppContext currentContext] getColor:@"#323232"];
            lable.textAlignment = NSTextAlignmentCenter;
            lable.userInteractionEnabled = YES;
            lable.font =[UIFont fontWithName:@"Helvetica" size:self.titleFont?self.titleFont:14.0f];
            [_scrollView addSubview:lable];
        }
        
        
        
        if (i == 1) {
//            UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
//            play.frame = CGRectMake(40, 55, 26, 26);
//            UIImage *image =[UIImage imageNamed:@"play"];
//            [play setBackgroundImage:image forState:UIControlStateNormal] ;
//            [imageView addSubview:play];
//            play.hidden = YES;
//            if (_isPlay) {
//                play.hidden = NO;
//            }else{
//                play.hidden = YES;
//            }
        }

    }
    DLog(@"%@",_scrollView.subviews);

    // [[_array lastObject] stringByReplacingOccurrencesOfString:@"1500" withString:@"250"]
    // 取出最后一张图片放第一张
    if (_isCycel) {
        UIImageView *ImageView = [[UIImageView alloc] init];
        [ImageView sd_setImageWithURL:[NSURL URLWithString:[array lastObject] ] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
        if (_with == kWidth) {
            if (_isContentModeOfFit) {
                ImageView.contentMode =  UIViewContentModeScaleAspectFit;
            }
        }else{
        ImageView.contentMode =  UIViewContentModeScaleAspectFit;
        }
        ImageView.frame = CGRectMake(0, 0, kWidth, kHeight);
        ImageView.userInteractionEnabled = YES;
        [_scrollView insertSubview:ImageView atIndex:0];
        
        // 取出最后一张放到第一张
        UIImageView * ImageView1 = [[UIImageView alloc] init];
        [ImageView1 sd_setImageWithURL:[NSURL URLWithString:[array firstObject] ] placeholderImage:[UIImage imageNamed:@"ZHS_Def"]];
        ImageView1.frame = CGRectMake((kCount+1) * kWidth, 0, kWidth, kHeight);
        [_scrollView addSubview:ImageView1];
        if (_with == kWidth) {
            if (_isContentModeOfFit) {
                ImageView1.contentMode =  UIViewContentModeScaleAspectFit;
            }
        }else{
        ImageView1.contentMode =  UIViewContentModeScaleAspectFit;
        }
        ImageView1.userInteractionEnabled = YES;
        [_scrollView scrollRectToVisible:CGRectMake(kWidth, 0, kWidth, kHeight) animated:NO];
    }
    [_view addSubview:_scrollView];

    if (kCount>1 &&_pageControlOpen)
    {
        _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(kWidth1/2-25, kHeight-20, 50, 5)];
        _pageControl.numberOfPages = kCount;
        _pageControl.currentPage=0;
        _pageControl.currentPageIndicatorTintColor=[[TNAppContext currentContext] getColor:@"#67c758"];
        _pageControl.pageIndicatorTintColor=[UIColor whiteColor];
        [_pageControl addTarget:self action:@selector(pageControlAction) forControlEvents:UIControlEventValueChanged];
        [_view addSubview:_pageControl];
    }
    DLog(@"jieshu");
    
    
}
-(void)viewClick:(UITapGestureRecognizer*)sender{
    UIImageView *imageV =(UIImageView*) sender.view;
    if (self.block) {
        self.block(imageV.tag);
    }
}
//#pragma mark ----定时器的触发方法
//- (void) showTime
//{
//    if (_isCycel) {
//    int page = (int)_pageControl.currentPage; // 获取当前页数
//    if (page == kCount-1) {
//        [_scrollView scrollRectToVisible:CGRectMake( kWidth1, 0, kWidth1, kHeight) animated:NO];
//        return ;
//    }
//    [_scrollView scrollRectToVisible:CGRectMake((page + 2) * kWidth1, 0, kWidth1, kHeight) animated:NO];
//    }
//}
#pragma mark - scrollView拖动时调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = (int)(_scrollView.contentOffset.x/kWidth1) - 1;
    _pageControl.currentPage = page;


}
#pragma mark - scrollview滚动减速结束时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentPage = (int)_scrollView.contentOffset.x/kWidth1; // 和上面两行效果一样
    if (currentPage==0)
    {
        [_scrollView scrollRectToVisible:CGRectMake(kWidth1 * kCount,0,kWidth1,kHeight) animated:NO]; // 序号0 最后1页
        return;
    }
    else if (currentPage == (kCount+1))
    {
        [_scrollView scrollRectToVisible:CGRectMake(kWidth1,0,kWidth1,kHeight) animated:NO]; // 最后+1,循环第1页
        return;
    }

}
- (void)pageControlAction
{
    int page = (int)_pageControl.currentPage; // 获取当前页数
    [_scrollView scrollRectToVisible:CGRectMake((page + 1) * kWidth1, 0, kWidth1, kHeight) animated:NO];
}

-(void)dealloc{

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
