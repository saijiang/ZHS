//
//  UIGestureRecognizer+MMExt.h
//  Mikoto
//
//  Created by 邢小迪 on 15/4/7.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  Add block method for UIGestureRecognizer.
//****************************************************************************************
//

#import <UIKit/UIKit.h>

typedef void (^GestureRecognizerBlock)(UIGestureRecognizer* gestureRecognizer);

@interface UIGestureRecognizer (MMExt)
@property (readonly, nonatomic) NSArray* blocksArray;
/**
 *  Create and return new gesture instance, and the gesture is already added to view.
 *
 *  @param view         The view gesture be added.
 *  @param gestureBlock  Callback block, is ^(UIGestureRecognizer* gestureRecognizer){}. It will be call when gesture responds to user interface.
 *
 *  @return New gesture instance.
 */
+ (instancetype)addGestureToView:(UIView*)view withGestureBlock:(GestureRecognizerBlock)gestureBlock;
/**
 *  Create and return new gesture instance, and the gesture is already added to view.
 *
 *  @param view   The view gesture be added.
 *  @param target An object that is the recipient of action messages sent by the receiver when it recognizes a gesture. nil is not a valid value.
 *  @param action A selector that identifies the method implemented by the target to handle the gesture recognized by the receiver. The action selector must conform to the signature described in the class overview. NULL is not a valid value.
 *
 *  @return New gesture instance.
 */
+ (instancetype)addGestureToView:(UIView*)view withTarget:(id)target action:(SEL)action;
/**
 *  Add the gesture to view, and set callback block.
 *
 *  @param view         The view gesture be added.
 *  @param gestureBlock Callback block, is ^(UIGestureRecognizer* gestureRecognizer){}. It will be call when gesture responds to user interface.
 */
- (void)addToView:(UIView*)view withGestureBlock:(GestureRecognizerBlock)gestureBlock;

@end
