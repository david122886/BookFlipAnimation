//
//  XXSYFlipAnimationController.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/2.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#define kDefaultPageVCCacheCount 2
#define kFlipAnimationSpeed 1500.0
#define kMinPanVelocity 5
#import "XXSYFlipAnimationController.h"
#import "XXSYPageViewController.h"
#import "PageAnimationView.h"


typedef BOOL (^XXSYFlipGestureShouldRecognizeTouchBlock)(XXSYFlipAnimationController * drawerController, UIGestureRecognizer * gesture, UITouch * touch);
typedef void (^XXSYFlipGestureCompletionBlock)(XXSYFlipAnimationController * drawerController, UIGestureRecognizer * gesture);

#pragma mark -




#pragma mark -


@interface XXSYFlipAnimationController ()<UIGestureRecognizerDelegate>
@property (strong,nonatomic) XXSYFlipGestureShouldRecognizeTouchBlock gestureShouldRecognizeTouch;
@property (strong,nonatomic) XXSYFlipGestureCompletionBlock gestureCompletion;
@property (strong,nonatomic) VisualCustomAnimationBlock visualCustomAnimationBlock;
@property (strong,nonatomic) CustomAnimationStatusBlock customAnimationBeginStatusBlock;
@property (strong,nonatomic) CustomAnimationStatusBlock customAnimationFinishedStatusBlock;
///缓存PageAnimationView，实现重复使用,index = 0表示最上面
@property (strong,nonatomic) NSMutableArray *reusePageAnimationViewArray;

@property (strong,nonatomic) Class currentPageVCClass;
#pragma mark - pan gesture
@property (nonatomic, assign) CGPoint startPanPoint;
@property (nonatomic, assign) CGPoint movePanPoint;
@property (strong,nonatomic) UIPanGestureRecognizer *panGesture;
//手势开始移动的 Point
@property (nonatomic, assign) FlipAnimationDirection panAnimationDirection;
@property (assign,nonatomic) CGRect touchAnimationViewOriginRect;
@property (strong,nonatomic) PageAnimationView *touchAnimationView;

@property (strong,nonatomic) PageAnimationView *tmpPanNeedPageAnimationView;
@property (strong,nonatomic) PageAnimationView *tmpPanCurrentPageAnimationView;

#pragma mark - auto read
@property (assign,nonatomic) FlipAnimationType tmpOldFlipTypeBeforeAutoRead;
@property (strong,nonatomic) CADisplayLink *autoReadTimer;
@property (assign,nonatomic) CGFloat autoReadSpeed;
@property (strong,nonatomic) PageAnimationView *autoReadAnimatingView;
@end

@implementation XXSYFlipAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupGestureRecognizers];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
-(void)registerPageVCForClass:(Class)pageVCClass{
    _currentPageVCClass = pageVCClass;
}

-(NSArray*)childenPageControllers{
    NSMutableArray *childern = @[].mutableCopy;
    for (PageAnimationView *sub in self.reusePageAnimationViewArray) {
        [childern addObject:sub.pageVC];
    }
    return childern;
}

-(XXSYPageViewController*)currentPageVC{
    PageAnimationView *animationView = [self getCurrentPageAnimationView];
    return animationView.pageVC;
}

-(void)setupInitPageViewController:(XXSYPageViewController*)pageVC withFlipAnimationType:(FlipAnimationType)animationType{
    if (!pageVC) {
        return;
    }
    _animationType = animationType;
    _isFlipAnimating = NO;
    PageAnimationView *needView = [[PageAnimationView alloc] initWithShadowPosion:[self pageShadowPosionWithFlipType:self.animationType] withPageVC:pageVC];
    
    [self movePageAnimationViewToParent:needView];
    [self.reusePageAnimationViewArray insertObject:needView atIndex:0];
    [self.view bringSubviewToFront:needView];
    [needView setShadowPosion:[self pageShadowPosionWithFlipType:self.animationType]];
    
    for (PageAnimationView *pageView in self.reusePageAnimationViewArray) {
        [pageView.pageVC animationTypeChanged:self.animationType];
        [pageView.pageVC flipAnimationStatusChanged:NO];

        if (pageView.pageVC != pageVC) {
            [pageView.pageVC currentPageVCChanged:NO];
            [pageView.pageVC willMoveToBack];
            [pageView.pageVC didMoveToBackWithDirection:FlipAnimationDirection_None];
        }else{
            [pageView.pageVC flipAnimationStatusChanged:NO];
            [pageView.pageVC currentPageVCChanged:YES];
            [pageView.pageVC willMoveToFront];
            [pageView.pageVC didMoveToFrontWithDirection:FlipAnimationDirection_None];
        }
    }
}
#pragma mark - init


