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
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection,CGRect currentViewOriginRect,CGPoint translatePoint){
        UIView *animationView = [allAnimationViewsStack firstObject];
        CGRect rect = CGRectOffset(currentViewOriginRect, translatePoint.x, 0);
//        rect = CGRectIntegral(rect);
        if (finalDirection == FlipAnimationDirection_FromRightToLeft) {
            if (rect.origin.x > 0) {
                rect.origin.x = 0;
            }
        }
        if (finalDirection == FlipAnimationDirection_FromLeftToRight) {
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
            
            ///滑入
            reuseView.isAnimationg = YES;
            UIView *animationView = reuseView;
            CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_Right];
            CGRect otherRect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_None];
            
            animationView.frame = CGRectOffset((CGRect){0,0,rect.size}, -CGRectGetWidth(rect), 0);
            
            for (PageAnimationView *sub in allAnimationViewsStack) {
                if (sub == reuseView) {
                    [sub setShadowPosion:ShadowPosion_Right];
                }else{
                    sub.frame = otherRect;
                    [sub setShadowPosion:ShadowPosion_None];
                    sub.isAnimationg = NO;
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
            
            currentView.isAnimationg = YES;
            ///滑出
            CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_None];
            CGRect animationRect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_Right];
            
            for (PageAnimationView *sub in allAnimationViewsStack) {
                if (sub == currentView) {
                    sub.frame = animationRect;
                    [sub setShadowPosion:ShadowPosion_Right];
                }else{
                    sub.frame = rect;
                    [sub setShadowPosion:ShadowPosion_None];
                    sub.isAnimationg = NO;
                }
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
            }
            
            if (originDirection == FlipAnimationDirection_FromRightToLeft) {
                [allAnimationViewsStack removeObject:currentView];
                [allAnimationViewsStack addObject:currentView];
                [animationController.view sendSubviewToBack:(UIView*)currentView];
                
                [allAnimationViewsStack removeObject:reuseView];
                [allAnimationViewsStack insertObject:reuseView atIndex:0];
                [animationController.view bringSubviewToFront:(UIView*)reuseView];
            }
            
            CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_None];
            if (finalDirection == FlipAnimationDirection_FromLeftToRight) {
                ///滑入
                for (PageAnimationView *sub in allAnimationViewsStack) {
                    sub.frame = (CGRect){0,0,rect.size};
                    sub.isAnimationg = NO;
                    [sub setShadowPosion:ShadowPosion_None];
                }
                
                return;
            }
            ///滑出
            UIView *animationView = currentView;
            animationView.frame = CGRectOffset((CGRect){0,0,rect.size}, -CGRectGetWidth(rect), 0);
            for (PageAnimationView *tmpView in allAnimationViewsStack) {
                if (tmpView != currentView) {
                    tmpView.frame = (CGRect){0,0,rect.size};
                }
                tmpView.isAnimationg = NO;
                [tmpView setShadowPosion:ShadowPosion_None];
            }
            
        }else{
            if (originDirection == FlipAnimationDirection_FromLeftToRight) {
                [allAnimationViewsStack removeObject:reuseView];
                [allAnimationViewsStack addObject:reuseView];
                [animationController.view sendSubviewToBack:(UIView*)reuseView];
                
                [allAnimationViewsStack removeObject:currentView];
                [allAnimationViewsStack insertObject:currentView atIndex:0];
                [animationController.view bringSubviewToFront:(UIView*)currentView];
                
                ///滑出
                CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_None];
                UIView *animationView = reuseView;
                animationView.frame = CGRectOffset((CGRect){0,0,rect.size}, -CGRectGetWidth(rect), 0);
                for (PageAnimationView *tmpView in allAnimationViewsStack) {
                    if (tmpView != currentView) {
                        tmpView.frame = (CGRect){0,0,rect.size};
                    }
                    tmpView.isAnimationg = NO;
                    [tmpView setShadowPosion:ShadowPosion_None];
                }
            }
            
            if (originDirection == FlipAnimationDirection_FromRightToLeft) {
                [allAnimationViewsStack removeObject:currentView];
                [allAnimationViewsStack insertObject:currentView atIndex:0];
                [animationController.view bringSubviewToFront:(UIView*)currentView];
                ///滑入
                CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_None];
                for (PageAnimationView *sub in allAnimationViewsStack) {
                    sub.frame = (CGRect){0,0,rect.size};
                    sub.isAnimationg = NO;
                    [sub setShadowPosion:ShadowPosion_None];
                }
            }
            
            
            
            
        }
        
    };
}

