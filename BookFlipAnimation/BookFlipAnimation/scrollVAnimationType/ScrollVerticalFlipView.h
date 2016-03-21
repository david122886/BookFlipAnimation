//
//  ScrollVerticalFlipView.h
//  BookFlipAnimation
//
//  Created by liudavid on 16/3/18.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXSYPageViewController.h"
/**
 * 上下拖动翻页效果
 */
@interface ScrollVerticalFlipView : UIView
-(instancetype)initWithFrame:(CGRect)frame withPageVC:(XXSYPageViewController*)pageVC;
@end
