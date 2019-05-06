//
//  TNActionSheet.h
//  WeZone
//
//  Created by DengQiang on 14-9-15.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNAlertAction.h"

@interface TNActionSheet : UIView

/**
 *  hasCancel = YES.
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title actions:(NSArray *)actions;

/**
 *  if hasCancel, the cancel action is the last action.
 */
+ (instancetype)actionSheetWithTitle:(NSString *)title actions:(NSArray *)actions hasCancel:(BOOL)hasCancel;

@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) BOOL hasCancel;

@property (nonatomic, strong) UIView *titleView;

- (void)show;
- (void)showInView:(UIView *)view;

- (void)setTitleLabelConfigurationHandler:(void (^)(UILabel *label))titleLabelConfigurationHandler;
- (void)setActionButtonConfigurationHandler:(void (^)(UIButton *button, TNAlertAction *action, NSInteger index))actionButtonConfigurationHandler;

@end
