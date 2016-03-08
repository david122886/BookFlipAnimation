//
//  FlipBookAnimationBlock.h
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/4.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXSYFlipAnimationController.h"
@interface FlipBookAnimationBlock : NSObject
+(VisualCustomAnimationBlock)coverAnimatingStatusBlock;
+(CustomAnimationStatusBlock)coverBeginAnimationStatusBlock;
+(CustomAnimationStatusBlock)coverEndAnimationStatusBlock;

+(VisualCustomAnimationBlock)scrollAnimatingStatusBlock;
+(CustomAnimationStatusBlock)scrollBeginAnimationStatusBlock;
+(CustomAnimationStatusBlock)scrollEndAnimationStatusBlock;

+(VisualCustomAnimationBlock)autoAnimatingStatusBlock;
+(CustomAnimationStatusBlock)autoBeginAnimationStatusBlock;
+(CustomAnimationStatusBlock)autoEndAnimationStatusBlock;

@end