#pragma mark - helpers
-(void)setupGestureRecognizers{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCallback:)];
    [pan setDelegate:self];
    [self.view addGestureRecognizer:pan];
    self.panGesture = pan;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureCallback:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    [tap requireGestureRecognizerToFail:pan];

}

#pragma mark - pageVC

-(PageAnimationView*)getReusePageAnimationView{
    if (self.reusePageAnimationViewArray.count < self.reuseCacheCount) {
        XXSYPageViewController *pageVC = [[self.currentPageVCClass alloc] init];
        PageAnimationView *aniamtionV = [[PageAnimationView alloc] initWithShadowPosion:[self pageShadowPosionWithFlipType:self.animationType] withPageVC:pageVC];
        [self.reusePageAnimationViewArray addObject:aniamtionV];
        [self movePageAnimationViewToParent:aniamtionV];
        
        return aniamtionV;
    }
    return [self.reusePageAnimationViewArray lastObject];
}

-(PageAnimationView*)getCurrentPageAnimationView{
    return [self.reusePageAnimationViewArray firstObject];
}

-(PageAnimationView*)getNeedLoadAfterPageAnimationView{
    PageAnimationView *reuseAnimationView = [self getReusePageAnimationView];
    PageAnimationView *currentAnimationView = [self getCurrentPageAnimationView];
    [self setupReusePageVC:reuseAnimationView.pageVC];
    XXSYPageViewController *pageVC = [self.dataSource flipAnimationController:self refreshAfterPageVCWithReusePageVC:reuseAnimationView.pageVC withCurrentPageVC:currentAnimationView.pageVC];
    return pageVC?reuseAnimationView:nil;
}

-(PageAnimationView*)getNeedLoadBeforePageAnimationView{
    PageAnimationView *reuseAnimationView = [self getReusePageAnimationView];
    PageAnimationView *currentAnimationView = [self getCurrentPageAnimationView];
    [self setupReusePageVC:reuseAnimationView.pageVC];
    XXSYPageViewController *pageVC = [self.dataSource flipAnimationController:self refreshBeforePageVCWithReusePageVC:reuseAnimationView.pageVC withCurrentPageVC:currentAnimationView.pageVC];
    return pageVC?reuseAnimationView:nil;
}

-(void)setupReusePageVC:(XXSYPageViewController*)pageVC{
    [pageVC clearAllPageData];
    
}
#pragma mark -  缓存操作
-(void)movePageAnimationViewToParent:(PageAnimationView*)animationView{
    UIViewController *pageVC = animationView.pageVC;
    if (![self.childViewControllers containsObject:pageVC]) {
        [pageVC willMoveToParentViewController:self];
        [self.view addSubview:animationView];
        [self.view sendSubviewToBack:animationView];
        animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addChildViewController:pageVC];
        [pageVC didMoveToParentViewController:self];
    }
}

#pragma mark - pagevc animation
-(void)pageVCAnimationBeginningWithNeedPageView:(PageAnimationView*)needPageView withCurrentPageView:(PageAnimationView*)pageView{
    _isFlipAnimating = YES;
    XXSYPageViewController *needPageVC = needPageView.pageVC;
    XXSYPageViewController *pageVC = pageView.pageVC;
    
    if (![self.childViewControllers containsObject:needPageVC]) {
        [needPageVC willMoveToParentViewController:self];
        [self.view addSubview:needPageView];
        needPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addChildViewController:needPageVC];
        [needPageVC didMoveToParentViewController:self];
    }
    
    [needPageVC animationTypeChanged:self.animationType];
    [needPageVC flipAnimationStatusChanged:YES];
    [needPageVC currentPageVCChanged:YES];
    [needPageVC willMoveToFront];
    
    [pageVC willMoveToBack];
    [pageVC currentPageVCChanged:NO];
    [pageVC animationTypeChanged:self.animationType];
    [pageVC flipAnimationStatusChanged:YES];
}

