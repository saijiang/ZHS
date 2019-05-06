//
//  TNBlockActionSheet.m
//  TNAppLib
//
//  Created by kiri on 2013-10-17.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNBlockActionSheet.h"

@interface TNBlockActionSheet () <UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableDictionary *buttonBlocks;
@property (nonatomic, weak) id<UIActionSheetDelegate> otherDelegate;

@end

@implementation TNBlockActionSheet

- (TNActionSheetBlock)blockAtButtonIndex:(NSInteger)buttonIndex
{
    return [self.buttonBlocks objectForKey:[NSNumber numberWithInteger:buttonIndex]];
}

- (void)setBlock:(TNActionSheetBlock)block atButtonIndex:(NSInteger)buttonIndex
{
    if (!self.buttonBlocks) {
        self.buttonBlocks = [NSMutableDictionary dictionary];
    }
    
    if (block) {
        TNActionSheetBlock temp = [block copy];
        [self.buttonBlocks setObject:temp forKey:[NSNumber numberWithInteger:buttonIndex]];
    }
}

- (void)prepareForShow
{
    self.otherDelegate = self.delegate == self ? nil : self.delegate;
    self.delegate = self;
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    [self prepareForShow];
    [super showFromBarButtonItem:item animated:animated];
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
    [self prepareForShow];
    [super showFromRect:rect inView:view animated:animated];
}

- (void)showFromTabBar:(UITabBar *)view
{
    [self prepareForShow];
    [super showFromTabBar:view];
}

- (void)showFromToolbar:(UIToolbar *)view
{
    [self prepareForShow];
    [super showFromToolbar:view];
}

- (void)showInView:(UIView *)view
{
    [self prepareForShow];
    [super showInView:view];
}


// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TNActionSheetBlock block = [self blockAtButtonIndex:buttonIndex];
    if (block) {
        __weak __typeof(actionSheet) weakActionSheet = actionSheet;
        block(weakActionSheet, buttonIndex);
    }
    
    if ([self.otherDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.otherDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if ([self.otherDelegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.otherDelegate willPresentActionSheet:actionSheet];
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    if ([self.otherDelegate respondsToSelector:@selector(didPresentActionSheet:)]) {
        [self.otherDelegate didPresentActionSheet:actionSheet];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.otherDelegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
        [self.otherDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.otherDelegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
        [self.otherDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
    }
}

@end
