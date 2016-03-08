//
//  FlipBookAnimationManager.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/4.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "FlipBookAnimationManager.h"
#import "FlipBookAnimationBlock.h"

@implementation FlipBookAnimationManager
+(VisualCustomAnimationBlock)visualAnimatingCustomAnimationBlockWithFlipAnimationType:(FlipAnimationType)animationType{
    if (animationType == FlipAnimationType_cover) {
        return [FlipBookAnimationBlock coverAnimatingStatusBlock];
    }
    if (animationType == FlipAnimationType_scroll) {
        return [FlipBookAnimationBlock scrollAnimatingStatusBlock];
    }
    if (animationType == FlipAnimationType_auto) {
        return [FlipBookAnimationBlock autoAnimatingStatusBlock];
    }
    
    return nil;
}

+(CustomAnimationStatusBlock)visualBeginCustomAnimationBlockWithFlipAnimationType:(FlipAnimationType)animationType{
    if (animationType == FlipAnimationType_cover) {
        return [FlipBookAnimationBlock coverBeginAnimationStatusBlock];
    }
    if (animationType == FlipAnimationType_scroll) {
        return [FlipBookAnimationBlock scrollBeginAnimationStatusBlock];
    }
    if (animationType == FlipAnimationType_auto) {
        return [FlipBookAnimationBlock autoBeginAnimationStatusBlock];
    }
    return nil;
}

+(CustomAnimationStatusBlock)visualEndCustomAnimationBlockWithFlipAnimationType:(FlipAnimationType)animationType{
    if (animationType == FlipAnimationType_cover) {
        return [FlipBookAnimationBlock coverEndAnimationStatusBlock];
    }
    if (animationType == FlipAnimationType_scroll) {
        return [FlipBookAnimationBlock scrollEndAnimationStatusBlock];
    }
    if (animationType == FlipAnimationType_auto) {
        return [FlipBookAnimationBlock autoEndAnimationStatusBlock];
    }
    return nil;
}
@end