#pragma mark - 水平滑动


+(VisualCustomAnimationBlock)scrollAnimatingStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection,CGRect currentViewOriginRect,CGPoint translatePoint){
        UIView *animationView = [allAnimationViewsStack firstObject];
        UIView *followView = [allAnimationViewsStack objectAtIndex:1];
        CGRect rect = CGRectOffset(currentViewOriginRect, translatePoint.x, 0);
        CGRect followRect;
//        rect = CGRectIntegral(rect);
        if (originDirection == finalDirection) {
            if (originDirection == FlipAnimationDirection_FromRightToLeft) {
                if (rect.origin.x > 0) {
                    rect.origin.x = 0;
                }
                followRect = CGRectOffset(rect, CGRectGetWidth(animationView.frame), 0);
            }
            if (originDirection == FlipAnimationDirection_FromLeftToRight) {
                if (rect.origin.x < 0) {
                    rect.origin.x = 0;
                }
                followRect = CGRectOffset(rect, -CGRectGetWidth(animationView.frame), 0);
            }
        }else{
            if (originDirection == FlipAnimationDirection_FromRightToLeft) {
                if (rect.origin.x > 0) {
                    rect.origin.x = 0;
                }
                followRect = CGRectOffset(rect, CGRectGetWidth(animationView.frame), 0);
            }
            if (originDirection == FlipAnimationDirection_FromLeftToRight) {
                if (rect.origin.x < - CGRectGetWidth(animationView.frame)) {
                    rect.origin.x = - CGRectGetWidth(animationView.frame);
                }
                followRect = CGRectOffset(rect, -CGRectGetWidth(animationView.frame), 0);
            }
        }
        
        animationView.frame = rect;
        followView.frame = followRect;
    };
}

+(CustomAnimationStatusBlock)scrollBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        if (allAnimationViewsStack.count < 2) {
            NSAssert(allAnimationViewsStack.count > 1, @" begin 动画效果childen View数量不足");
            return ;
        }
        
        [allAnimationViewsStack removeObject:reuseView];
        [allAnimationViewsStack insertObject:reuseView atIndex:0];
        [animationController.view bringSubviewToFront:(UIView*)reuseView];
        
        [allAnimationViewsStack removeObject:currentView];
        [allAnimationViewsStack insertObject:currentView atIndex:0];
        [animationController.view bringSubviewToFront:(UIView*)currentView];
        
        
        [reuseView setShadowPosion:ShadowPosion_None];
        [currentView setShadowPosion:ShadowPosion_None];
        
        CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_None];
        for (PageAnimationView *sub in allAnimationViewsStack) {
            sub.frame = rect;
            [sub setShadowPosion:ShadowPosion_None];
            sub.isAnimationg = YES;
        }
        
        if (originDirection == FlipAnimationDirection_FromLeftToRight) {
            reuseView.frame = CGRectOffset(currentView.bounds, -CGRectGetWidth(currentView.bounds), 0);
        }
        
        if (originDirection == FlipAnimationDirection_FromRightToLeft) {
            reuseView.frame = CGRectOffset(currentView.bounds, CGRectGetWidth(currentView.bounds), 0);
        }
    };
}
+(CustomAnimationStatusBlock)scrollEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        if (allAnimationViewsStack.count < 2) {
            NSAssert(allAnimationViewsStack.count > 1, @" begin 动画效果childen View数量不足");
            return ;
        }
        if (originDirection == finalDirection) {
            [allAnimationViewsStack removeObject:currentView];
            [allAnimationViewsStack addObject:currentView];
            [animationController.view sendSubviewToBack:(UIView*)currentView];
            
            [allAnimationViewsStack removeObject:reuseView];
            [allAnimationViewsStack insertObject:reuseView atIndex:0];
            [animationController.view bringSubviewToFront:(UIView*)reuseView];
            
            CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_None];
            for (PageAnimationView *sub in allAnimationViewsStack) {
                sub.frame = rect;
                sub.isAnimationg = NO;
            }
            
            if (finalDirection == FlipAnimationDirection_FromLeftToRight) {
                currentView.frame = CGRectOffset(currentView.bounds, CGRectGetWidth(currentView.frame), 0);
            }
            if (finalDirection == FlipAnimationDirection_FromRightToLeft) {
                currentView.frame = CGRectOffset(currentView.bounds, -CGRectGetWidth(currentView.frame), 0);

            }
            
        }else{
            [allAnimationViewsStack removeObject:reuseView];
            [allAnimationViewsStack addObject:reuseView];
            [animationController.view sendSubviewToBack:(UIView*)reuseView];
            
            [allAnimationViewsStack removeObject:currentView];
            [allAnimationViewsStack insertObject:currentView atIndex:0];
            [animationController.view bringSubviewToFront:(UIView*)currentView];
            
            CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_None];
            for (PageAnimationView *sub in allAnimationViewsStack) {
                sub.frame = rect;
                sub.isAnimationg = NO;
            }
            
            if (finalDirection == FlipAnimationDirection_FromLeftToRight) {
                reuseView.frame = CGRectOffset(currentView.bounds, CGRectGetWidth(currentView.frame), 0);
            }
            if (finalDirection == FlipAnimationDirection_FromRightToLeft) {
                reuseView.frame = CGRectOffset(currentView.bounds, -CGRectGetWidth(currentView.frame), 0);
            }
        }
    };
}

