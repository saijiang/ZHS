//
//  TNBlockAlertView.m
//  TNAppLib
//
//  Created by kiri on 2013-10-16.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNBlockAlertView.h"

@interface TNBlockAlertView ()  <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *buttonBlocks;
@property (nonatomic, weak) id<UIAlertViewDelegate> otherDelegate;

@end

@implementation TNBlockAlertView

-(void)show
{
    self.otherDelegate = self.delegate;
    self.delegate = self;
    [super show];
}

- (void)setBlockForOk:(TNAlertViewBlock)blockForOk
{
    [self setBlock:blockForOk atButtonIndex:1];
}

- (TNAlertViewBlock)blockForOk
{
    return [[self buttonBlocks] objectForKey:@1];
}

- (void)setBlockForCancel:(TNAlertViewBlock)blockForCancel
{
    [self setBlock:blockForCancel atButtonIndex:0];
}

- (TNAlertViewBlock)blockForCancel
{
    return [self.buttonBlocks objectForKey:@0];
}

- (void)setBlock:(TNAlertViewBlock)block atButtonIndex:(NSInteger)buttonIndex
{
    if (!self.buttonBlocks) {
        self.buttonBlocks = [NSMutableDictionary dictionary];
    }
    
    if (block) {
        TNAlertViewBlock temp = [block copy];
        [self.buttonBlocks setObject:temp forKey:[NSNumber numberWithInteger:buttonIndex]];
    }
}

- (TNAlertViewBlock)blockAtButtonIndex:(NSInteger)buttonIndex
{
    return [self.buttonBlocks objectForKey:[NSNumber numberWithInteger:buttonIndex]];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TNAlertViewBlock block = [self blockAtButtonIndex:buttonIndex];
    if (block) {
        block();
    }
    
    if ([self.otherDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.otherDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if ([self.otherDelegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.otherDelegate willPresentAlertView:alertView];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if ([self.otherDelegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [self.otherDelegate didPresentAlertView:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.otherDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [self.otherDelegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.otherDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
        [self.otherDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
}

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if ([self.otherDelegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]) {
        return [self.otherDelegate alertViewShouldEnableFirstOtherButton:alertView];
    }
    return YES;
}

@end
