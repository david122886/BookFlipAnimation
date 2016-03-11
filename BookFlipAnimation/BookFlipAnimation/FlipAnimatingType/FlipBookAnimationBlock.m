//
//  FlipBookAnimationBlock.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/4.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "FlipBookAnimationBlock.h"
#import "PageAnimationView.h"
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
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        if (allAnimationViewsStack.count < 2) {
            NSAssert(allAnimationViewsStack.count > 1, @" begin 动画效果childen View数量不足");
            return ;
        }
        if (originDirection == FlipAnimationDirection_FromLeftToRight) {
            [allAnimationViewsStack removeObject:reuseView];
            [allAnimationViewsStack insertObject:reuseView atIndex:0];
            [animationController.view bringSubviewToFront:(UIView*)reuseView];
            
            [reuseView setShadowPosion:ShadowPosion_Right];
            
            ///滑入
            UIView *animationView = reuseView;
            animationView.frame = CGRectOffset(animationView.bounds, -CGRectGetWidth(animationView.bounds), 0);
            for (UIView *tmpView in allAnimationViewsStack) {
                if (tmpView != reuseView) {
                    tmpView.frame = (CGRect){0,0,animationView.frame.size};
                }
            }
        }
        
        if (originDirection == FlipAnimationDirection_FromRightToLeft) {
            [allAnimationViewsStack removeObject:reuseView];
            [allAnimationViewsStack insertObject:reuseView atIndex:0];
            [animationController.view bringSubviewToFront:(UIView*)reuseView];
            
            [allAnimationViewsStack removeObject:currentView];
            [allAnimationViewsStack insertObject:currentView atIndex:0];
            [animationController.view bringSubviewToFront:(UIView*)currentView];
            
            [currentView setShadowPosion:ShadowPosion_Right];
            
            ///滑出
            for (UIView *sub in allAnimationViewsStack) {
                sub.frame = sub.bounds;
            }
        }
    };
}

+(CustomAnimationStatusBlock)coverEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        if (allAnimationViewsStack.count < 2) {
            NSAssert(allAnimationViewsStack.count > 1, @" begin 动画效果childen View数量不足");
            return ;
        }
        if (originDirection == finalDirection) {
            if (originDirection == FlipAnimationDirection_FromLeftToRight) {
                [allAnimationViewsStack removeObject:currentView];
                [allAnimationViewsStack insertObject:currentView atIndex:0];
                [animationController.view bringSubviewToFront:(UIView*)currentView];
                
                [allAnimationViewsStack removeObject:reuseView];
                [allAnimationViewsStack insertObject:reuseView atIndex:0];
                [animationController.view bringSubviewToFront:(UIView*)reuseView];
                
                [reuseView setShadowPosion:ShadowPosion_None];
                
            }
            
            if (originDirection == FlipAnimationDirection_FromRightToLeft) {
                [allAnimationViewsStack removeObject:currentView];
                [allAnimationViewsStack addObject:currentView];
                [animationController.view sendSubviewToBack:(UIView*)currentView];
                
                [allAnimationViewsStack removeObject:reuseView];
                [allAnimationViewsStack insertObject:reuseView atIndex:0];
                [animationController.view bringSubviewToFront:(UIView*)reuseView];
                
                [currentView setShadowPosion:ShadowPosion_None];
                
            }
            
            if (finalDirection == FlipAnimationDirection_FromLeftToRight) {
                ///滑入
                for (UIView *sub in allAnimationViewsStack) {
                    sub.frame = sub.bounds;
                }
                
                return;
            }
            ///滑出
            UIView *animationView = currentView;
            animationView.frame = CGRectOffset(animationView.bounds, -CGRectGetWidth(animationView.bounds), 0);
            for (UIView *tmpView in allAnimationViewsStack) {
                if (tmpView != currentView) {
                    tmpView.frame = animationView.bounds;
                }
            }
            
        }else{
            if (originDirection == FlipAnimationDirection_FromLeftToRight) {
                [allAnimationViewsStack removeObject:reuseView];
                [allAnimationViewsStack addObject:reuseView];
                [animationController.view sendSubviewToBack:(UIView*)reuseView];
                
                [allAnimationViewsStack removeObject:currentView];
                [allAnimationViewsStack insertObject:currentView atIndex:0];
                [animationController.view bringSubviewToFront:(UIView*)currentView];
                
                [reuseView setShadowPosion:ShadowPosion_None];
                
                ///滑出
                UIView *animationView = reuseView;
                animationView.frame = CGRectOffset(animationView.bounds, -CGRectGetWidth(animationView.bounds), 0);
                for (UIView *tmpView in allAnimationViewsStack) {
                    if (tmpView != currentView) {
                        tmpView.frame = animationView.bounds;
                    }
                }
            }
            
            if (originDirection == FlipAnimationDirection_FromRightToLeft) {
                [allAnimationViewsStack removeObject:currentView];
                [allAnimationViewsStack insertObject:currentView atIndex:0];
                [animationController.view bringSubviewToFront:(UIView*)currentView];
                [currentView setShadowPosion:ShadowPosion_None];
                
                ///滑入
                for (UIView *sub in allAnimationViewsStack) {
                    sub.frame = sub.bounds;
                }
            }
            
            
            
            
        }
    };
}

#pragma mark - 水平滑动


+(VisualCustomAnimationBlock)scrollAnimatingStatusBlock{
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

+(CustomAnimationStatusBlock)scrollBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        
    };
}
+(CustomAnimationStatusBlock)scrollEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        
    };
}

#pragma mark - 自动阅读


+(VisualCustomAnimationBlock)autoAnimatingStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect,CGPoint translatePoint){
        
    };
}
+(CustomAnimationStatusBlock)autoBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        
    };
}
+(CustomAnimationStatusBlock)autoEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        
    };
}
@end
