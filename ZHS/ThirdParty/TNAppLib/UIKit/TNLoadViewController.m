//
//  TNLoadViewController.m
//  Tuhu
//
//  Created by Tuhu on 15/1/13.
//  Copyright (c) 2015年 telenav. All rights reserved.
//
#define widthFactor 8/9
#define heightFactor 71/80
#define colorFactor 255
#define FPS 5.0//定义帧率

#import "TNLoadViewController.h"
#import "TNFlowUtil.h"
#import "ZHSLoginViewController.h"
#import "TNMainTabBarControllerDelegate.h"

@interface TNLoadViewController ()<UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView* mySV;
@property(nonatomic,strong)UIPageControl* pageControl;

@property(nonatomic,strong)UIImageView* carForFirst;
@property(nonatomic,strong)UIImageView* tireForSecond;
@property(nonatomic,strong)UIImageView* engineOilForThird;
@property(nonatomic,strong)UIImageView* toolForThird;
@property(nonatomic,strong)UIImageView* bonnetForThird;
@property(nonatomic,strong)UIImageView* tolietForFourth;
@property(nonatomic,strong)UIImageView* phoneForFourth;
@property(nonatomic,strong)NSTimer* phoneTimer;
@property(nonatomic)int count;
@end

@implementation TNLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mySV.delegate=self;
    self.mySV.showsHorizontalScrollIndicator=NO;
    self.mySV.showsVerticalScrollIndicator=NO;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self setView];
//    self.phoneTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 / FPS target:self selector:@selector(animate) userInfo:nil repeats:YES];
    
}
-(void)animate
{
        self.phoneForFourth.transform=CGAffineTransformMakeRotation(M_PI_4/4*pow(-1, self.count++));
}
- (void)setView
{
    
    self.view.userInteractionEnabled=YES;
    self.mySV=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.mySV.backgroundColor=[UIColor clearColor];
    [self.mySV setContentSize:CGSizeMake(3*self.view.width, 0)];
    self.mySV.delegate=self;
    self.mySV.pagingEnabled=YES;
    self.mySV.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.mySV];
    
