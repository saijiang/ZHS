//
//  TNAudioService.h
//  WeZone
//
//  Created by kiri on 2013-11-29.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNAudioService : NSObject

+ (void)vibrate;
+ (void)playAlertSoundWithName:(NSString *)name extension:(NSString *)extension;
+ (void)playNewChatMessageSound;

@end