//
//  XXSYFlipAnimationController.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/2.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#define kDefaultPageVCCacheCount 3
#define kFlipAnimationSpeed 1000.0

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

#pragma mark - pan gesture
@property (nonatomic, assign) CGPoint startPanPoint;
@property (nonatomic, assign) CGPoint movePanPoint;
//手势开始移动的 Point
@property (nonatomic, assign) FlipAnimationDirection panAnimationDirection;
@property (assign,nonatomic) BOOL panFromLeftToRightIsAfter;
@property (assign,nonatomic) CGRect touchAnimationViewOriginRect;
@property (strong,nonatomic) PageAnimationView *touchAnimationView;
@property (strong,nonatomic) PageAnimationView *currentAnimationView;
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
-(NSArray*)childenPageControllers{
    return nil;
}

-(XXSYPageViewController*)currentPageVC{
    PageAnimationView *animationView = [self.reusePageAnimationViewArray firstObject];
    return animationView.pageVC;
}

-(void)setupInitPageViewController:(XXSYPageViewController*)pageVC withFlipAnimationType:(FlipAnimationType)animationType{
    if (!pageVC) {
        return;
    }
    [self movePageAnimationViewToFront:[[PageAnimationView alloc] initWithShadowPosion:[self pageShadowPosionWithFlipType:self.animationType] withPageVC:pageVC]];
    [self changeFlipAnimationType:animationType];
}
#pragma mark - init


#pragma mark - helpers
-(void)setupGestureRecognizers{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCallback:)];
    [pan setDelegate:self];
    [self.view addGestureRecognizer:pan];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureCallback:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    [tap requireGestureRecognizerToFail:pan];

}

#pragma mark - pageVC

-(XXSYPageViewController*)getReusePageVC{
    XXSYPageViewController *pageVC = nil;
    if (self.reusePageAnimationViewArray.count < self.reuseCacheCount) {
        pageVC = [[XXSYPageViewController alloc] init];
        [self.reusePageAnimationViewArray addObject:[[PageAnimationView alloc] initWithShadowPosion:[self pageShadowPosionWithFlipType:self.animationType] withPageVC:pageVC]];
        return pageVC;
    }
    PageAnimationView *aniamtionV = [self.reusePageAnimationViewArray lastObject];
    pageVC = aniamtionV.pageVC;
    return pageVC;
}

-(XXSYPageViewController*)getNeedLoadAfterPageVC{
    XXSYPageViewController *reusePageVC = [self getReusePageVC];
    XXSYPageViewController *currentPageVC = [self currentPageVC];
    [self setupReusePageVC:reusePageVC];
    XXSYPageViewController *pageVC = [self.dataSource flipAnimationController:self refreshAfterPageVCWithReusePageVC:reusePageVC withCurrentPageVC:currentPageVC];
    return pageVC;
}

-(XXSYPageViewController*)getNeedLoadBeforePageVC{
    XXSYPageViewController *reusePageVC = [self getReusePageVC];
    XXSYPageViewController *currentPageVC = [self currentPageVC];
    [self setupReusePageVC:reusePageVC];
    XXSYPageViewController *pageVC = [self.dataSource flipAnimationController:self refreshBeforePageVCWithReusePageVC:reusePageVC withCurrentPageVC:currentPageVC];
    return pageVC;
}

-(void)setupReusePageVC:(XXSYPageViewController*)pageVC{
    [pageVC clearAllPageData];
    
}

-(void)movePageAnimationViewToFront:(PageAnimationView*)animationView withFlipDirection:(FlipAnimationDirection)direction{
    UIViewController *pageVC = animationView.pageVC;
    if (![self.childViewControllers containsObject:pageVC]) {
        [pageVC willMoveToParentViewController:self];
        [self.view addSubview:animationView];
        animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addChildViewController:pageVC];
        [pageVC didMoveToParentViewController:self];
    }
    if (self.animationType == FlipAnimationType_cover && direction == FlipAnimationDirection_FromRightToLeft) {
        [self.view sendSubviewToBack:animationView];
    }else{
        [self.view bringSubviewToFront:animationView];
    }
    
    [animationView setShadowPosion:[self pageShadowPosionWithFlipType:self.animationType]];
    [self.reusePageAnimationViewArray removeObject:animationView];
    [self.reusePageAnimationViewArray insertObject:animationView atIndex:0];
}


