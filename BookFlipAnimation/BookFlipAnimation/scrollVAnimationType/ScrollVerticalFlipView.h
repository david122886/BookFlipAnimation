//
//  ScrollVerticalFlipView.h
//  BookFlipAnimation
//
//  Created by liudavid on 16/3/18.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXSYPageViewController.h"
#define kPageHeaderHeight 30

@class ScrollVerticalFlipView;

@protocol ScrollVerticalFlipViewDataSource<NSObject>
-(XXSYPageViewController*)scrollVerticalView:(ScrollVerticalFlipView*)scrollView refreshBeforePageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC;

-(XXSYPageViewController*)scrollVerticalView:(ScrollVerticalFlipView*)scrollView refreshAfterPageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC;

@end

@protocol ScrollVerticalFlipViewDelegate <NSObject>

-(void)scrollVerticalView:(ScrollVerticalFlipView*)scrollView refreshScrollHeader:(UIView*)header andRefreshScrollFooter:(UIView*)footer withCurrentPageVC:(XXSYPageViewController*)currentPageVC;

@end
/**
 * 上下拖动翻页效果
 */
@interface ScrollVerticalFlipView : UIView
@property (weak,nonatomic) id<ScrollVerticalFlipViewDataSource> dataSource;
@property (weak,nonatomic) id<ScrollVerticalFlipViewDelegate> delegate;
@property (assign,nonatomic) BOOL isFlipAnimating;
-(instancetype)initWithFrame:(CGRect)frame withPageVC:(XXSYPageViewController*)pageVC withDataSource:(id<ScrollVerticalFlipViewDataSource>)dataSource withPageVCForClass:(Class)pageVCClass;

-(void)registerScrollHeader:(Class)headerClass;
-(void)registerScrollFooter:(Class)footerClass;

-(NSArray*)getAllPageVCs;
@end
