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
        return [FlipBookAnimationBlock coverAnimatingAnimationTypeBlock];
    }
    if (animationType == FlipAnimationType_scroll) {
        return [FlipBookAnimationBlock scrollAnimatingAnimationTypeBlock];
    }
    if (animationType == FlipAnimationType_auto) {
        return [FlipBookAnimationBlock autoAnimatingAnimationTypeBlock];
    }
    
    return nil;
}

+(CustomAnimationStatusBlock)visualBeginCustomAnimationBlockWithFlipAnimationType:(FlipAnimationType)animationType{
    if (animationType == FlipAnimationType_cover) {
        return [FlipBookAnimationBlock coverBeginAnimationTypeBlock];
    }
    if (animationType == FlipAnimationType_scroll) {
        return [FlipBookAnimationBlock scrollBeginAnimationTypeBlock];
    }
    if (animationType == FlipAnimationType_auto) {
        return [FlipBookAnimationBlock autoBeginAnimationTypeBlock];
    }
    return nil;
}

+(CustomAnimationStatusBlock)visualEndCustomAnimationBlockWithFlipAnimationType:(FlipAnimationType)animationType{
    if (animationType == FlipAnimationType_cover) {
        return [FlipBookAnimationBlock coverEndAnimationTypeBlock];
    }
    if (animationType == FlipAnimationType_scroll) {
        return [FlipBookAnimationBlock scrollEndAnimationTypeBlock];
    }
    if (animationType == FlipAnimationType_auto) {
        return [FlipBookAnimationBlock autoEndAnimationTypeBlock];
    }
    return nil;
}
@end
