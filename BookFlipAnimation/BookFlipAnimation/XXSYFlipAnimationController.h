//
//  XXSYFlipAnimationController.h
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/2.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XXSYPageViewController.h"
@class XXSYFlipAnimationController;
@class PageAnimationView;

typedef void (^VisualCustomAnimationBlock)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection,CGRect currentViewOriginRect,CGPoint translatePoint);

typedef void (^CustomAnimationStatusBlock)(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection);

#pragma mark - 

@protocol XXSYFlipAnimationControllerDataSource <NSObject>
/**
 * @brief 需要显示上一页PageVC赋值
 *
 * @param animationController
 * @param reusePageVC 需要刷新数据PageVC
 * @param currentPageVC 当前正在显示PageVC
 *
 * @return 需要显示PageVC，如果为空表示没有数据展示
 */
-(XXSYPageViewController*)flipAnimationController:(XXSYFlipAnimationController*)animationController refreshBeforePageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC;

/**
 * @brief 需要显示下一页PageVC赋值
 *
 * @param animationController
 * @param reusePageVC 需要刷新数据PageVC
 * @param currentPageVC 当前正在显示PageVC
 *
 * @return 需要显示PageVC，如果为空表示没有数据展示
 */
-(XXSYPageViewController*)flipAnimationController:(XXSYFlipAnimationController*)animationController refreshAfterPageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC;

@end

@protocol XXSYFlipAnimationControllerDelegate <NSObject>
///弹出阅读菜单
-(void)flipAnimationControllerPopupMenu:(XXSYFlipAnimationController*)animationController;

/**
 * @brief 翻页结束时调用
 *
 * @param  animationController
 * @param  animation 翻页是否带动画效果
 * @param  completed 翻页是否完成
 *
 */
-(void)flipAnimationController:(XXSYFlipAnimationController*)animationController FlipFinishedHasAnimation:(BOOL)animation transitionCompleted:(BOOL)completed;

-(void)flipAnimationController:(XXSYFlipAnimationController*)animationController refreshScrollHeader:(UIView*)header andRefreshScrollFooter:(UIView*)footer withCurrentPageVC:(XXSYPageViewController*)currentPageVC;
@end

#pragma mark -

/**
 * 翻页效果
 */
@interface XXSYFlipAnimationController : UIViewController
#pragma mark -
@property (weak,nonatomic) id<XXSYFlipAnimationControllerDataSource> dataSource;
@property (weak,nonatomic) id<XXSYFlipAnimationControllerDelegate> delegate;
#pragma mark -


@property (assign,nonatomic,readonly) FlipAnimationType animationType;

-(void)changeFlipAnimationType:(FlipAnimationType)animationType;
///是否正在进行动画效果
-(BOOL)isAnimating;

///自定义动画，上下拖动（uiscrollview实现）和仿真（uipageviewcontroller实现）除外
-(void)setCustomVisualAnimationBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection,CGRect currentViewOriginRect,CGPoint translatePoint))visualAnimationBlock withAnimationBeginStatusBlock:(void (^)(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection))animationBeginStatus withAnimationFinishedBlock:(void (^)(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection))animationFinishedStatus;

#pragma mark -

-(void)registerPageVCForClass:(Class)pageVCClass;
-(void)registerScrollHeader:(Class)scrollHeader;
-(void)registerScrollFooter:(Class)scrollFooter;

-(NSArray*)childenPageControllers;
///上下拖动翻页需要区分
-(XXSYPageViewController*)getCurrentPageVCForAfter;
///上下拖动翻页需要区分
-(XXSYPageViewController*)getCurrentPageVCForBefore;

-(void)setupInitPageViewController:(XXSYPageViewController*)pageVC withFlipAnimationType:(FlipAnimationType)animationType;
#pragma mark -

///点击有效区域,必须设置
@property (strong,nonatomic,readonly) UIBezierPath *touchBeforeBezierPath;
@property (strong,nonatomic,readonly) UIBezierPath *touchAfterBezierPath;
@property (strong,nonatomic,readonly) UIBezierPath *touchCenterBezierPath;

/**
 * @brief 手势结束时处理,和delegate FlipFinishedHasAnimation相同功能
 *
 * @param  flipAnimationController 手势接受viewcontroller
 * @param  gesture tap/pan Gesture
 *
 */
-(void)setGestureCompletionBlock:(void(^)(XXSYFlipAnimationController * flipAnimationController, UIGestureRecognizer * gesture))gestureCompletionBlock;

-(void)setGestureShouldRecognizeTouchBlock:(BOOL(^)(XXSYFlipAnimationController * flipAnimationController, UIGestureRecognizer * gesture, UITouch * touch))gestureShouldRecognizeTouchBlock;


-(void)setTouchBeforeAreaBezierPath:(UIBezierPath*)bezierPath;
-(void)setTouchAfterAreaBezierPath:(UIBezierPath*)bezierPath;
-(void)setTouchCenterAreaBezierPath:(UIBezierPath*)bezierPath;
#pragma mark -


#pragma mark - cache
///缓存pagevc数量
@property (assign,nonatomic) NSInteger reuseCacheCount;


#pragma mark - 自动翻页设置

@property (assign,nonatomic,readonly) AutoReadStatus autoReadStatus;

-(void)startAutoReadWithSpeed:(CGFloat)speed;
-(void)stopAutoRead;
-(void)pauseAutoRead;
-(void)resumeAutoRead;
-(void)setupSpeed:(CGFloat)speed;
@end