-(void)pageVCAnimationDidFinishedWithNeedPageView:(PageAnimationView*)needPageView withCurrentPageView:(PageAnimationView*)pageView withAnimationDirection:(FlipAnimationDirection)direction{
    _isFlipAnimating = NO;
    XXSYPageViewController *needPageVC = needPageView.pageVC;
    XXSYPageViewController *pageVC = pageView.pageVC;
    
    [needPageVC currentPageVCChanged:YES];
    [needPageVC flipAnimationStatusChanged:NO];
    [needPageVC didMoveToFrontWithDirection:direction];
    
    [pageVC currentPageVCChanged:NO];
    [pageVC flipAnimationStatusChanged:NO];
    [pageVC didMoveToBackWithDirection:direction];
}

-(void)pageVCAnimationDidCancelWithNeedPageView:(PageAnimationView*)needPageView withCurrentPageView:(PageAnimationView*)pageView{
    _isFlipAnimating = NO;
    XXSYPageViewController *needPageVC = needPageView.pageVC;
    XXSYPageViewController *pageVC = pageView.pageVC;
    
    [needPageVC currentPageVCChanged:NO];
    [needPageVC flipAnimationStatusChanged:NO];
    [needPageVC didCancelMoveToFront];
    
    [pageVC currentPageVCChanged:YES];
    [pageVC flipAnimationStatusChanged:NO];
    [pageVC didCancelMoveToBack];
}


-(PageAnimationViewShadowPosition)pageShadowPosionWithFlipType:(FlipAnimationType)flipType{
    if (flipType == FlipAnimationType_auto) {
        return ShadowPosion_Bottom;
    }
    if (flipType == FlipAnimationType_cover) {
        return ShadowPosion_Right;
    }
    return ShadowPosion_None;
}

#pragma mark - Gesture Helpers
-(void)tapGestureBeforeAnimationBegining:(UITapGestureRecognizer *)tapGesture{
//    XXSYPageViewController *needPageVC = [self touchFromLeftToRightIsAfter]?[self getNeedLoadBeforePageVC]:[self getNeedLoadAfterPageVC];
//    XXSYPageViewController *currentPageVC = [self currentPageVC];
    PageAnimationView *needPageAnimationView = [self touchFromLeftToRightIsAfter]?[self getNeedLoadBeforePageAnimationView]:[self getNeedLoadAfterPageAnimationView];
    PageAnimationView *currentPageAnimationView = [self getCurrentPageAnimationView];
    if (!needPageAnimationView) {
        return;
    }
    
    self.customAnimationBeginStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,FlipAnimationDirection_FromLeftToRight,FlipAnimationDirection_FromLeftToRight);
    
    [self pageVCAnimationBeginningWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView];

    
    
    [tapGesture setEnabled:NO];
    CGFloat time = (CGFloat)CGRectGetWidth([[UIScreen mainScreen] bounds])/kFlipAnimationSpeed;
    CGRect originRect;
    if (self.animationType == FlipAnimationType_cover) {
        originRect = needPageAnimationView.frame;
    }
    if (self.animationType == FlipAnimationType_scroll) {
        originRect = currentPageAnimationView.frame;
    }
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromLeftToRight,FlipAnimationDirection_FromLeftToRight,originRect,(CGPoint){CGRectGetWidth(self.view.bounds),0});
        
    } completion:^(BOOL finished) {
        
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,FlipAnimationDirection_FromLeftToRight,FlipAnimationDirection_FromLeftToRight);
        
        [self pageVCAnimationDidFinishedWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView withAnimationDirection:FlipAnimationDirection_FromLeftToRight];

        [tapGesture setEnabled:YES];
        
        if (self.gestureCompletion) {
            self.gestureCompletion(self,tapGesture);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(flipAnimationController:FlipFinishedHasAnimation:transitionCompleted:)]) {
            [self.delegate flipAnimationController:self FlipFinishedHasAnimation:YES transitionCompleted:YES];
        }
    }];
}

