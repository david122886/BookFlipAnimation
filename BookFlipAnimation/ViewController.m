//
//  ViewController.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/2.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "ViewController.h"
#import "Constent.h"
#import "XXSYFlipAnimationController.h"
#import "FlipBookAnimationManager.h"
#import "PageViewController.h"

#import "ScrollVerticalFlipView.h"
#import "PageHeaderAndFooter.h"

@interface ViewController ()<XXSYFlipAnimationControllerDelegate,XXSYFlipAnimationControllerDataSource,ScrollVerticalFlipViewDataSource,ScrollVerticalFlipViewDelegate>
@property (strong,nonatomic) XXSYFlipAnimationController *animationController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    PageViewController *vc = [[PageViewController alloc] init];
//    vc.index = 0;
//    vc.view.backgroundColor = [UIColor greenColor];
//    
//    ScrollVerticalFlipView *flipView = [[ScrollVerticalFlipView alloc] initWithFrame:self.view.bounds withPageVC:vc withDataSource:self withPageVCForClass:[PageViewController class]];
//    [self.view addSubview:flipView];
//    flipView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    flipView.delegate = self;
//    [flipView registerScrollHeader:[PageHeaderAndFooter class]];
//    [flipView registerScrollFooter:[PageHeaderAndFooter class]];
//    
//    return;
    
    
    _animationController = [[XXSYFlipAnimationController alloc] init];
    [self.animationController registerPageVCForClass:[PageViewController class]];
    [self.animationController registerScrollHeader:[PageHeaderAndFooter class]];
    [self.animationController registerScrollFooter:[PageHeaderAndFooter class]];

    self.animationController.delegate = self;
    self.animationController.dataSource = self;
    
    self.animationController.view.backgroundColor = [UIColor redColor];
    [self.animationController willMoveToParentViewController:self];
    self.animationController.view.frame = self.view.bounds;
    self.animationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.animationController.view];
    [self.view sendSubviewToBack:self.animationController.view];
    [self addChildViewController:self.animationController];
    [self.animationController didMoveToParentViewController:self];
    
    [self setupFlipAnimationVCGesture];
    [self setupFlipAnimationVCTouchArea];
    [self setupFlipAnimationVCAnimationBlock];
    
    [self setupInitPageVC];
    
}

#pragma mark - setup XXSYFlipAnimationController

-(void)setupFlipAnimationVCGesture{
    [self.animationController setGestureShouldRecognizeTouchBlock:^BOOL(XXSYFlipAnimationController *flipAnimationController, UIGestureRecognizer *gesture, UITouch *touch) {
        return YES;
    }];
    
//    [self.animationController setGestureCompletionBlock:^(XXSYFlipAnimationController *flipAnimationController, UIGestureRecognizer *gesture) {
//        
//    }];
    
}

-(void)setupFlipAnimationVCTouchArea{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIBezierPath *leftBezierPath = [UIBezierPath bezierPathWithRect:(CGRect){0,0,CGRectGetWidth(rect)/3,CGRectGetHeight(rect)}];
    UIBezierPath *rightBezierPath = [UIBezierPath bezierPathWithRect:(CGRect){CGRectGetWidth(rect)/3*2,0,CGRectGetWidth(rect)/3,CGRectGetHeight(rect)}];
    UIBezierPath *centerBezierPath = [UIBezierPath bezierPathWithRect:(CGRect){CGRectGetWidth(rect)/3,0,CGRectGetWidth(rect)/3,CGRectGetHeight(rect)}];
    
    [self.animationController setTouchAfterAreaBezierPath:rightBezierPath];
    [self.animationController setTouchBeforeAreaBezierPath:leftBezierPath];
    [self.animationController setTouchCenterAreaBezierPath:centerBezierPath];
}

-(void)setupFlipAnimationVCAnimationBlock{
    [self.animationController setCustomVisualAnimationBlock:^(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection,CGRect currentViewOriginRect,CGPoint translatePoint) {
        VisualCustomAnimationBlock block = [FlipBookAnimationManager visualAnimatingCustomAnimationBlockWithFlipAnimationType:animationController.animationType];
        if (block) {
            block(animationController,allAnimationViewsStack,originDirection,finalDirection,currentViewOriginRect,translatePoint);
        }
//        NSLog(@"animating");
    } withAnimationBeginStatusBlock:^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection) {
        CustomAnimationStatusBlock block = [FlipBookAnimationManager visualBeginCustomAnimationBlockWithFlipAnimationType:animationController.animationType];
        if (block) {
            block(animationController,allAnimationViewsStack,reuseView,currentView,originDirection,finalDirection);
        }
        NSLog(@"begin");
    } withAnimationFinishedBlock:^(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection) {
        CustomAnimationStatusBlock block = [FlipBookAnimationManager visualEndCustomAnimationBlockWithFlipAnimationType:animationController.animationType];
        if (block) {
            block(animationController,allAnimationViewsStack,reuseView,currentView,originDirection,finalDirection);
        }
        NSLog(@"end");
    }];
}


