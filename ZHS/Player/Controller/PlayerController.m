//
//  PlayerController.m
//  WtyMusicPlayer
//
//  Created by cassiopeia on 16/1/12.
//  Copyright © 2016年 cassiopeia. All rights reserved.
//

#import "PlayerController.h"
#import "UIImageView+WebCache.h"

// view
#import "WtyView.h"
#import "PlayerFooterView.h"
#import "PlayerHeaderView.h"
#import "UIImage+GIF.h"
#import "douPlayer.h"
// tool

#define RADIUS 115
#define ICONWIDTH 170
#define ALLANGLE 350

@interface PlayerController ()

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *mp3Url;
@property (nonatomic, strong) PlayerFooterView *playerFooter;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) PlayerHeaderView *headerView;
@property (nonatomic, assign) NSInteger angle;
@property(nonatomic,strong)UIButton *backBTN;
@property(nonatomic,strong) UILabel *navigationBarTitleLable;

@end

@implementation PlayerController

#pragma mark - 创建单例对象
+ (PlayerController *)sharedManager
{
    static PlayerController *player = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        player = [[self alloc] init];
    });
    return player;
}

- (void)viewWillAppear:(BOOL)animated
{
    

    self.navigationController.navigationBarHidden = YES;
    _navigationBarTitleLable.text = self.musicModel.name;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _Play = [[douPlayer alloc] init];
    [self PlayerControl];
    self.angle = 0;
//    [self createLeftBarItemWithImage];
    [self createPlayer];
    [self createUI];
    [self creatTitleView];

    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sliderClick:) name:@"点击进度条" object:nil];

}

#pragma mark - 进度条点击通知
- (void)sliderClick:(NSNotification *)noti
{
    
}



- (void)setMusicModel:(MusicModel *)musicModel
{
    _musicModel = musicModel;
    
    if (self.mp3Url != nil && ![_musicModel.mp3Url isEqualToString:self.mp3Url]) {
//        [self.wtyView removeFromSuperview];
        [_Play stop];
        [self createPlayer];
        [self createSingImage];
        [self createFooterView];
        _navigationBarTitleLable.text = self.musicModel.name;
        self.angle = 0;

    }
}

#pragma mark - 创建头部的控件
-(void)creatTitleView{
    
    _backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBTN.frame = CGRectMake(20, 12, 30, 30);
    UIImage *image =[UIImage imageNamed:@"common_back"];
    [_backBTN addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_backBTN setBackgroundImage:image forState:UIControlStateNormal] ;
    
    
    _navigationBarTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(kWidth/2-100, 7, 200, 30)];
    _navigationBarTitleLable.textColor = [UIColor whiteColor];
    _navigationBarTitleLable.font = [UIFont boldSystemFontOfSize:20.0f];
    _navigationBarTitleLable.textAlignment = NSTextAlignmentCenter;
    _navigationBarTitleLable.backgroundColor = [UIColor clearColor];
    
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, kWidth, 44)];
    
    customView.backgroundColor = [UIColor clearColor];
    [customView addSubview:_backBTN];
    [customView addSubview:_navigationBarTitleLable];
    [self.backgroundImage addSubview:customView];
}

#pragma mark - 创建音乐播放器
- (void)createPlayer
{
    NSString *mp3name = self.musicModel.mp3Url;
    if ( ([mp3name hasPrefix:@"http://"]) && !([mp3name hasPrefix:@"https://"]) ) {
        _Play.track.audioFileURL = [NSURL URLWithString:mp3name];
        [_Play play];
    }

    self.mp3Url = self.musicModel.mp3Url;

}