-(void)tapGestureAfterAnimationBegining:(UITapGestureRecognizer *)tapGesture{
//    XXSYPageViewController *needPageVC = [self touchFromLeftToRightIsAfter]?[self getNeedLoadAfterPageVC]:[self getNeedLoadBeforePageVC];
//    XXSYPageViewController *currentPageVC = [self currentPageVC];
    PageAnimationView *needPageAnimationView = [self touchFromLeftToRightIsAfter]?[self getNeedLoadAfterPageAnimationView]:[self getNeedLoadBeforePageAnimationView];
    PageAnimationView *currentPageAnimationView = [self getCurrentPageAnimationView];
    if (!needPageAnimationView) {
        return;
    }
    
    self.customAnimationBeginStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,FlipAnimationDirection_FromRightToLeft,FlipAnimationDirection_FromRightToLeft);
    
    [self pageVCAnimationBeginningWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView];
    
    [tapGesture setEnabled:NO];
    CGFloat time = (CGFloat)CGRectGetWidth([[UIScreen mainScreen] bounds])/kFlipAnimationSpeed;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromRightToLeft,FlipAnimationDirection_FromRightToLeft,currentPageAnimationView.frame,(CGPoint){-CGRectGetWidth(self.view.bounds),0});
        
    } completion:^(BOOL finished) {
        
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,FlipAnimationDirection_FromRightToLeft,FlipAnimationDirection_FromRightToLeft);
        
        [self pageVCAnimationDidFinishedWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView withAnimationDirection:FlipAnimationDirection_FromRightToLeft];
        
        [tapGesture setEnabled:YES];
        
        if (self.gestureCompletion) {
            self.gestureCompletion(self,tapGesture);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(flipAnimationController:FlipFinishedHasAnimation:transitionCompleted:)]) {
            [self.delegate flipAnimationController:self FlipFinishedHasAnimation:YES transitionCompleted:YES];
        }
    }];
}

-(BOOL)panGestureAfterAnimationWillBegin:(UIPanGestureRecognizer *)panGesture withFlipDirection:(FlipAnimationDirection)direction{
//    XXSYPageViewController *needPageVC = [self touchFromLeftToRightIsAfter]?[self getNeedLoadAfterPageVC]:[self getNeedLoadBeforePageVC];
//    XXSYPageViewController *currentPageVC = [self currentPageVC];
    PageAnimationView *needPageAnimationView = [self touchFromLeftToRightIsAfter]?[self getNeedLoadAfterPageAnimationView]:[self getNeedLoadBeforePageAnimationView];
    PageAnimationView *currentPageAnimationView = [self getCurrentPageAnimationView];
    
    if (!needPageAnimationView) {
        return NO;
    }
    
    self.tmpPanNeedPageAnimationView = needPageAnimationView;
    self.tmpPanCurrentPageAnimationView = currentPageAnimationView;
    if (self.animationType == FlipAnimationType_cover) {
        if (direction == FlipAnimationDirection_FromRightToLeft) {
            self.touchAnimationView = currentPageAnimationView;
        }else{
            self.touchAnimationView = needPageAnimationView;
        }
    }
    if (self.animationType == FlipAnimationType_scroll) {
        self.touchAnimationView = currentPageAnimationView;
    }

    self.customAnimationBeginStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,direction,direction);
    
    [self pageVCAnimationBeginningWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView];

    return YES;
}

-(BOOL)panGestureBeforeAnimationWillBegin:(UIPanGestureRecognizer *)panGesture withFlipDirection:(FlipAnimationDirection)direction{
//    XXSYPageViewController *needPageVC = [self touchFromLeftToRightIsAfter]?[self getNeedLoadBeforePageVC]:[self getNeedLoadAfterPageVC];
//    XXSYPageViewController *currentPageVC = [self currentPageVC];
    PageAnimationView *needPageAnimationView = [self touchFromLeftToRightIsAfter]?[self getNeedLoadBeforePageAnimationView]:[self getNeedLoadAfterPageAnimationView];
    PageAnimationView *currentPageAnimationView = [self getCurrentPageAnimationView];
    if (!needPageAnimationView) {
        return NO;
    }
    
    self.tmpPanNeedPageAnimationView = needPageAnimationView;
    self.tmpPanCurrentPageAnimationView = currentPageAnimationView;
    if (self.animationType == FlipAnimationType_cover) {
        if (self.animationType == FlipAnimationType_cover && direction == FlipAnimationDirection_FromRightToLeft) {
            self.touchAnimationView = currentPageAnimationView;
        }else{
            self.touchAnimationView = needPageAnimationView;
        }
    }
    if (self.animationType == FlipAnimationType_scroll) {
        self.touchAnimationView = currentPageAnimationView;
    }
    
    self.customAnimationBeginStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,direction,direction);
    
    [self pageVCAnimationBeginningWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView];

    return YES;
}