#pragma mark - 自动阅读


+(VisualCustomAnimationBlock)autoAnimatingStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection,CGRect currentViewOriginRect,CGPoint translatePoint){
        UIView *animationView = [allAnimationViewsStack firstObject];
        animationView.frame = (CGRect){0,0,CGRectGetWidth(currentViewOriginRect),CGRectGetHeight(currentViewOriginRect)+translatePoint.y};
    };
}

+(CustomAnimationStatusBlock)autoBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        if (allAnimationViewsStack.count < 2) {
            NSAssert(allAnimationViewsStack.count > 1, @" begin 动画效果childen View数量不足");
            return ;
        }
        [allAnimationViewsStack removeObject:currentView];
        [allAnimationViewsStack insertObject:currentView atIndex:0];
        [animationController.view bringSubviewToFront:(UIView*)currentView];
        
        [allAnimationViewsStack removeObject:reuseView];
        [allAnimationViewsStack insertObject:reuseView atIndex:0];
        [animationController.view bringSubviewToFront:(UIView*)reuseView];
        
        currentView.isAnimationg = YES;
        ///滑出
        CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_Bottom];
        for (PageAnimationView *sub in allAnimationViewsStack) {
            [sub setShadowPosion:ShadowPosion_Bottom];
            if (sub != reuseView) {
                sub.frame = rect;
            }else{
                sub.frame = (CGRect){0,0,CGRectGetWidth(rect),0};
            }
        }
    };
}

+(CustomAnimationStatusBlock)autoEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection){
        if (allAnimationViewsStack.count < 2) {
            NSAssert(allAnimationViewsStack.count > 1, @" begin 动画效果childen View数量不足");
            return ;
        }
        [allAnimationViewsStack removeObject:currentView];
        [allAnimationViewsStack addObject:currentView];
        [animationController.view sendSubviewToBack:(UIView*)currentView];
        
        [allAnimationViewsStack removeObject:reuseView];
        [allAnimationViewsStack insertObject:reuseView atIndex:0];
        [animationController.view bringSubviewToFront:(UIView*)reuseView];
        
        CGRect rect = [PageAnimationView pageAnimationViewFrameWithShadowPosion:ShadowPosion_Right];
        for (PageAnimationView *sub in allAnimationViewsStack) {
            sub.isAnimationg = NO;
            sub.frame = rect;
            [sub setShadowPosion:ShadowPosion_None];
        }
    };
}
@end
