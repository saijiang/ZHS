//
//  UINavigationController+MMExt.h
//  Mikoto
//
//  Created by 邢小迪 on 15/3/24.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//
//****************************************************************************************
//  Notification for navigation action, such as pop. ViewController will recive a notification when navigation pop to it.
//  LAST UPDATE 2015-06-24: Add pop method with userinfo
//****************************************************************************************
//

#import <UIKit/UIKit.h>

@protocol MMNavigationControllerNotificationDelegate <NSObject>
@optional
- (BOOL)viewControllerWillShowWithPop:(NSArray *)viewControllers;
- (void)viewControllerDidShowWithPop:(NSArray *)viewControllers;
@end


@interface UINavigationController (MMExt)
/**
 *  Use to pass infomation between view controllers when pop, you can get it in MMNavigationControllerNotificationDelegate methods with self.navigationController.userinfo. You can assign this vaule in pop methods and it will be set to nil after -[viewControllerDidShowWithPop:] method done.
 */
@property (readonly, nonatomic) id     userinfo;

/**
 *  Search latest view controller of target class pushed in the navigation stack.
 *
 *  @param targetClass The class of view controller to searched
 *
 *  @return Latest viewController of target class pushed in the navigation stack, or nil if not found.
 */
- (id)getTopViewControllerOfClass:(Class)targetClass;
/**
 *  Pops view controllers until the view controller of target class is at the top of the navigation stack.
 *
 *  @param targetClass The class of view controller that you want to be at the top of the stack. Method will do nothing if all view controller isnt kind of this class.
 *  @param animated    Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 *
 *  @return An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)poptoTargetViewControllerOfClass:(Class)targetClass animated:(BOOL)animated;
/**
 *  Pops view controllers until the view controller isn't kind of the target class that at the top of the navigation stack.
 *
 *  @param passClass The class of view controllers that you want to be poped from the stack while they are the top of the navigation stack.
 *  @param animated  Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 *
 *  @return An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)popPassViewControllerClass:(Class)passClass animated:(BOOL)animated;
/**
 *  Pops view controllers until the view controller isn't kind of the target classes that at the top of the navigation stack.
 *
 *  @param passClasses The classes of view controllers that you want to be poped from the stack while they are the top of the navigation stack. NSString of classes in this array.
 *  @param animated    Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 *
 *  @return An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)popPassViewControllerClasses:(NSArray*)passClasses animated:(BOOL)animated;

#pragma mark pop methods with userInfo
/**
 *  Pops the top view controller from the navigation stack and updates the display.
 *
 *  @param animated    Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 *  @param userinfo     Infomation pass to view controller in stack, they can get it in MMNavigationControllerNotificationDelegate methods. 
 *
 *  @return The view controller that was popped from the stack.
 */
- (UIViewController *)popViewControllerAnimated:(BOOL)animated withUserinfo:(id)userinfo;
/**
 *  Pops view controllers until the specified view controller is at the top of the navigation stack. For information on how the navigation bar is updated, see Updating the Navigation Bar.
 *
 *  @param viewController The view controller that you want to be at the top of the stack. This view controller must currently be on the navigation stack.
 *  @param animated    Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 *  @param userinfo     Infomation pass to view controller in stack, they can get it in MMNavigationControllerNotificationDelegate methods.
 *
 *  @return An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated withUserinfo:(id)userinfo;
/**
 *  Pops all the view controllers on the stack except the root view controller and updates the display. The root view controller becomes the top view controller. For information on how the navigation bar is updated, see Updating the Navigation Bar.
 *
 *  @param animated Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 *  @param userinfo     Infomation pass to view controller in stack, they can get it in MMNavigationControllerNotificationDelegate methods.
 *
 *  @return An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated withUserinfo:(id)userinfo;
/**
 *  Pops view controllers until the view controller of target class is at the top of the navigation stack.
 *
 *  @param targetClass The class of view controller that you want to be at the top of the stack. Method will do nothing if all view controller isnt kind of this class.
 *  @param animated    Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 *  @param userinfo     Infomation pass to view controller in stack, they can get it in MMNavigationControllerNotificationDelegate methods.
 *
 *  @return An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)poptoTargetViewControllerOfClass:(Class)targetClass animated:(BOOL)animated withUserinfo:(id)userinfo;
/**
 *  Pops view controllers until the view controller isn't kind of the target class that at the top of the navigation stack.
 *
 *  @param passClass The class of view controllers that you want to be poped from the stack while they are the top of the navigation stack.
 *  @param animated  Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 *  @param userinfo     Infomation pass to view controller in stack, they can get it in MMNavigationControllerNotificationDelegate methods.
 *
 *  @return An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)popPassViewControllerClass:(Class)passClass animated:(BOOL)animated withUserinfo:(id)userinfo;
/**
 *  Pops view controllers until the view controller isn't kind of the target classes that at the top of the navigation stack.
 *
 *  @param passClasses The classes of view controllers that you want to be poped from the stack while they are the top of the navigation stack. NSString of classes in this array.
 *  @param animated    Set this value to YES to animate the transition. Pass NO if you are setting up a navigation controller before its view is displayed.
 *  @param userinfo     Infomation pass to view controller in stack, they can get it in MMNavigationControllerNotificationDelegate methods.
 *
 *  @return An array containing the view controllers that were popped from the stack.
 */
- (NSArray *)popPassViewControllerClasses:(NSArray *)passClasses animated:(BOOL)animated withUserinfo:(id)userinfo;

@end