//    self.pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(self.view.width/2-71*widthFactor/2, 508*heightFactor,71*widthFactor, 12*heightFactor)];
//    self.pageControl.numberOfPages = 4;
//    self.pageControl.userInteractionEnabled = NO;
//    [self.view addSubview:self.pageControl];
    
    DLog(@"%f",self.view.bounds.size.width);
    
    for (int i=0; i<3; i++)
    {
        
        UIView* view=[[UIView alloc]initWithFrame:CGRectMake(i*self.view.width, 0, self.view.width, self.view.height)];
//        UIImageView* iv=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view.width, view.height)];
//        NSString* imageName=[NSString stringWithFormat:@"启动页%d",i+1];
//        iv.image=[UIImage imageNamed:imageName];
//        [view addSubview:iv];
        
        switch (i) {
            case 0:
            {
//                view .backgroundColor=[UIColor colorWithRed:223.0/255 green:53.0/255 blue:68.0/255 alpha:1.0];
//                6P设计稿尺寸(实际尺寸) iv1(141x63) iv2(288x332) iv3(120x210) iv4(112x255) self.carForFirst(262x91,*x263) pageControl(71x12,*x508)
                
//                UIImageView* iv1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导页1"]];
//                UIImageView* iv2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导页2"]];
//                UIImageView* iv3=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导页3"]];
//                UIImageView* iv4=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导页4"]];
//                if (kHight == 480) {
//                    self.carForFirst=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"1"]];
//
//                }else
               self.carForFirst=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导页1"]];
//                self.carForFirst.contentMode =  UIViewContentModeScaleAspectFit;
                //                UIView* baffleView=[[UIView alloc]initWithFrame:CGRectMake(self.view.width-36*widthFactor,0, 36*widthFactor, self.view.height)];
//                baffleView.backgroundColor=view.backgroundColor;
//                iv1.frame=CGRectMake(109*widthFactor, 55*heightFactor, 141*widthFactor, 63*heightFactor);
//                iv2.frame=CGRectMake(36*widthFactor, 153*heightFactor, 288*widthFactor, 332*heightFactor);
//                iv3.frame=CGRectMake(15*widthFactor, 263*heightFactor, 120*widthFactor, 210*heightFactor);
//                iv4.frame=CGRectMake(109*widthFactor, 255*heightFactor, 32*widthFactor, 27*heightFactor);
//                iv4.alpha=0.5;
//                self.carForFirst.frame=CGRectMake(self.view.width/2-262*widthFactor/2, 263*heightFactor, 262*widthFactor, 91*heightFactor);
                self.carForFirst.frame=CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
//                [view addSubview:iv1];
//                [view addSubview:iv2];
//                [view addSubview:self.carForFirst];
//                [view addSubview:iv3];
//                [view addSubview:iv4];
                [view addSubview:self.carForFirst];
//                CGRect startFrame=self.carForFirst.frame;
//                CGRect endFrame=self.carForFirst.frame;
//                endFrame.origin.x=self.view.width/2-262*widthFactor/2;
//                [UIView animateWithDuration:2 animations:^{
//                    self.carForFirst.frame=endFrame;
//                }];
//                CGRect endFrame2=iv4.frame;
//                endFrame2.origin.y=245*heightFactor;
//                [UIView animateWithDuration:0.8
//                                      delay:0
//                                    options:
//                 UIViewAnimationOptionCurveEaseInOut |
//                 UIViewAnimationOptionRepeat |
//                 UIViewAnimationOptionAutoreverse
//                                 animations:^{
//                                     iv4.frame=endFrame2;
//                                     iv4.alpha=1.0;
//                                 } completion:^(BOOL finished) {
//                                     //动画结束后会执行的代码
//                                 }];

                
            }
                break;
              case 1:
            {
//                6P设计稿尺寸(实际尺寸) iv1(59x65,242x42) iv2(288x332) iv3(120x210) iv4(265x301,10x21) self.tireForSecond(171x352,100x63) pageControl(71x12,*x508)
//               view .backgroundColor=[UIColor colorWithRed:153.0/255 green:184.0/255 blue:49.0/255 alpha:1.0];
//                 UIImageView* iv1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"换轮胎保正品"]];
//                UIImageView* iv2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"启动页AI"]];
//                UIImageView* iv3=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"汽车"]];
//                UIImageView* iv4=[[UIImageView alloc]initWithFrame:CGRectMake(265*widthFactor, 301*heightFactor, 10*widthFactor, 21*heightFactor)];
//                iv4.image=[UIImage animatedImageNamed:@"星星" duration:1];
//                if (kHight == 480) {
//                    self.tireForSecond=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"2"]];
//                    
//                }else
                self.tireForSecond=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"引导页2"]];
//                self.tireForSecond.contentMode =  UIViewContentModeScaleAspectFit;
//                self.tireForSecond.alpha=0;
//                iv1.frame=CGRectMake(59*widthFactor, 65*heightFactor, 242*widthFactor, 42*heightFactor);
//                iv2.frame=CGRectMake(36*widthFactor, 153*heightFactor, 288*widthFactor, 332*heightFactor);
//                iv3.frame=CGRectMake(self.view.width/2-262*widthFactor/2, 263*heightFactor, 262*widthFactor, 91*heightFactor);
                self.tireForSecond.frame=CGRectMake(0, 0, view.frame.size.width,view.frame.size.height);
//                [view addSubview:iv1];
//                [view addSubview:iv2];
//                [view addSubview:iv3];
//                [view addSubview:iv4];
                [view addSubview:self.tireForSecond];
                

            }
                break;
            case 2:
            {
//          self.engineOilForThird（276x255,33x35）self.toolForThird(,119x104) self.bonnetForThird(268x273,36x22)
//                view .backgroundColor=[UIColor colorWithRed:91.0/255 green:157.0/255 blue:207.0/255 alpha:1.0];
//                UIImageView* iv1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"做保养好简单"]];
//                UIImageView* iv2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"启动页AI"]];
//                UIImageView* iv3=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"汽车"]];
                  UIImageView *image  =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height)];
//                image.contentMode =  UIViewContentModeScaleAspectFit;
//                self.engineOilForThird.alpha=0;
//                if (kHight == 480) {
//                    image.image= [UIImage imageNamed:@"3"];
                
//                }else
                image.image=[UIImage imageNamed:@"引导页3"];
