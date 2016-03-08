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
        animationView.frame = CGRectOffset(currentViewOriginRect, translatePoint.x, 0);
    };
}

+(CustomAnimationStatusBlock)coverBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection){
        if (allAnimationViewsStack.count < 2) {
            NSAssert(allAnimationViewsStack.count > 1, @" begin 动画效果childen View数量不足");
            return ;
        }
        if (animationDirection == FlipAnimationDirection_FromLeftToRight) {
            ///滑入
            UIView *animationView = [allAnimationViewsStack firstObject];
            animationView.frame = CGRectOffset(animationView.bounds, -CGRectGetWidth(animationView.bounds), 0);
            for (int i = 1; i < allAnimationViewsStack.count; i++) {
                UIView *tmpView = allAnimationViewsStack[i];
                tmpView.frame = (CGRect){0,0,animationView.frame.size};
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
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection){
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
        UIView *animationView = [allAnimationViewsStack firstObject];
        animationView.frame = CGRectOffset(animationView.bounds, -CGRectGetWidth(animationView.bounds), 0);
        for (int i = 1; i < allAnimationViewsStack.count; i++) {
            UIView *tmpView = allAnimationViewsStack[i];
            tmpView.frame = animationView.bounds;
        }
    };
}

#pragma mark - 水平滑动


+(VisualCustomAnimationBlock)scrollAnimatingStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect,CGPoint translatePoint){
        
    };
}
+(CustomAnimationStatusBlock)scrollBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection){
        
    };
}
+(CustomAnimationStatusBlock)scrollEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection){
        
    };
}

#pragma mark - 自动阅读


+(VisualCustomAnimationBlock)autoAnimatingStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect,CGPoint translatePoint){
        
    };
}
+(CustomAnimationStatusBlock)autoBeginAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection){
        
    };
}
+(CustomAnimationStatusBlock)autoEndAnimationStatusBlock{
    return ^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection){
        
    };
}
@end
