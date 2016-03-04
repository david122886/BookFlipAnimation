//
//  XXSYPageViewController.h
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/2.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXSYPageVCProtocol.h"
@interface XXSYPageViewController : UIViewController<XXSYPageVCProtocol>
@property (strong,nonatomic) ChapterNode *currentNode;
///是否是当前页
@property (assign,nonatomic,readonly) BOOL isCurrentPageVC;
///是否正在进行翻页动画
@property (assign,nonatomic,readonly) BOOL isFlipAnimating;

@property (assign,nonatomic,readonly) FlipAnimationType animationType;

@end
