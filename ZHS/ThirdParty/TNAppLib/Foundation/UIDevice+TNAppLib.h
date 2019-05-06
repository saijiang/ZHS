//
//  UIDevice+TNAppLib.h
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (TNAppLib)

- (int)majorSystemVersion;
- (NSString *)carrierName;
- (NSString *)macAddress;
- (NSString *)fullModel;
- (NSString *)machineName;
+ (BOOL)isIphone4;
+ (BOOL)isIphone5;
+ (BOOL)isIphone6;
+ (BOOL)isIphone6P;
@end
