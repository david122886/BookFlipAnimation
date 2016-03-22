//
//  ScrollVerticalFlipView.h
//  BookFlipAnimation
//
//  Created by liudavid on 16/3/18.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXSYPageViewController.h"
@class ScrollVerticalFlipView;

@protocol ScrollVerticalFlipViewDataSource<NSObject>
-(XXSYPageViewController*)scrollVerticalView:(ScrollVerticalFlipView*)scrollView refreshBeforePageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC;

-(XXSYPageViewController*)scrollVerticalView:(ScrollVerticalFlipView*)scrollView refreshAfterPageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC;

@end
/**
 * 上下拖动翻页效果
 */
@interface ScrollVerticalFlipView : UIView
@property (weak,nonatomic) id<ScrollVerticalFlipViewDataSource> dataSource;
@property (assign,nonatomic) BOOL isFlipAnimating;
-(instancetype)initWithFrame:(CGRect)frame withPageVC:(XXSYPageViewController*)pageVC withDataSource:(id<ScrollVerticalFlipViewDataSource>)dataSource withPageVCForClass:(Class)pageVCClass;

@end
