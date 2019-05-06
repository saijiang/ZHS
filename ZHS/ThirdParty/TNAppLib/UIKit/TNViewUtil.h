//
//  TNViewUtil.h
//  TNAppLib
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNViewUtil : NSObject

+ (UIView *)snapshotViewForView:(UIView *)srcView afterScreenUpdates:(BOOL)afterUpdates;
+ (UIImage *)snapshotForView:(UIView *)srcView afterScreenUpdates:(BOOL)afterUpdates;

+ (CGFloat)heightWithLabel:(UILabel *)label;

+ (CGSize)sizeWithLabel:(UILabel *)label maxWidth:(CGFloat)maxWidth;

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth;

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth maxLine:(NSInteger)maxLine;

+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxWidth:(CGFloat)maxWidth maxLine:(NSInteger)maxLine lineBreakMode:(NSLineBreakMode)lineBreakMode;

+ (CGSize)sizeWithAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth;

+ (CGSize)sizeWithAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth maxLine:(NSInteger)maxLine;

+ (CGSize)sizeWithAttributedString:(NSAttributedString *)attributedString maxWidth:(CGFloat)maxWidth maxLine:(NSInteger)maxLine lineBreakMode:(NSLineBreakMode)lineBreakMode;

+ (void)heightWithHtmlString:(NSString *)htmlString baseURL:(NSURL *)baseURL maxWidth:(CGFloat)maxWidth completion:(void (^)(CGFloat height))completion;

/*!
 * Prepare UI according to dynamic label.
 * We will re-calculate y for the UIViews below the label.
 * Meanwhile, we will re-calculate height for the containers who contains the lable.
 */
+ (void)prepareDynamicLabel:(UILabel *)label withBelowUIView:(NSArray *)belowUIViews withContainers:(NSArray *)containers;

/*!
 * Prepare UI according to dynamic label.
 * We will re-calculate y for the UIViews below the label.
 * Meanwhile, we will re-calculate height for the containers who contains the lable.
 *
 * NOTE: the max line is limited.
 */
+ (void)prepareDynamicLabel:(UILabel *)label withBelowUIView:(NSArray *)belowUIViews withContainers:(NSArray *)containers maxLine:(int)maxLine;

/*!
 * Prepare UI according to dynamic label.
 * All it's right side views will be adjusted according to label's real length.
 */
+ (void)prepareDynamicLabel:(UILabel *)label withRightUIView:(NSArray *)rightUIViews;

/*!
 * calculate number of lines
 */
+ (NSInteger)calculateNumberOfLinesWithString:(NSString *)string font:(UIFont *)font width:(CGFloat)width;

/*!
 * Justify the badge view with label.text.
 *
 *  @param referenceX The baseline for justifing.
 *  @param alignment Only support for NSTextAlignmentLeft, NSTextAlignmentCenter, NSTextAlignmentRight. It decides how to use the referenceX.
 *  @param maxWidth The maximium width of backgroundView can reached to.
 *  @param backgroundView The badge backgroundView, often be an image view.
 *  @param label The badge label, justification is base on its text.
 */
+ (void)justifyBadgeViewWithBaseline:(CGFloat)referenceX alignment:(NSTextAlignment)alignment maxWidth:(CGFloat)maxWidth backgroundView:(UIView *)backgroundView label:(UILabel *)label;
+ (void)justifyBadgeViewWithBaseline:(CGFloat)referenceX alignment:(NSTextAlignment)alignment maxWidth:(CGFloat)maxWidth containerView:(UIView *)containerView label:(UILabel *)label;

+ (UIEdgeInsets)justifiedWebViewContentInset;
+ (UIEdgeInsets)justifiedTextViewContentInset;

+ (void)setTitle:(NSString *)title forButton:(UIButton *)button;

#pragma mark - Animation
+ (void)animateWithAnimations:(void (^)(void))animations;
+ (void)animateWithAnimations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

#pragma mark - Mask
+ (void)setUserMaskLayerWithView:(UIView *)view;
+ (void)setMaskLayerWithImage:(UIImage *)image forView:(UIView *)view;
+ (void)setMaskLayerWithImage:(UIImage *)image forView:(UIView *)view replaceCurrentMask:(BOOL)replaceCurrentMask;


#pragma mark - TableView
+ (void)hideFooterSeperatorWithTableView:(UITableView *)tableView;

@end