-(void)panGestureAnimationFinished:(UIPanGestureRecognizer *)panGesture withFlipDirection:(FlipAnimationDirection)direction{
    CGFloat time = 0;
    CGPoint finalTranslatePoint;
    if (self.animationType == FlipAnimationType_cover) {
        if (direction == FlipAnimationDirection_FromRightToLeft) {
            time = (CGFloat)ABS(CGRectGetMaxX(self.touchAnimationView.frame))/kFlipAnimationSpeed;
        }else{
            time = (CGFloat)ABS(CGRectGetMinX(self.touchAnimationView.frame))/kFlipAnimationSpeed;
        }
        CGRect finalRect = direction == FlipAnimationDirection_FromLeftToRight?self.touchAnimationView.bounds:CGRectOffset(self.touchAnimationView.bounds, -CGRectGetWidth(self.touchAnimationView.frame), 0);
        finalTranslatePoint = (CGPoint){CGRectGetMinX(finalRect) - CGRectGetMinX(self.touchAnimationView.frame),0};
    }
    
    if (self.animationType == FlipAnimationType_scroll) {
        if (direction == FlipAnimationDirection_FromRightToLeft) {
            time = (CGFloat)ABS(CGRectGetMaxX(self.touchAnimationView.frame))/kFlipAnimationSpeed;
        }else{
            time = (CGFloat)ABS(CGRectGetWidth(self.touchAnimationView.frame)-CGRectGetMinX(self.touchAnimationView.frame))/kFlipAnimationSpeed;
        }
        CGRect finalRect = direction == FlipAnimationDirection_FromLeftToRight?CGRectOffset(self.touchAnimationView.bounds,CGRectGetWidth(self.touchAnimationView.frame), 0):CGRectOffset(self.touchAnimationView.bounds, -CGRectGetWidth(self.touchAnimationView.frame), 0);
        finalTranslatePoint = (CGPoint){CGRectGetMinX(finalRect) - CGRectGetMinX(self.touchAnimationView.frame),0};
    }

    
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,self.panAnimationDirection,direction,self.touchAnimationView.frame,finalTranslatePoint);
        
    } completion:^(BOOL finished) {
        PageAnimationView *needPageAnimationView = self.tmpPanNeedPageAnimationView;
        PageAnimationView *currentPageAnimationView = self.tmpPanCurrentPageAnimationView;
        
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,direction,direction);
        
        [self pageVCAnimationDidFinishedWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView withAnimationDirection:direction];


        [panGesture.view setUserInteractionEnabled:YES];
        [panGesture setEnabled:YES];
        if (self.gestureCompletion) {
            self.gestureCompletion(self,panGesture);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(flipAnimationController:FlipFinishedHasAnimation:transitionCompleted:)]) {
            [self.delegate flipAnimationController:self FlipFinishedHasAnimation:YES transitionCompleted:YES];
        }
        
    }];
    
}

-(void)panGestureAnimationCancel:(UIPanGestureRecognizer *)panGesture withFlipDirection:(FlipAnimationDirection)direction{
    
    CGFloat time = 0;
    CGPoint finalTranslatePoint;
    if (self.animationType == FlipAnimationType_cover) {
        if (direction == FlipAnimationDirection_FromRightToLeft) {
            time = (CGFloat)ABS(CGRectGetMaxX(self.touchAnimationView.frame))/kFlipAnimationSpeed;
        }else{
            time = (CGFloat)ABS(CGRectGetMinX(self.touchAnimationView.frame))/kFlipAnimationSpeed;
        }
        CGRect finalRect = direction == FlipAnimationDirection_FromLeftToRight?self.touchAnimationView.bounds:CGRectOffset(self.touchAnimationView.bounds, -CGRectGetWidth(self.touchAnimationView.frame), 0);
        finalTranslatePoint = (CGPoint){CGRectGetMinX(finalRect) - CGRectGetMinX(self.touchAnimationView.frame),0};
    }
    
    if (self.animationType == FlipAnimationType_scroll) {
        time = (CGFloat)ABS(CGRectGetMinX(self.touchAnimationView.frame))/kFlipAnimationSpeed;
        finalTranslatePoint = (CGPoint){CGRectGetMinX(self.touchAnimationView.bounds) - CGRectGetMinX(self.touchAnimationView.frame),0};
    }

    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,self.panAnimationDirection,direction,self.touchAnimationView.frame,finalTranslatePoint);
        
    } completion:^(BOOL finished) {
        PageAnimationView *needPageAnimationView = self.tmpPanNeedPageAnimationView;
        PageAnimationView *currentPageAnimationView = self.tmpPanCurrentPageAnimationView;
        
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,self.panAnimationDirection,direction);
        
        [self pageVCAnimationDidCancelWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView];

        [panGesture.view setUserInteractionEnabled:YES];
        [panGesture setEnabled:YES];
        if (self.gestureCompletion) {
            self.gestureCompletion(self,panGesture);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(flipAnimationController:FlipFinishedHasAnimation:transitionCompleted:)]) {
            [self.delegate flipAnimationController:self FlipFinishedHasAnimation:YES transitionCompleted:NO];
        }
        
    }];
    
}


