//
//  TNTag.h
//  TNAppLib
//
//  Created by kiri on 2013-10-29.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNBean.h"

extern const CGFloat TNTagAutomaticHeight;

@interface TNTag : NSObject

@property (nonatomic) NSInteger tag;
@property (nonatomic, strong) id data;

+ (id)tagWithTag:(NSInteger)tag data:(id)data;

@end

@interface TNSectionTag : TNTag

@property (nonatomic, strong) NSString *titleForHeader;
@property (nonatomic, strong) NSString *titleForFooter;
@property (nonatomic) CGFloat heightForHeader;
@property (nonatomic) CGFloat heightForFooter;
@property (nonatomic, strong) NSArray *rows;

+ (id)sectionTagWithTag:(NSInteger)tag rows:(NSArray *)rows;

@end

@interface TNRowTag : TNTag

@property (nonatomic) CGFloat height;
@property (nonatomic, strong) NSString *reuseIdentifier;

+ (id)rowTagWithTag:(NSInteger)tag data:(id)data reuseIdentifier:(NSString *)reuseIdentifier;
+ (id)rowTagWithTag:(NSInteger)tag data:(id)data height:(CGFloat)height reuseIdentifier:(NSString *)reuseIdentifier;

+ (NSMutableArray *)rowTagsWithTag:(NSInteger)tag dataList:(NSArray *)dataList height:(CGFloat)height reuseIdentifier:(NSString *)reuseIdentifier;
+ (NSMutableArray *)rowTagsWithTag:(NSInteger)tag section:(CGFloat)section dataList:(NSArray *)dataList height:(CGFloat)height reuseIdentifier:(NSString *)reuseIdentifier;
@end