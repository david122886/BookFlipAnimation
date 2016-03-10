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

typedef void (^VisualCustomAnimationBlock)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect,CGPoint translatePoint);

typedef void (^CustomAnimationStatusBlock)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,UIView *animatingView,BOOL success,FlipAnimationDirection animationDirection);

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

///是否正在进行动画效果
@property (assign,nonatomic,readonly) BOOL isFlipAnimating;
@property (assign,nonatomic,readonly) FlipAnimationType animationType;

-(void)changeFlipAnimationType:(FlipAnimationType)animationType;

///自定义动画，上下拖动（uiscrollview实现）和仿真（uipageviewcontroller实现）除外
-(void)setCustomVisualAnimationBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect,CGPoint translatePoint))visualAnimationBlock withAnimationBeginStatusBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,UIView *animatingView,BOOL success,FlipAnimationDirection animationDirection))animationBeginStatus withAnimationFinishedBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,UIView *animatingView,BOOL success,FlipAnimationDirection animationDirection))animationFinishedStatus;

#pragma mark -

-(void)registerPageVCForClass:(Class)pageVCClass;

-(NSArray*)childenPageControllers;
-(XXSYPageViewController*)currentPageVC;
-(void)setupInitPageViewController:(XXSYPageViewController*)pageVC withFlipAnimationType:(FlipAnimationType)animationType;
#pragma mark -

///点击有效区域,必须设置
@property (strong,nonatomic,readonly) UIBezierPath *touchBeforeBezierPath;
@property (strong,nonatomic,readonly) UIBezierPath *touchAfterBezierPath;
@property (strong,nonatomic,readonly) UIBezierPath *touchCenterBezierPath;

/**
 * @brief 手势结束时处理
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
@end
