//
//  TNViewController.h
//  WeZone
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNActionSheet.h"

@interface TNViewController : UIViewController

@property (nonatomic, getter = isNavigationBarHidden) BOOL navigationBarHidden;
@property (nonatomic, getter = isTabBarHidden) BOOL tabBarHidden;
@property (nonatomic, strong) UIColor *navbarColor;
@property (nonatomic) BOOL navigationBarBottomLineHidden;

- (void)prepareForLeftSidebar;
- (BOOL)isViewAppeared;
- (IBAction)backButtonDidClick:(id)sender;
- (IBAction)homeButtonDidClick:(id)sender;
- (IBAction)leftSidebarButtonDidClick:(id)sender;
- (IBAction)rightSidebarButtonDidClick:(id)sender;

- (BOOL)useGlobalBackground;

/*!
 *  common for storyboard. used for viewDidLoad or prepareForSegue:.
 */
- (void)configureView;

- (void)viewDidFirstAppear:(BOOL)animated;

- (void)showActionSheet:(TNActionSheet *)actionSheet;

#pragma mark - UITextField & UITextView
@property (nonatomic) BOOL observeKeyboardChangeFrameNotification;
- (void)keyboardWillChangeFrame:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)keyboardWillShow:(NSNotification *)notification;
- (UIScrollView *)scrollViewForTextInputView:(UIView *)textInputView;

- (void)textViewDidBeginEditing:(UITextView *)textView;
- (void)textFieldDidBeginEditing:(UITextField *)textField;

-(void)createLeftBarItemWithTitle:(NSString *)title;
-(void)createLeftBarItemWithImage;
-(void)createRightBarItemWithTitle:(NSString *)title;
-(void)createRightBarItemWithTitle:(NSString *)title font:(CGFloat)fontSize;
-(void)createRightBarItemWithImage:(NSString *)imageName;
-(void)clickRightSender:(UIButton *)sender;
-(void)back;
+ (UIImage *)drawImage:(CGSize)imageSize setColor:(UIColor *)color;

-(void)initView;
-(void)initData;
- (void)reclaimedKeyboard;

@end