//
//  FlipBookAnimationBlock.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/4.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "FlipBookAnimationBlock.h"

@implementation FlipBookAnimationBlock
#pragma mark - 覆盖

+(VisualCustomAnimationBlock)coverAnimatingStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect,CGPoint translatePoint){
        UIView *animationView = [allAnimationViewsStack firstObject];
        CGRect rect = CGRectOffset(currentViewOriginRect, translatePoint.x, 0);
        rect = CGRectIntegral(rect);
        if (animationDirection == FlipAnimationDirection_FromRightToLeft) {
            if (rect.origin.x > 0) {
                rect.origin.x = 0;
            }
        }
        if (animationDirection == FlipAnimationDirection_FromLeftToRight) {
            if (rect.origin.x < - CGRectGetWidth(animationView.frame)) {
                rect.origin.x = - CGRectGetWidth(animationView.frame);
            }
        }
        animationView.frame = rect;
    };
}

+(CustomAnimationStatusBlock)coverBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,UIView *animatingView,BOOL success,FlipAnimationDirection animationDirection){
        if (allAnimationViewsStack.count < 2) {
            NSAssert(allAnimationViewsStack.count > 1, @" begin 动画效果childen View数量不足");
            return ;
        }
        
        if (animationDirection == FlipAnimationDirection_FromLeftToRight) {
            ///滑入
            UIView *animationView = animatingView;
            animationView.frame = CGRectOffset(animationView.bounds, -CGRectGetWidth(animationView.bounds), 0);
            for (UIView *tmpView in allAnimationViewsStack) {
                if (tmpView != animatingView) {
                    tmpView.frame = (CGRect){0,0,animationView.frame.size};
                }
            }
            return;
        }
        ///滑出
        for (UIView *sub in allAnimationViewsStack) {
            sub.frame = sub.bounds;
        }
    };
}

+(CustomAnimationStatusBlock)coverEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,UIView *animatingView,BOOL success,FlipAnimationDirection animationDirection){
        if (allAnimationViewsStack.count < 2) {
            NSAssert(allAnimationViewsStack.count > 1, @" begin 动画效果childen View数量不足");
            return ;
        }
        
        if (animationDirection == FlipAnimationDirection_FromLeftToRight) {
            ///滑入
            for (UIView *sub in allAnimationViewsStack) {
                sub.frame = sub.bounds;
            }
            
            return;
        }
        ///滑出
        UIView *animationView = animatingView;
        animationView.frame = CGRectOffset(animationView.bounds, -CGRectGetWidth(animationView.bounds), 0);
        for (UIView *tmpView in allAnimationViewsStack) {
            if (tmpView != animatingView) {
                tmpView.frame = animationView.bounds;
            }
        }
    };
}

#pragma mark - 水平滑动


+(VisualCustomAnimationBlock)scrollAnimatingStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect,CGPoint translatePoint){
        
    };
}
+(CustomAnimationStatusBlock)scrollBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,UIView *animatingView,BOOL success,FlipAnimationDirection animationDirection){
        
    };
}
+(CustomAnimationStatusBlock)scrollEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,UIView *animatingView,BOOL success,FlipAnimationDirection animationDirection){
        
    };
}

#pragma mark - 自动阅读


+(VisualCustomAnimationBlock)autoAnimatingStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect,CGPoint translatePoint){
        
    };
}
+(CustomAnimationStatusBlock)autoBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,UIView *animatingView,BOOL success,FlipAnimationDirection animationDirection){
        
    };
}
+(CustomAnimationStatusBlock)autoEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,UIView *animatingView,BOOL success,FlipAnimationDirection animationDirection){
        
    };
}
@end