#pragma mark - pagevc animation
-(void)pageVCAnimationBeginningWithNeedPageView:(PageAnimationView*)needPageView withCurrentPageView:(PageAnimationView*)pageView withFlipDirection:(FlipAnimationDirection)direction{
    _isFlipAnimating = YES;
    XXSYPageViewController *needPageVC = needPageView.pageVC;
    XXSYPageViewController *pageVC = pageView.pageVC;
    
    [needPageVC animationTypeChanged:self.animationType];
    [needPageVC flipAnimationStatusChanged:YES];
    [needPageVC currentPageVCChanged:YES];
    [needPageVC willMoveToFront];
    [self movePageAnimationViewToFront:needPageView withFlipDirection:direction];
    
    [pageVC willMoveToBack];
    [pageVC currentPageVCChanged:NO];

}

-(void)pageVCAnimationDidFinishedWithNeedPageView:(PageAnimationView*)needPageView withCurrentPageView:(PageAnimationView*)pageView withAnimationDirection:(FlipAnimationDirection)direction{
    _isFlipAnimating = NO;
    XXSYPageViewController *needPageVC = needPageView.pageVC;
    XXSYPageViewController *pageVC = pageView.pageVC;
    
    [needPageVC flipAnimationStatusChanged:NO];
    [needPageVC didMoveToFrontWithDirection:direction];
    
    [pageVC didMoveToBackWithDirection:direction];
}

-(void)pageVCAnimationDidCancelWithNeedPageView:(PageAnimationView*)needPageView withCurrentPageView:(PageAnimationView*)pageView{
    _isFlipAnimating = NO;
    XXSYPageViewController *needPageVC = needPageView.pageVC;
    XXSYPageViewController *pageVC = pageView.pageVC;
    
    [needPageVC currentPageVCChanged:YES];
    [needPageVC didCancelMoveToBack];
    
    [pageVC currentPageVCChanged:NO];
    [pageVC flipAnimationStatusChanged:NO];
    [pageVC didCancelMoveToFront];
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

-(void)tapGestureAfterAnimationBegining:(UITapGestureRecognizer *)tapGesture{
    XXSYPageViewController *needPageVC = [self getNeedLoadAfterPageVC];
    XXSYPageViewController *currentPageVC = [self currentPageVC];
    if (!needPageVC) {
        return;
    }
    [self pageVCAnimationBeginningWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withFlipDirection:FlipAnimationDirection_FromLeftToRight];
    self.customAnimationBeginStatusBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromLeftToRight);
    
    [tapGesture setEnabled:NO];
    CGFloat time = (CGFloat)CGRectGetWidth([[UIScreen mainScreen] bounds])/kFlipAnimationSpeed;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromLeftToRight,needPageVC.view.superview.frame,(CGPoint){CGRectGetWidth(self.view.bounds),0});
        
    } completion:^(BOOL finished) {
        
        [self pageVCAnimationDidFinishedWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromLeftToRight);
        
        //            //OR
        //            [self pageVCAnimationDidCancelWithNeedPageView:(PageAnimationView*)currentPageVC.view.superview withCurrentPageView:(PageAnimationView*)needPageVC.view.superview];
        
        [tapGesture setEnabled:YES];
        
        if (self.gestureCompletion) {
            self.gestureCompletion(self,tapGesture);
        }
    }];
}