//                self.toolForThird=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"工具"]];
//                self.bonnetForThird=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"后盖"]];
//                self.bonnetForThird.layer.anchorPoint=CGPointMake(0, 0);
//                iv1.frame=CGRectMake(59*widthFactor, 65*heightFactor, 242*widthFactor, 42*heightFactor);
//                iv2.frame=CGRectMake(36*widthFactor, 153*heightFactor, 288*widthFactor, 332*heightFactor);
//                iv3.frame=CGRectMake(self.view.width/2-262*widthFactor/2, 263*heightFactor, 262*widthFactor, 91*heightFactor);
//                self.toolForThird.frame=CGRectMake(112*widthFactor, self.view.height, 119*widthFactor, 104*heightFactor);
//                self.bonnetForThird.frame=CGRectMake(self.view.width-87*widthFactor,279*heightFactor, 31*widthFactor, 9*heightFactor);
//                [view addSubview:iv1];
//                [view addSubview:iv2];
//                [view addSubview:iv3];
                [view addSubview:image];
//                [view addSubview:self.toolForThird];
//                [view addSubview:self.bonnetForThird];
            }
                break;
            case 3:
            {
//                view .backgroundColor=[UIColor colorWithRed:58.0/255 green:202.0/255 blue:182.0/255 alpha:1.0];
//                UIImageView* iv1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"5分洗车巨划算"]];
//                UIImageView* iv2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"启动页AI"]];
//                UIImageView* iv3=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"汽车有水渍"]];
//                UIImageView* iv4=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"人物2"]];
//                self.tolietForFourth=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height)];
//                if (kHight == 480) {
//                    self.tolietForFourth=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"4"]];
//                    
//                }else
//                self.tolietForFourth.image=[UIImage imageNamed:@"引导页4"];
//
//                self.phoneForFourth=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"手机五分券"]];
//                self.phoneForFourth.layer.anchorPoint=CGPointMake(0.5, 0);
//                iv1.frame=CGRectMake(self.view.width/2-294/2*widthFactor, 65*heightFactor, 294*widthFactor, 42*heightFactor);
//                iv2.frame=CGRectMake(36*widthFactor, 153*heightFactor, 288*widthFactor, 332*heightFactor);
//                iv3.frame=CGRectMake(self.view.width/2-262*widthFactor/2+10, 263*heightFactor, 262*widthFactor, 108*heightFactor);
//                iv4.frame=CGRectMake(192*widthFactor, 233*heightFactor, 133*widthFactor, 202*heightFactor);
//                self.phoneForFourth.frame=CGRectMake(self.view.width-73*widthFactor, 311*heightFactor,30*widthFactor, 38*heightFactor);
//                [view addSubview:iv1];
//                [view addSubview:iv2];
//                [view addSubview:iv3];
//                [view addSubview:iv4];
//                [view addSubview:self.tolietForFourth];
//                [view addSubview:self.phoneForFourth];
            }
                break;
            default:
                break;
        }
//        if (i<2)
//        {
//            UIButton* skipButton=[[UIButton alloc]initWithFrame:CGRectMake((kWidth/2)-60, self.view.height*((float)45/63), 60, 25)];
//            [skipButton addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
//            [skipButton setTitle:@"跳过>>" forState:UIControlStateNormal];
//            [view addSubview:skipButton];
//        }
        if (i == 2) {
            UIButton* startButton;
//            if (kWidth == 320) {
//                startButton=[[UIButton alloc]initWithFrame:CGRectMake((kWidth/2)-40, self.view.height*43.5/63, 80,27)];
//                startButton.layer.cornerRadius = 5;
//                 startButton.titleLabel.font = [UIFont systemFontOfSize: 12.0];
//
//            }else
//            {
            startButton=[[UIButton alloc]initWithFrame:CGRectMake(kWidth*100/375.0, 540*kHight/667.0, kWidth-(2*kWidth*100/375.0),(kWidth-(2*kWidth*100/375.0))*50/176)];
                startButton.layer.cornerRadius = 10;

//            }
            //50b880//
            [startButton setTitleColor:[[TNAppContext currentContext] getColor:@"#50b880"] forState:UIControlStateNormal];
            
            startButton.alpha = 0.8;
//            startButton.layer.borderColor = [[TNAppContext currentContext] getColor:@"#3F51B5"].CGColor;
//            startButton.layer.borderWidth = 2;
            startButton.backgroundColor = [UIColor whiteColor];
            startButton.titleLabel.font = [UIFont systemFontOfSize: 20];
//            startButton.font = [UIFont systemFontOfSize:20];
            [startButton setTitle:@"马上进入" forState:UIControlStateNormal];
            [startButton addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:startButton];
//            view.userInteractionEnabled=YES;
//            UITapGestureRecognizer* tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startAction)];
//            [view addGestureRecognizer:tapRecognizer];
        }
        
        [self.mySV addSubview:view];
    }
}

