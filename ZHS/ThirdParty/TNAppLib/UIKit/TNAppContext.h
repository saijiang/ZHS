//
//  TNAppContext.h
//  Tuhu
//
//  Created by DengQiang on 14/10/23.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNUser.h"

@interface TNAppContext : NSObject

@property (nonatomic, strong,nullable) NSArray *cars;
@property (nonatomic, strong,nullable) TNUser *user;
@property (nonatomic, strong,nullable)NSArray* activities;
@property (nonatomic, strong,nullable)NSArray* onsales;
@property(nonatomic,strong,nullable)NSMutableArray *citys;
@property(nonnull,copy,nonatomic)NSString *schoolbagMode;
+ (instancetype _Nullable)currentContext;
+ ( UIImage * _Nullable )thumbnailWithImageWithoutScale:(UIImage * _Nullable)image size:(CGSize)asize;
- (void)logout;

- (void)saveUser;
- (UIColor * _Nullable)getColor:(NSString * _Nullable)hexColor;
- (BOOL)validateMobile:(NSString * _Nullable)mobileNum;
- (NSString * _Nullable)formateDate:(NSString * _Nullable)dateString;
- (CGFloat)heightFordetailText:(NSString * _Nullable)text andWidth:(CGFloat)width andFontOfSize:(CGFloat)size;
- (MMNetwork)returnNetwork;
@end
