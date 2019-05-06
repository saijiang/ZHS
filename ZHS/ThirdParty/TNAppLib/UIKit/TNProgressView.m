//
//  TNProgressView.m
//  FitTime
//
//  Created by DengQiang on 14-5-28.
//  Copyright (c) 2014年 telenav. All rights reserved.
//

#import "TNProgressView.h"
#import "NSTimer+Block.h"
#import <CoreGraphics/CoreGraphics.h>
#import <math.h>

@interface TNProgressView ()

@property (nonatomic, weak) NSTimer *animationTimer;

@end

@implementation TNProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self privateInitialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self privateInitialize];
}

- (void)privateInitialize
{
    self.progress = 0.f;
    self.progressTintColor = [UIColor blackColor];
    self.trackTintColor = [UIColor clearColor];
    [self registerForKVO];
}

- (void)dealloc
{
    [self unregisterFromKVO];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGPoint c1 = CGPointMake(h / 2, h / 2);
    CGPoint c2 = CGPointMake(w - h / 2, h / 2);
    
//    CGFloat r1 = h / 2;
    CGFloat r2 = h / 2 - 2;
    
//    UIBezierPath *borderPath = [UIBezierPath bezierPath];
//    [borderPath moveToPoint:CGPointMake(c1.x, 0)];
//    [borderPath addLineToPoint:CGPointMake(c2.x, 0)];
//    [borderPath addArcWithCenter:c2 radius:r1 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];
//    [borderPath addLineToPoint:CGPointMake(c1.x, h)];
//    [borderPath addArcWithCenter:c1 radius:r1 startAngle:M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
//    borderPath.lineCapStyle = kCGLineCapButt;
//    borderPath.lineWidth = 1.f;
//    [self.progressTintColor set];
//    [borderPath stroke];
    
    CGFloat endX = 2 + (w - 4) * self.progress;
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    if (endX < c1.x) {
        CGFloat cos = (c1.x - endX) / r2;
        CGFloat angle = acosf(cos);
        [progressPath addArcWithCenter:c1 radius:r2 startAngle:M_PI - angle endAngle:M_PI + angle clockwise:YES];
    } else if (endX <= c2.x) {
        [progressPath moveToPoint:CGPointMake(c1.x, 2)];
        [progressPath addLineToPoint:CGPointMake(endX, 2)];
        [progressPath addLineToPoint:CGPointMake(endX, h - 2)];
        [progressPath addLineToPoint:CGPointMake(c1.x, h - 2)];
        [progressPath addArcWithCenter:c1 radius:r2 startAngle:M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
    } else {
        CGFloat cos = (endX - c2.x) / r2;
        CGFloat angle = acosf(cos);
        [progressPath addArcWithCenter:c2 radius:r2 startAngle:angle endAngle:M_PI_2 clockwise:YES];
        [progressPath addLineToPoint:CGPointMake(c1.x, h - 2)];
        [progressPath addArcWithCenter:c1 radius:r2 startAngle:M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
        [progressPath addLineToPoint:CGPointMake(c2.x, 2)];
        [progressPath addArcWithCenter:c2 radius:r2 startAngle:-M_PI_2 endAngle:-angle clockwise:YES];
    }
    [progressPath closePath];
    [self.progressTintColor set];
    progressPath.lineWidth = 0.f;
    [progressPath fill];
}

#pragma mark - KVO
- (void)registerForKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)unregisterFromKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self removeObserver:self forKeyPath:keyPath];
	}
}

- (NSArray *)observableKeypaths {
	return [NSArray arrayWithObjects:@"progressTintColor", @"trackTintColor", @"lineWidth", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [self setProgress:progress animated:animated maxDuration:1.0 completion:nil];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated maxDuration:(NSTimeInterval)maxDuration completion:(void (^)(void))completion
{
    progress = MIN(1.0, MAX(0.0, progress));
    if (_progress != progress) {
        BOOL animating = [self.animationTimer isValid];
        if (animating) {
            [self.animationTimer invalidate];
            self.animationTimer = nil;
        }
        if (animated) {
            BOOL plus = _progress < progress;
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 * maxDuration block:^BOOL(NSTimer *timer) {
                if (plus) {
                    _progress += MIN(0.01, progress - _progress);
                } else {
                    _progress -= MIN(0.01, _progress - progress);
                }
                [self setNeedsDisplay];
                [self sendActionsForControlEvents:UIControlEventValueChanged];
                return (plus && _progress >= progress) || (!plus && _progress <= progress);
            } userInfo:nil repeatCount:TNBlockTimerRepeatCountInfinite completion:^(BOOL canceled) {
                if (completion) {
                    completion();
                }
            }];
        } else {
            _progress = progress;
            [self setNeedsDisplay];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            if (completion) {
                completion();
            }
        }
    }
}

- (void)stopAnimating
{
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

@end