#pragma mark - Gesture Handlers

-(BOOL)touchFromLeftToRightIsAfter{
    CGRect beforeRect = CGPathGetBoundingBox(self.touchBeforeBezierPath.CGPath);
    CGRect afterRect = CGPathGetBoundingBox(self.touchAfterBezierPath.CGPath);
    return CGRectGetMinX(beforeRect) < CGRectGetMinX(afterRect);
}

-(void)tapGestureCallback:(UITapGestureRecognizer *)tapGesture{
    if (self.animationType == FlipAnimationType_auto) {
        if (self.autoReadStatus == AutoReadStatus_pause) {
            [self resumeAutoRead];
            return;
        }
        if (self.autoReadStatus == AutoReadStatus_beginning) {
            [self pauseAutoRead];
            return;
        }
        return;
    }
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    if ([self.touchAfterBezierPath containsPoint:point]) {
        ///下翻页
        if ([self touchFromLeftToRightIsAfter]) {
            [self tapGestureAfterAnimationBegining:tapGesture];
        }else{
            [self tapGestureBeforeAnimationBegining:tapGesture];

        }
        return;
    }
    
    if ([self.touchCenterBezierPath containsPoint:point]) {
        ///中
        if (self.delegate && [self.delegate respondsToSelector:@selector(flipAnimationControllerPopupMenu:)]) {
            [self.delegate flipAnimationControllerPopupMenu:self];
        }
        return;
    }
    
    if ([self.touchBeforeBezierPath containsPoint:point]) {
        ///上翻页
        if ([self touchFromLeftToRightIsAfter]) {
            [self tapGestureBeforeAnimationBegining:tapGesture];
        }else{
            [self tapGestureAfterAnimationBegining:tapGesture];
        }
        return;
    }
    
}

-(void)panGestureCallback:(UIPanGestureRecognizer *)panGesture{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
           if (self.isFlipAnimating) {
               
               [panGesture setEnabled:NO];
               return;
           }
           self.panAnimationDirection = FlipAnimationDirection_None;
           self.startPanPoint = self.movePanPoint = [panGesture locationInView:nil];
           self.touchAnimationView = nil;
            self.tmpPanCurrentPageAnimationView = nil;
            self.tmpPanNeedPageAnimationView = nil;
            
           self.touchAnimationViewOriginRect = CGRectZero;
        }
            break;
        case UIGestureRecognizerStateChanged:
     {
        [panGesture.view setUserInteractionEnabled:NO];
        CGPoint point = [panGesture velocityInView:nil];
        if (self.panAnimationDirection == FlipAnimationDirection_None) {
            
            if (point.x > kMinPanVelocity) {
                self.panAnimationDirection = FlipAnimationDirection_FromLeftToRight;
                BOOL panGestureValid = [self panGestureBeforeAnimationWillBegin:panGesture withFlipDirection:self.panAnimationDirection];
                if (!panGestureValid) {
                    self.panAnimationDirection = FlipAnimationDirection_Other;
                }
            }else
            if (point.x < -kMinPanVelocity) {
                self.panAnimationDirection = FlipAnimationDirection_FromRightToLeft;
                BOOL panGestureValid = [self panGestureAfterAnimationWillBegin:panGesture withFlipDirection:self.panAnimationDirection];
                if (!panGestureValid) {
                    self.panAnimationDirection = FlipAnimationDirection_Other;
                }
            }
            
            UIView *animationView = [self.reusePageAnimationViewArray firstObject];
            self.touchAnimationViewOriginRect = animationView.frame;
            
        }else{
            if (self.panAnimationDirection != FlipAnimationDirection_Other) {
                self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,self.panAnimationDirection,self.panAnimationDirection,self.touchAnimationViewOriginRect,[panGesture translationInView:nil]);
            }
        }

        self.movePanPoint = point;
     }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
     {
         if (self.panAnimationDirection == FlipAnimationDirection_Other) {
             return;
         }
        CGPoint point = [panGesture velocityInView:nil];
        if (point.x > kMinPanVelocity) {
            if (self.panAnimationDirection == FlipAnimationDirection_FromLeftToRight) {
                [self panGestureAnimationFinished:panGesture withFlipDirection:FlipAnimationDirection_FromLeftToRight];
            }
            if (self.panAnimationDirection == FlipAnimationDirection_FromRightToLeft) {
                [self panGestureAnimationCancel:panGesture withFlipDirection:FlipAnimationDirection_FromLeftToRight];
            }
        }else{
            if (self.panAnimationDirection == FlipAnimationDirection_FromLeftToRight) {
                [self panGestureAnimationCancel:panGesture withFlipDirection:FlipAnimationDirection_FromRightToLeft];
            }
            if (self.panAnimationDirection == FlipAnimationDirection_FromRightToLeft) {
                [self panGestureAnimationFinished:panGesture withFlipDirection:FlipAnimationDirection_FromRightToLeft];
            }
        }
        
     }
            break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && (!self.touchBeforeBezierPath || !self.touchCenterBezierPath || !self.touchAfterBezierPath)) {
        return NO;
    }
    
    if (self.gestureShouldRecognizeTouch) {
        return self.gestureShouldRecognizeTouch(self,gestureRecognizer,touch);
    }
    return NO;
}

