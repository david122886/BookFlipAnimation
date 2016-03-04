//
//  Constent.h
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/2.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BookModel.h"
#import "Page.h"
#import "ChapterNode.h"
#import "RequestError.h"

#ifndef Constent_h
#define Constent_h

typedef NS_ENUM(NSInteger, FlipAnimationDirection) {
    ///动画方向从左到右
    FlipAnimationDirection_FromLeftToRight,
    ///动画方向从右到左
    FlipAnimationDirection_FromRightToLeft,
    ///没有方向
    FlipAnimationDirection_None,
    FlipAnimationDirection_Other
};

///自动阅读状态
typedef NS_ENUM(NSInteger,AutoReadStatus){
    AutoReadStatus_none,
    AutoReadStatus_start,
    AutoReadStatus_pause,
    AutoReadStatus_stop,
    AutoReadStatus_beginning
};

typedef NS_ENUM(NSInteger, FlipAnimationType) {
    ///仿真翻页
    FlipAnimationType_curl,
    ///水平滑动翻页
    FlipAnimationType_scroll,
    ///垂直滑动翻页
    FlipAnimationType_scroll_V,
    ///覆盖翻页效果
    FlipAnimationType_cover,
    ///自动翻页效果
    FlipAnimationType_auto
};

#endif /* Constent_h */
