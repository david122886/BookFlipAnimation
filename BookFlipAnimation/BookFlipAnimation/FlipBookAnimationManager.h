//
//  FlipBookAnimationManager.h
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/4.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constent.h"
#import "XXSYFlipAnimationController.h"
@interface FlipBookAnimationManager : NSObject
+(VisualCustomAnimationBlock)visualAnimatingCustomAnimationBlockWithFlipAnimationType:(FlipAnimationType)animationType;
+(CustomAnimationStatusBlock)visualBeginCustomAnimationBlockWithFlipAnimationType:(FlipAnimationType)animationType;
+(CustomAnimationStatusBlock)visualEndCustomAnimationBlockWithFlipAnimationType:(FlipAnimationType)animationType;
@end