-(void)setupInitPageVC{
    PageViewController *vc = [[PageViewController alloc] init];
    vc.index = 0;
    vc.view.backgroundColor = [UIColor greenColor];
    [self.animationController setupInitPageViewController:vc withFlipAnimationType:FlipAnimationType_cover];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XXSYFlipAnimationControllerDataSource
-(XXSYPageViewController*)flipAnimationController:(XXSYFlipAnimationController*)animationController refreshBeforePageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC{
    NSInteger index = [(PageViewController*)currentPageVC index];
    [(PageViewController*)reusePageVC setIndex:index-1];
    reusePageVC.view.backgroundColor = index%2==0?[UIColor redColor]:[UIColor whiteColor];
    //    reusePageVC.view.backgroundColor = [UIColor clearColor];
    return reusePageVC;
}


-(XXSYPageViewController*)flipAnimationController:(XXSYFlipAnimationController*)animationController refreshAfterPageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC{
    NSInteger index = [(PageViewController*)currentPageVC index];
    reusePageVC.view.backgroundColor = index%2==0?[UIColor redColor]:[UIColor whiteColor];
    [(PageViewController*)reusePageVC setIndex:index+1];
    //    reusePageVC.view.backgroundColor = [UIColor clearColor];
    
    return reusePageVC;
    
}



#pragma mark - XXSYFlipAnimationControllerDelegate

///弹出阅读菜单
-(void)flipAnimationControllerPopupMenu:(XXSYFlipAnimationController*)animationController{
    
}


/**
 * @brief 翻页结束时调用
 *
 * @param  animationController
 * @param  animation 翻页是否带动画效果
 * @param  completed 翻页是否完成
 *
 */
-(void)flipAnimationController:(XXSYFlipAnimationController*)animationController FlipFinishedHasAnimation:(BOOL)animation transitionCompleted:(BOOL)completed{
    
}

-(void)flipAnimationController:(XXSYFlipAnimationController *)animationController refreshScrollHeader:(UIView *)header andRefreshScrollFooter:(UIView *)footer withCurrentPageVC:(XXSYPageViewController *)currentPageVC{
    PageHeaderAndFooter *headerView = (PageHeaderAndFooter*)header;
    PageHeaderAndFooter *footerView = (PageHeaderAndFooter*)footer;
    PageViewController *vc = (PageViewController*)currentPageVC;
    
    [headerView drawString:[NSString stringWithFormat:@"%ld",vc.index]];
    [footerView drawString:[NSString stringWithFormat:@"%ld",vc.index]];
    
}

#pragma mark - auto read
- (IBAction)start:(id)sender {
    [self.animationController startAutoReadWithSpeed:30];
}
- (IBAction)stop:(id)sender {
    [self.animationController stopAutoRead];
}
- (IBAction)pause:(id)sender {
    [self.animationController pauseAutoRead];
}
- (IBAction)resume:(id)sender {
    [self.animationController resumeAutoRead];
}

- (IBAction)speed:(id)sender {
    [self.animationController setupSpeed:1];
}

- (IBAction)speedAdd:(id)sender {
    [self.animationController setupSpeed:60];
}


- (IBAction)exchangeFlipType:(UIButton *)sender {
    FlipAnimationType type = FlipAnimationType_scroll_V;
    int value = arc4random()%4;
    switch (value) {
        case 0:
            type = FlipAnimationType_cover;
            break;
        case 1:
            type = FlipAnimationType_scroll;
            break;
        case 2:
            type = FlipAnimationType_curl;
            break;
        default:
            break;
    }
    [self.animationController changeFlipAnimationType:type];
}

#pragma mark - ScrollVerticalFlipViewDataSource
-(XXSYPageViewController *)scrollVerticalView:(ScrollVerticalFlipView *)scrollView refreshAfterPageVCWithReusePageVC:(XXSYPageViewController *)reusePageVC withCurrentPageVC:(XXSYPageViewController *)currentPageVC{
    NSInteger index = [(PageViewController*)currentPageVC index];
    reusePageVC.view.backgroundColor = index%2==0?[UIColor redColor]:[UIColor whiteColor];
    [(PageViewController*)reusePageVC setIndex:index+1];
    return reusePageVC;
    
}

-(XXSYPageViewController *)scrollVerticalView:(ScrollVerticalFlipView *)scrollView refreshBeforePageVCWithReusePageVC:(XXSYPageViewController *)reusePageVC withCurrentPageVC:(XXSYPageViewController *)currentPageVC{
    NSInteger index = [(PageViewController*)currentPageVC index];
    [(PageViewController*)reusePageVC setIndex:index-1];
    reusePageVC.view.backgroundColor = index%2==0?[UIColor redColor]:[UIColor whiteColor];
    return reusePageVC;
}

#pragma mark - ScrollVerticalFlipViewDelegate
-(void)scrollVerticalView:(ScrollVerticalFlipView *)scrollView refreshScrollHeader:(UIView *)header andRefreshScrollFooter:(UIView *)footer withCurrentPageVC:(XXSYPageViewController *)currentPageVC{
    PageHeaderAndFooter *headerView = (PageHeaderAndFooter*)header;
    PageHeaderAndFooter *footerView = (PageHeaderAndFooter*)footer;
    PageViewController *vc = (PageViewController*)currentPageVC;
    
    [headerView drawString:[NSString stringWithFormat:@"%ld",vc.index]];
    [footerView drawString:[NSString stringWithFormat:@"%ld",vc.index]];

}


@end