#pragma mark - 自动翻页设置
-(void)startAutoReadWithSpeed:(CGFloat)speed{
    if (self.autoReadStatus == AutoReadStatus_beginning || self.autoReadStatus == AutoReadStatus_pause) {
        return;
    }
    self.autoReadSpeed = speed;
    _tmpOldFlipTypeBeforeAutoRead = self.animationType;
    [self changeFlipAnimationType:FlipAnimationType_auto];
    
    if (self.autoReadTimer) {
        [self.autoReadTimer invalidate];
    }
    self.autoReadTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoReadTimer:)];
    self.autoReadTimer.frameInterval = self.autoReadSpeed <= 0.0?60/30:60/self.autoReadSpeed;
    
    _autoReadStatus = AutoReadStatus_beginning;
    [self.autoReadTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.panGesture setEnabled:NO];
}

-(void)stopAutoRead{
    if (self.autoReadTimer) {
        [self.autoReadTimer invalidate];
    }
    self.autoReadTimer = nil;
    
    if (self.autoReadStatus == AutoReadStatus_stop) {
        return;
    }
    
    _autoReadStatus = AutoReadStatus_stop;
    PageAnimationView *needPageAnimationView = self.tmpPanNeedPageAnimationView;
    PageAnimationView *currentPageAnimationView = self.tmpPanCurrentPageAnimationView;
    if (!needPageAnimationView) {
        NSAssert(NO, @"自动阅读还没有开始，不存在结束");
        return;
    }
    
    self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,FlipAnimationDirection_FromLeftToRight,FlipAnimationDirection_FromLeftToRight);
    
    [self pageVCAnimationDidFinishedWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
    
    self.autoReadAnimatingView = nil;
    
    [self changeFlipAnimationType:self.tmpOldFlipTypeBeforeAutoRead];
    _tmpOldFlipTypeBeforeAutoRead = FlipAnimationType_auto;
    
    [self.panGesture setEnabled:YES];

}

-(void)pauseAutoRead{
    if (self.autoReadTimer && !self.autoReadTimer.paused) {
        self.autoReadTimer.paused = YES;
    }
    _autoReadStatus = AutoReadStatus_pause;
    
    [self.panGesture setEnabled:NO];
}

-(void)resumeAutoRead{
    if (self.autoReadTimer && self.autoReadTimer.paused) {
        self.autoReadTimer.paused = NO;
    }
    _autoReadStatus = AutoReadStatus_beginning;
    
    [self.panGesture setEnabled:NO];
}

-(void)setupSpeed:(CGFloat)speed{
    self.autoReadSpeed = speed;
    if (self.autoReadTimer) {
        self.autoReadTimer.frameInterval = self.autoReadSpeed <= 0.0?60/30:60/self.autoReadSpeed;
    }
}


