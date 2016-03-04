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

@interface ViewController ()<XXSYFlipAnimationControllerDelegate,XXSYFlipAnimationControllerDataSource>
@property (strong,nonatomic) XXSYFlipAnimationController *animationController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _animationController = [[XXSYFlipAnimationController alloc] init];
    self.animationController.delegate = self;
    self.animationController.dataSource = self;
    
    self.animationController.view.backgroundColor = [UIColor redColor];
    [self.animationController willMoveToParentViewController:self];
    self.animationController.view.frame = self.view.bounds;
    self.animationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.animationController.view];
    [self addChildViewController:self.animationController];
    [self.animationController didMoveToParentViewController:self];
    
    [self setupFlipAnimationVCGesture];
    [self setupFlipAnimationVCTouchArea];
    [self setupFlipAnimationVCAnimationBlock];
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
    
    [self.animationController setTouchAfterAreaBezierPath:leftBezierPath];
    [self.animationController setTouchBeforeAreaBezierPath:rightBezierPath];
    [self.animationController setTouchCenterAreaBezierPath:centerBezierPath];
}

-(void)setupFlipAnimationVCAnimationBlock{
    [self.animationController setCustomVisualAnimationBlock:^(XXSYFlipAnimationController *animationController, NSArray *allAnimationViewsStack, FlipAnimationDirection animationDirection, CGRect currentViewOriginRect, CGPoint translatePoint) {
        VisualCustomAnimationBlock block = [FlipBookAnimationManager visualAnimatingCustomAnimationBlockWithFlipAnimationType:animationController.animationType];
        if (block) {
            block(animationController,allAnimationViewsStack,animationDirection,currentViewOriginRect,translatePoint);
        }
        NSLog(@"animating");
    } withAnimationBeginStatusBlock:^(XXSYFlipAnimationController *animationController, NSArray *allAnimationViewsStack, FlipAnimationDirection animationDirection) {
        CustomAnimationStatusBlock block = [FlipBookAnimationManager visualBeginCustomAnimationBlockWithFlipAnimationType:animationController.animationType];
        if (block) {
            block(animationController,allAnimationViewsStack,animationDirection);
        }
        NSLog(@"begin");
    } withAnimationFinishedBlock:^(XXSYFlipAnimationController *animationController, NSArray *allAnimationViewsStack, FlipAnimationDirection animationDirection) {
        CustomAnimationStatusBlock block = [FlipBookAnimationManager visualEndCustomAnimationBlockWithFlipAnimationType:animationController.animationType];
        if (block) {
            block(animationController,allAnimationViewsStack,animationDirection);
        }
        NSLog(@"end");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - XXSYFlipAnimationControllerDelegate

///弹出阅读菜单
-(void)flipAnimationControllerPopupMenu:(XXSYFlipAnimationController*)animationController{
    
}

#pragma mark - XXSYFlipAnimationControllerDataSource
-(XXSYPageViewController*)flipAnimationController:(XXSYFlipAnimationController*)animationController refreshBeforePageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC{
    
    return reusePageVC;
}


-(XXSYPageViewController*)flipAnimationController:(XXSYFlipAnimationController*)animationController refreshAfterPageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC{
    
    return reusePageVC;
    
}
@end
