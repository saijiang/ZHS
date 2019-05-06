//
//  NSFileManager+TNAppLib.h
//  TNAppLib
//
//  Created by kiri on 2013-11-11.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (TNAppLib)

+ (NSURL *)applicationDocumentsDirectory;
+ (NSURL *)applicationCachesDirectory;

+ (NSURL *)applicationPrivateDirectory;

@end