-(void)autoReadTimer:(CADisplayLink*)dispalyLink{
    if (!self.autoReadAnimatingView) {
        PageAnimationView *needPageAnimationView = [self getNeedLoadAfterPageAnimationView];
        PageAnimationView *currentPageAnimationView = [self getCurrentPageAnimationView];
        self.tmpPanNeedPageAnimationView = needPageAnimationView;
        self.tmpPanCurrentPageAnimationView = currentPageAnimationView;
        
        if (!needPageAnimationView) {
            _autoReadStatus = AutoReadStatus_pause;
            self.autoReadTimer.paused = YES;
            return;
        }
        
        self.customAnimationBeginStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,FlipAnimationDirection_FromLeftToRight,FlipAnimationDirection_FromLeftToRight);
        
        [self pageVCAnimationBeginningWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView];
        
        
        self.autoReadAnimatingView = needPageAnimationView;
        
        return;
    }
    
    if (CGRectGetHeight(self.autoReadAnimatingView.bounds) > CGRectGetHeight(self.view.frame)+kShadowWidth) {
        PageAnimationView *needPageAnimationView = self.tmpPanNeedPageAnimationView;
        PageAnimationView *currentPageAnimationView = self.tmpPanCurrentPageAnimationView;
        if (!needPageAnimationView) {
            NSAssert(NO, @"自动阅读还没有开始，不存在结束");
            return;
        }
        
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,needPageAnimationView,currentPageAnimationView,FlipAnimationDirection_FromLeftToRight,FlipAnimationDirection_FromLeftToRight);
        
        [self pageVCAnimationDidFinishedWithNeedPageView:needPageAnimationView withCurrentPageView:currentPageAnimationView withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
        
        self.autoReadAnimatingView = nil;
        return;
    }
    
    
    self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromLeftToRight,FlipAnimationDirection_FromLeftToRight,self.autoReadAnimatingView.frame,(CGPoint){0,1});

}
#pragma mark - setter

-(void)setGestureCompletionBlock:(void(^)(XXSYFlipAnimationController * flipAnimationController, UIGestureRecognizer * gesture))gestureCompletionBlock{
    _gestureCompletion = gestureCompletionBlock;
}

-(void)setGestureShouldRecognizeTouchBlock:(BOOL(^)(XXSYFlipAnimationController * flipAnimationController, UIGestureRecognizer * gesture, UITouch * touch))gestureShouldRecognizeTouchBlock{
    _gestureShouldRecognizeTouch = gestureShouldRecognizeTouchBlock;
}

-(void)setTouchBeforeAreaBezierPath:(UIBezierPath*)bezierPath{
    _touchBeforeBezierPath = bezierPath;
}
-(void)setTouchAfterAreaBezierPath:(UIBezierPath*)bezierPath{
    _touchAfterBezierPath = bezierPath;
}
-(void)setTouchCenterAreaBezierPath:(UIBezierPath*)bezierPath{
    _touchCenterBezierPath = bezierPath;
}

-(void)changeFlipAnimationType:(FlipAnimationType)animationType{
    _animationType = animationType;
    for (PageAnimationView *pageView in self.reusePageAnimationViewArray) {
        [pageView.pageVC animationTypeChanged:animationType];
    }
}

-(void)setCustomVisualAnimationBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection,CGRect currentViewOriginRect,CGPoint translatePoint))visualAnimationBlock
       withAnimationBeginStatusBlock:(void (^)(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection))animationBeginStatus
          withAnimationFinishedBlock:(void (^)(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection))animationFinishedStatus{
    _visualCustomAnimationBlock = visualAnimationBlock;
    _customAnimationBeginStatusBlock = animationBeginStatus;
    _customAnimationFinishedStatusBlock = animationFinishedStatus;
}
#pragma mark - property
-(NSMutableArray *)reusePageAnimationViewArray{
    if (!_reusePageAnimationViewArray) {
        _reusePageAnimationViewArray = @[].mutableCopy;
    }
    return _reusePageAnimationViewArray;
}

-(NSInteger)reuseCacheCount{
    if (_reuseCacheCount <= 0) {
        _reuseCacheCount = kDefaultPageVCCacheCount;
        return _reuseCacheCount;
    }
    return _reuseCacheCount;
}
@end
