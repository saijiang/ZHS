//
//  TNImagePreviewManager.h
//  TTXClient
//
//  Created by Mr.Wang(Wang Zhao) on 13-9-4.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNImageListView.h"

#define NOTIFICATION_START_SHOW_IMAGES @"NOTIFICATION_START_SHOW_IMAGES"
#define NOTIFICATION_END_SHOW_IMAGES @"NOTIFICATION_END_SHOW_IMAGES"

@interface TNImagePreviewManager : NSObject <TNImageListViewDelegate>

+ (TNImagePreviewManager *)defaultManager;

- (void)showImages:(NSArray *)imageList placeholderImage:(UIImage *)placeholderImage atIndex:(NSInteger)index fromViewList:(NSArray *)viewList;

@end
