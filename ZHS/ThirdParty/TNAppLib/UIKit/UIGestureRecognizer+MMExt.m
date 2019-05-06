//
//  UIGestureRecognizer+MMExt.m
//  Mikoto
//
//  Created by 邢小迪 on 15/4/7.
//  Copyright (c) 2015年 m_mikoto. All rights reserved.
//

#import "UIGestureRecognizer+MMExt.h"
#import <objc/runtime.h>

@implementation UIGestureRecognizer (MMExt)

static char gestureRecognizerBlocksArray;

- (NSArray *)blocksArray
{
    if (!objc_getAssociatedObject(self, &gestureRecognizerBlocksArray))
    {
        objc_setAssociatedObject(self, &gestureRecognizerBlocksArray, [NSMutableArray array], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return [objc_getAssociatedObject(self, &gestureRecognizerBlocksArray) copy];
}

+ (instancetype)addGestureToView:(UIView*)view withGestureBlock:(GestureRecognizerBlock)gestureBlock
{
    UIGestureRecognizer* gesture = [[self alloc] init];
    [gesture addToView:view withGestureBlock:gestureBlock];
    return gesture;
}

+ (instancetype)addGestureToView:(UIView *)view withTarget:(id)target action:(SEL)action
{
    return [[self alloc] initWithTarget:target action:action];
}

- (void)addToView:(UIView*)view withGestureBlock:(GestureRecognizerBlock)gestureBlock
{
    NSMutableArray* blocksArray = objc_getAssociatedObject(self, &gestureRecognizerBlocksArray);
    if (!blocksArray)
    {
        blocksArray = [NSMutableArray array];
        objc_setAssociatedObject(self, &gestureRecognizerBlocksArray, blocksArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [blocksArray addObject:[gestureBlock copy]];
    [self removeTarget:nil action:nil];
    [self addTarget:self action:@selector(blockHandle)];
    [view addGestureRecognizer:self];
}

- (void)blockHandle
{
    @synchronized(self)
    {
        for (GestureRecognizerBlock block in self.blocksArray)
            block(self);
    }
}
@end