-(void)skipAction
{
//    [self.pageControl setCurrentPage:3];
    [self.mySV setContentOffset:CGPointMake(self.view.width*2, 0) animated:YES];
}
-(void)startAction
{
//    [self.phoneTimer invalidate];
    if (![TNAppContext currentContext].user.token) {
            [TNFlowUtil handleMainFlowWillLoadWithCompletion:^{
                TNApplication *app = [TNApplication sharedApplication];
                UITabBarController *tabVc = [TNTabBarController new];
                
                UIViewController *tab1 = [TNFlowUtil navigationControllerWithRootViewController:[ZHSLoginViewController new]];
                tabVc.viewControllers = @[tab1];
                tabVc.delegate = [TNMainTabBarControllerDelegate sharedInstance];
                [app setRootViewController:tabVc animated:YES];
            }];
    }else{

            [TNFlowUtil startMainFlow];

    }
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self.pageControl setCurrentPage:(int)(self.mySV.contentOffset.x/self.view.width)];
//    switch ((int)(self.mySV.contentOffset.x/self.view.width))
//    {
//        case 0:
//        {
//            self.tireForSecond.alpha=0;
//            self.toolForThird.frame=CGRectMake(112*widthFactor, self.view.height, 119*widthFactor, 104*heightFactor);
//            self.engineOilForThird.alpha=0;
//            self.bonnetForThird.transform=CGAffineTransformMakeRotation(0);
            
//            CGRect endFrame=self.carForFirst.frame;
//            endFrame.origin.x=self.view.width/2-262*widthFactor/2;
//            [UIView animateWithDuration:2 animations:^{
//                self.carForFirst.frame=endFrame;
//            }];
//        }
//            break;
//        case 1:
//        {
//            self.carForFirst.frame=CGRectMake(self.view.width+20, 263*heightFactor, 262*widthFactor, 91*heightFactor);
//            self.toolForThird.frame=CGRectMake(112*widthFactor, self.view.height, 119*widthFactor, 104*heightFactor);
//            self.engineOilForThird.alpha=0;
//            self.bonnetForThird.transform=CGAffineTransformMakeRotation(0);
//            
//            [UIView animateWithDuration:2 animations:^{
//                self.tireForSecond.alpha=1.0;
//            }];
//
//        }
//            break;
//        case 2:
//        {
//            self.tireForSecond.alpha=0;
//            self.carForFirst.frame=CGRectMake(self.view.width+20, 263*heightFactor, 262*widthFactor, 91*heightFactor);
//            
//            CGRect endFrame=self.toolForThird.frame;
//            endFrame.origin.y=354*heightFactor;
//            [UIView animateWithDuration:2 animations:^{
//                self.toolForThird.frame=endFrame;
//                self.engineOilForThird.alpha=1.0;
//                self.bonnetForThird.transform=CGAffineTransformMakeRotation(-M_PI_2*0.95);
//            }];
//            self.engineOilForThird.image=[UIImage animatedImageNamed:@"机油" duration:0.2];
//        }
//            break;
//        case 3:
//        {
//            self.tireForSecond.alpha=0;
//            self.carForFirst.frame=CGRectMake(self.view.width+20, 263*heightFactor, 262*widthFactor, 91*heightFactor);
//            self.toolForThird.frame=CGRectMake(112*widthFactor, self.view.height, 119*widthFactor, 104*heightFactor);
//            self.engineOilForThird.alpha=0;
//            self.bonnetForThird.transform=CGAffineTransformMakeRotation(0);
//        }
//            break;
//        default:
//            break;
//    }
}
-(void)dealloc
{
//    [self.phoneTimer invalidate];
}

@end

