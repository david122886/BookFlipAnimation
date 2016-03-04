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
+(VisualCustomAnimationBlock)coverAnimatingAnimationTypeBlock;
+(CustomAnimationStatusBlock)coverBeginAnimationTypeBlock;
+(CustomAnimationStatusBlock)coverEndAnimationTypeBlock;

+(VisualCustomAnimationBlock)scrollAnimatingAnimationTypeBlock;
+(CustomAnimationStatusBlock)scrollBeginAnimationTypeBlock;
+(CustomAnimationStatusBlock)scrollEndAnimationTypeBlock;

+(VisualCustomAnimationBlock)autoAnimatingAnimationTypeBlock;
+(CustomAnimationStatusBlock)autoBeginAnimationTypeBlock;
+(CustomAnimationStatusBlock)autoEndAnimationTypeBlock;

@end
