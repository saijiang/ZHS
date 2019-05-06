//
//  ALAssetsLibrary+Singleton.h
//  TTXClient
//
//  Created by kiri on 13-5-28.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (Singleton)

+(id)sharedLibrary;

@end
