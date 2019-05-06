//
//  TNAudioService.m
//  WeZone
//
//  Created by kiri on 2013-11-29.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNAudioService.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation TNAudioService

+ (void)vibrate
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

void AudioServicesSystemSoundCompletionCallback(SystemSoundID soundID,void *clientData)
{
    *(BOOL *)clientData = NO;
    AudioServicesRemoveSystemSoundCompletion(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
}

+ (void)playAlertSoundWithName:(NSString *)name extension:(NSString *)extension
{
    static BOOL playing = NO;
    if (playing) {
        return;
    }
    
    playing = YES;
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:name withExtension:extension];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
    
    if (soundID == 0) {
        playing = NO;
        return;
    }
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, AudioServicesSystemSoundCompletionCallback, &playing);
    AudioServicesPlayAlertSound(soundID);
    
    // protect
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        playing = NO;
    });
}

+ (void)playNewChatMessageSound
{
    [self playAlertSoundWithName:@"NewChatMessage" extension:@"aiff"];
//    [self vibrate];
}

@end