- (void)PlayerControl{
    __weak typeof(self) weakSelf = self;
    __weak typeof(douPlayer *) weakDouPLayer = _Play;
    
    if ([_Play isPlaying]) {
        [weakSelf.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-bofang"] forState:UIControlStateNormal];
    }
    else{
        [weakSelf.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-bofang"] forState:UIControlStateNormal];
    }
    
    [_Play setStatusBlock:^(DOUAudioStreamer *streamer) {
        switch ([streamer status]) {
            case DOUAudioStreamerPlaying:
                [weakSelf.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-zanting"] forState:UIControlStateNormal];
                [weakSelf startAnimation];

                break;
                
            case DOUAudioStreamerPaused:
                [weakSelf.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-bofang"] forState:UIControlStateNormal];
                break;
                
            case DOUAudioStreamerIdle:
                [weakSelf.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-bofang"] forState:UIControlStateNormal];
                [weakDouPLayer stop];
                break;
                
            case DOUAudioStreamerFinished:
                [weakSelf.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-bofang"] forState:UIControlStateNormal];
                [weakDouPLayer stop];
                break;
                
            case DOUAudioStreamerBuffering:
//                weakSelf.playInfoLbl.text = @"Buffering";
                break;
                
            case DOUAudioStreamerError:
                [weakSelf.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-bofang"] forState:UIControlStateNormal];
//                [weakSelf.playSlider setValue:0.0f animated:NO];
                [weakDouPLayer stop];
//                weakSelf.playInfoLbl.text = @"net error";
                break;
        }
    }];
    
    [_Play setDurationBlock:^(DOUAudioStreamer *streamer) {
        weakSelf.playerFooter.timeLabel.text = [NSString stringWithFormat:@"%d:%.2d/%d:%.2d",(int)[streamer currentTime]/60,(int)[streamer currentTime]%60,(int)[streamer duration]/60,(int)[streamer duration]%60];

//    if ([streamer duration] == 0.0) {
//        weakSelf.playerFooter.timeLabel.text = [NSString stringWithFormat:@"%d:%.2d/%d:%.2d",(int)[streamer duration]/60,(int)[streamer duration]%60,(int)[streamer duration]/60,(int)[streamer duration]%60];
//    }else {
//        weakSelf.playerFooter.timeLabel.text = [NSString stringWithFormat:@"%d:%.2d/%d:%.2d",(int)[streamer currentTime]/60,(int)[streamer currentTime]%60,(int)[streamer duration]/60,(int)[streamer duration]%60];
//    }
    }];

}
- (void)createUI
{
    
//     背景
    self.backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImage.userInteractionEnabled = YES;
    [self.view addSubview:self.backgroundImage];
    [self createSingImage];
    [self createFooterView];
    
}


- (void)createSingImage
{
    if (self.icon == nil) {
        
        UIImageView *panIV = [[UIImageView alloc]initWithFrame:CGRectMake((kWidth-ICONWIDTH-100)/2,(kHight-ICONWIDTH-100-64)/2 , ICONWIDTH+100, ICONWIDTH+100)];;
        panIV.image = [UIImage imageNamed:@"wangyiM"];
        [self.view addSubview:panIV];
        
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake((kWidth-ICONWIDTH)/2,(kHight-ICONWIDTH-64)/2 , ICONWIDTH, ICONWIDTH)];
//        self.icon.center = self.view.center;
        self.icon.layer.cornerRadius = ICONWIDTH / 2;
        self.icon.layer.borderWidth = 3;
        self.icon.layer.borderColor = [[[TNAppContext currentContext] getColor:@"#ffffff"] CGColor];
        self.icon.clipsToBounds = YES;
        [self.view addSubview:self.icon];
        
    }
    
    [self.icon sd_setImageWithURL:[NSURL URLWithString:self.musicModel.picUrl] placeholderImage:nil];
//    self.backgroundImage.image = [UIImage getSubImage:self.icon.image mCGRect:CGRectMake(0, 0, 2, 2) centerBool:YES];
    self.backgroundImage.clipsToBounds = YES;
    self.backgroundImage.contentMode=UIViewContentModeScaleAspectFill;
    self.backgroundImage.image = [UIImage blurryImage:self.icon.image withBlurLevel:0.8];

    
}



- (void)startAnimation
{
    __weak __block PlayerController *play = self;
    [UIView animateWithDuration:5.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        play.icon.transform = CGAffineTransformMakeRotation(play.angle);
    } completion:^(BOOL finished) {
        play.angle += 90;
        if (_Play.isPlaying) {
            [play startAnimation];
        }
    }];
}



#pragma mark - 尾部控件
- (void)createFooterView
{
    CGFloat footerX = 0;
    CGFloat footerH = 100;
    CGFloat footerW = kWidth;
    CGFloat footerY = kHight - footerH-64;
    if (self.playerFooter == nil) {
        self.playerFooter = [[[NSBundle mainBundle] loadNibNamed:@"PlayerFooterView" owner:nil options:nil] lastObject];
        self.playerFooter.backgroundColor = [UIColor clearColor];
        self.playerFooter.frame = CGRectMake(footerX, footerY, footerW, footerH+40);
        [self.view addSubview:self.playerFooter];
    }

    if (_Play.isPlaying) {
        [self.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-zanting"] forState:UIControlStateNormal];
    } else
    {
        [self.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-bofang"] forState:UIControlStateNormal];
    }
    __weak douPlayer *dPlay = _Play;
    __weak typeof(self)tempSelf = self;
    // 点击暂停/开始
    [self.playerFooter setPauseButtonBlock:^(void){
        if (dPlay.isPlaying) {
            [dPlay pause];
            [tempSelf.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-bofang"] forState:UIControlStateNormal];

        } else {
            [dPlay play];
            [tempSelf startAnimation];
            [tempSelf.playerFooter.pauseButton setBackgroundImage:[UIImage imageNamed:@"iconfont-zanting"] forState:UIControlStateNormal];
        }
        
    }];
    
}



- (void)createBackgroundImage
{
    // 在子线程下载图片
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.musicModel.picUrl]];
        
        self.image = [UIImage imageWithData:data];
        
        // 主线程显示
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.backgroundImage == nil) {
                self.backgroundImage = [[UIImageView alloc] init];
                self.backgroundImage.frame = self.view.bounds;
                self.backgroundImage.image = self.image;
                
//                [self.view addSubview:self.backgroundImage];
                
                self.backgroundImage.alpha = 0;
                [UIView animateWithDuration:2 animations:^{
                    self.backgroundImage.alpha = 1;
                }];
                
                [self.view insertSubview:self.backgroundImage atIndex:0];
            }
            else
            {
                self.backgroundImage.image = self.image;
                self.backgroundImage.alpha = 0;
                [UIView animateWithDuration:2 animations:^{
                    self.backgroundImage.alpha = 1;
                }];
            
            }
            
        });
        
    });
    
    
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageStr]];
//        
//        
//        GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
//        blurFilter.blurRadiusInPixels = 10.0;
//        UIImage *image = [UIImage imageWithData:data];
//        self.image = image;
//        UIImage *blurredImage = [blurFilter imageByFilteringImage:image];
//        self.coverImageObject = blurredImage;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self.backgroundImageView == nil) {
//                
//                self.backgroundImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
//                [self.view addSubview:self.backgroundImageView];
//                self.backgroundImageView.image = blurredImage;
//                self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
//                self.backgroundImageView.clipsToBounds = YES;
//                
//                self.backgroundImageView.alpha = 0;
//                [UIView animateWithDuration:2 animations:^{
//                    self.backgroundImageView.alpha = 1;
//                }];
//                
//                self.blockView = [[UIView alloc]initWithFrame:self.backgroundImageView.bounds];
//                [self.backgroundImageView addSubview:self.blockView];
//                self.blockView.backgroundColor = [UIColor whiteColor];
//                self.blockView.alpha = 0.4;
//                
//                [self.view sendSubviewToBack:self.backgroundImageView];
//            }else{
//                self.backgroundImageView.image = blurredImage;
//                self.backgroundImageView.alpha = 0;
//                [UIView animateWithDuration:2 animations:^{
//                    self.backgroundImageView.alpha = 1;
//                }];
//            }
//        });
//    });

}




-(void)back{
    [[NSUserDefaults standardUserDefaults] setBool:_Play.isPlaying forKey:@"isPlaying"];
    [self.navigationController popViewControllerAnimated:YES withUserinfo:@(_Play.isPlaying
     )];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"显示音符" object:nil];

}
@end
