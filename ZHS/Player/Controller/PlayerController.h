//
//  PlayerController.h
//  WtyMusicPlayer
//
//  Created by cassiopeia on 16/1/12.
//  Copyright © 2016年 cassiopeia. All rights reserved.
//

#import "MusicModel.h"
#import <AVFoundation/AVFoundation.h>
@class douPlayer;

@interface PlayerController :TNViewController
@property (nonatomic, strong) MusicModel *musicModel;

//@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) douPlayer *Play;

+ (PlayerController *)sharedManager;

@end
