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

+(VisualCustomAnimationBlock)coverAnimatingAnimationTypeBlock{
    return nil;
}
+(CustomAnimationStatusBlock)coverBeginAnimationTypeBlock{
    return nil;
}
+(CustomAnimationStatusBlock)coverEndAnimationTypeBlock{
    return nil;
}

#pragma mark - 水平滑动


+(VisualCustomAnimationBlock)scrollAnimatingAnimationTypeBlock{
    return nil;
}
+(CustomAnimationStatusBlock)scrollBeginAnimationTypeBlock{
    return nil;
}
+(CustomAnimationStatusBlock)scrollEndAnimationTypeBlock{
    return nil;
}

#pragma mark - 自动阅读


+(VisualCustomAnimationBlock)autoAnimatingAnimationTypeBlock{
    return nil;
}
+(CustomAnimationStatusBlock)autoBeginAnimationTypeBlock{
    return nil;
}
+(CustomAnimationStatusBlock)autoEndAnimationTypeBlock{
    return nil;
}
@end