-(void)tapGestureBeforeAnimationBegining:(UITapGestureRecognizer *)tapGesture{
    XXSYPageViewController *needPageVC = [self getNeedLoadBeforePageVC];
    XXSYPageViewController *currentPageVC = [self currentPageVC];
    if (!needPageVC) {
        return;
    }
    [self pageVCAnimationBeginningWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withFlipDirection:FlipAnimationDirection_FromRightToLeft];
    self.customAnimationBeginStatusBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromRightToLeft);
    
    [tapGesture setEnabled:NO];
    CGFloat time = (CGFloat)CGRectGetWidth([[UIScreen mainScreen] bounds])/kFlipAnimationSpeed;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromRightToLeft,needPageVC.view.superview.frame,(CGPoint){-CGRectGetWidth(self.view.bounds),0});
        
    } completion:^(BOOL finished) {
        
        [self pageVCAnimationDidFinishedWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withAnimationDirection:FlipAnimationDirection_FromRightToLeft];
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromRightToLeft);
        
        //            //OR
        //            [self pageVCAnimationDidCancelWithNeedPageView:(PageAnimationView*)currentPageVC.view.superview withCurrentPageView:(PageAnimationView*)needPageVC.view.superview];
        
        [tapGesture setEnabled:YES];
        
        if (self.gestureCompletion) {
            self.gestureCompletion(self,tapGesture);
        }
    }];
}

-(void)panGestureAfterAnimationWillBegin:(UIPanGestureRecognizer *)panGesture withFlipDirection:(FlipAnimationDirection)direction{
    XXSYPageViewController *needPageVC = [self getNeedLoadAfterPageVC];
    XXSYPageViewController *currentPageVC = [self currentPageVC];
    if (!needPageVC) {
        return;
    }
    [self pageVCAnimationBeginningWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withFlipDirection:direction];
    self.customAnimationBeginStatusBlock(self,self.reusePageAnimationViewArray,direction);
    self.touchAnimationView = (PageAnimationView*)needPageVC.view.superview;
    self.currentAnimationView = (PageAnimationView*)currentPageVC.view.superview;
}

-(void)panGestureAnimationFinished:(UIPanGestureRecognizer *)panGesture withFlipDirection:(FlipAnimationDirection)direction{
    XXSYPageViewController *needPageVC = self.touchAnimationView.pageVC;
    XXSYPageViewController *currentPageVC = self.currentAnimationView.pageVC;
    
    CGFloat time = (CGFloat)CGRectGetWidth([[UIScreen mainScreen] bounds])/kFlipAnimationSpeed;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromLeftToRight,needPageVC.view.superview.frame,(CGPoint){CGRectGetWidth(self.view.bounds),0});
        
    } completion:^(BOOL finished) {
        
        [self pageVCAnimationDidFinishedWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromLeftToRight);
        
        //            //OR
        //            [self pageVCAnimationDidCancelWithNeedPageView:(PageAnimationView*)currentPageVC.view.superview withCurrentPageView:(PageAnimationView*)needPageVC.view.superview];
        
        [self pageVCAnimationDidFinishedWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromLeftToRight);
        
        [panGesture.view setUserInteractionEnabled:YES];
        [panGesture setEnabled:YES];
        if (self.gestureCompletion) {
            self.gestureCompletion(self,panGesture);
        }
    }];
    
}

-(void)panGestureAnimationCancel:(UIPanGestureRecognizer *)panGesture withFlipDirection:(FlipAnimationDirection)direction{
    XXSYPageViewController *needPageVC = self.touchAnimationView.pageVC;
    XXSYPageViewController *currentPageVC = self.currentAnimationView.pageVC;
    
    [self pageVCAnimationDidFinishedWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
    self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromLeftToRight);
    
    [panGesture.view setUserInteractionEnabled:YES];
    [panGesture setEnabled:YES];
    if (self.gestureCompletion) {
        self.gestureCompletion(self,panGesture);
    }
}

