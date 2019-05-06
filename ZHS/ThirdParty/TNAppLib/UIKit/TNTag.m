//
//  TNTag.m
//  TNAppLib
//
//  Created by kiri on 2013-10-29.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNTag.h"
#import "NSObject+Automatic.h"

const CGFloat TNTagAutomaticHeight = -2.0f;

@implementation TNTag

+ (id)tagWithTag:(NSInteger)tag data:(id)data
{
    TNTag *obj = [self new];
    [obj setTag:tag];
    [obj setData:data];
    return obj;
}

@end

@implementation TNSectionTag

+ (id)sectionTagWithTag:(NSInteger)tag rows:(NSArray *)rows
{
    id obj = [self tagWithTag:tag data:nil];
    [obj setRows:rows];
    [obj setHeightForHeader:TNTagAutomaticHeight];
    [obj setHeightForFooter:TNTagAutomaticHeight];
    return obj;
}

@end

@implementation TNRowTag

+ (id)rowTagWithTag:(NSInteger)tag data:(id)data reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self rowTagWithTag:tag data:data height:TNTagAutomaticHeight reuseIdentifier:reuseIdentifier];
}

+ (id)rowTagWithTag:(NSInteger)tag data:(id)data height:(CGFloat)height reuseIdentifier:(NSString *)reuseIdentifier
{
    id obj = [self tagWithTag:tag data:data];
    [obj setReuseIdentifier:reuseIdentifier];
    [obj setHeight:height];
    return obj;
}
+ (NSMutableArray *)rowTagsWithTag:(NSInteger)tag dataList:(NSArray *)dataList height:(CGFloat)height reuseIdentifier:(NSString *)reuseIdentifier
{
    NSMutableArray *array = [NSMutableArray array];
    for (id data in dataList) {
        [array addObject:[TNRowTag rowTagWithTag:tag data:data height:height reuseIdentifier:reuseIdentifier]];
    }
    return array;
}
+ (NSMutableArray *)rowTagsWithTag:(NSInteger)tag section:(CGFloat)section dataList:(NSArray *)dataList height:(CGFloat)height reuseIdentifier:(NSString *)reuseIdentifier
{
    NSMutableArray *array = [NSMutableArray array];
    for (id data in dataList) {
        
        [array addObject:[TNRowTag rowTagWithTag:10000 data:nil height:section reuseIdentifier:@"TNSeperatorCell"]];
        [array addObject:[TNRowTag rowTagWithTag:tag data:data height:height reuseIdentifier:reuseIdentifier]];
    }
    return array;
}
@end