-(void)panGestureBeforeAnimationWillBegin:(UIPanGestureRecognizer *)panGesture withFlipDirection:(FlipAnimationDirection)direction{
    XXSYPageViewController *needPageVC = [self getNeedLoadBeforePageVC];
    XXSYPageViewController *currentPageVC = [self currentPageVC];
    if (!needPageVC) {
        return;
    }
    [self pageVCAnimationBeginningWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withFlipDirection:direction];
    self.customAnimationBeginStatusBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromRightToLeft);
    
    [tapGesture setEnabled:NO];
    CGFloat time = (CGFloat)CGRectGetWidth([[UIScreen mainScreen] bounds])/kFlipAnimationSpeed;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromRightToLeft,needPageVC.view.superview.frame,(CGPoint){-CGRectGetWidth(self.view.bounds),0});
        
    } completion:^(BOOL finished) {
        
        [self pageVCAnimationDidFinishedWithNeedPageView:(PageAnimationView*)needPageVC.view.superview withCurrentPageView:(PageAnimationView*)currentPageVC.view.superview withAnimationDirection:FlipAnimationDirection_FromRightToLeft];
        self.customAnimationFinishedStatusBlock(self,self.reusePageAnimationViewArray,FlipAnimationDirection_FromRightToLeft);
        
        //            //OR
        //            [self pageVCAnimationDidCancelWithNeedPageView:(PageAnimationView*)currentPageVC.view.superview withCurrentPageView:(PageAnimationView*)needPageVC.view.superview];
        
        
        if (self.gestureCompletion) {
            self.gestureCompletion(self,tapGesture);
        }
    }];
}
#pragma mark - Gesture Handlers

-(void)tapGestureCallback:(UITapGestureRecognizer *)tapGesture{
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    if ([self.touchAfterBezierPath containsPoint:point]) {
        ///下翻页
        [self tapGestureAfterAnimationBegining:tapGesture];
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
        [self tapGestureBeforeAnimationBegining:tapGesture];
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
           
          CGRect beforeRect = CGPathGetBoundingBox(self.touchBeforeBezierPath.CGPath);
           CGRect afterRect = CGPathGetBoundingBox(self.touchAfterBezierPath.CGPath);
           self.panFromLeftToRightIsAfter = CGRectGetMinX(beforeRect) < CGRectGetMinX(afterRect);
           self.touchAnimationViewOriginRect = CGRectZero;
        }
            break;
        case UIGestureRecognizerStateChanged:
     {
        [panGesture.view setUserInteractionEnabled:NO];
        CGPoint point = [panGesture locationInView:nil];
        if (self.panAnimationDirection == FlipAnimationDirection_None) {
            
            if (point.x > self.startPanPoint.x) {
                self.panAnimationDirection = FlipAnimationDirection_FromLeftToRight;
            }else
            if (point.x < self.startPanPoint.x) {
                self.panAnimationDirection = FlipAnimationDirection_FromRightToLeft;
            }
            
            if (self.panAnimationDirection == FlipAnimationDirection_FromLeftToRight) {
                if (self.panFromLeftToRightIsAfter) {
                    [self panGestureAfterAnimationWillBegin:panGesture withFlipDirection:self.panAnimationDirection];
                }else{
                    [self panGestureBeforeAnimationWillBegin:panGesture withFlipDirection:self.panAnimationDirection];
                }
            }
            
            if (self.panAnimationDirection == FlipAnimationDirection_FromRightToLeft) {
                if (self.panFromLeftToRightIsAfter) {
                    [self panGestureBeforeAnimationWillBegin:panGesture withFlipDirection:self.panAnimationDirection];
                }else{
                    [self panGestureAfterAnimationWillBegin:panGesture withFlipDirection:self.panAnimationDirection];
                }
            }
            
            UIView *animationView = [self.reusePageAnimationViewArray firstObject];
            self.touchAnimationViewOriginRect = animationView.frame;
            
        }else{
            self.visualCustomAnimationBlock(self,self.reusePageAnimationViewArray,self.panAnimationDirection,self.touchAnimationViewOriginRect,[panGesture translationInView:nil]);
        }
        
        
        
        self.movePanPoint = point;
        
        CGPoint translatePoint = [panGesture translationInView:nil];
        if (translatePoint.x > 0) {
            
        }
        NSLog(@"%@",NSStringFromCGPoint(translatePoint));
     }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
     {
        CGPoint point = [panGesture locationInView:nil];
        if (point.x > self.movePanPoint.x) {
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

-(void)setCustomVisualAnimationBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect,CGPoint translatePoint))visualAnimationBlock
       withAnimationBeginStatusBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection))animationBeginStatus
          withAnimationFinishedBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection))animationFinishedStatus{
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
