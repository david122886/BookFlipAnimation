//
//  XXSYFlipAnimationController.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/2.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#define kDefaultPageVCCacheCount 3

#import "XXSYFlipAnimationController.h"
#import "XXSYPageViewController.h"
typedef BOOL (^XXSYFlipGestureShouldRecognizeTouchBlock)(XXSYFlipAnimationController * drawerController, UIGestureRecognizer * gesture, UITouch * touch);
typedef void (^XXSYFlipGestureCompletionBlock)(XXSYFlipAnimationController * drawerController, UIGestureRecognizer * gesture);
typedef void (^VisualCustomAnimationBlock)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect);
@interface XXSYFlipAnimationController ()<UIGestureRecognizerDelegate>
@property (strong,nonatomic) XXSYFlipGestureShouldRecognizeTouchBlock gestureShouldRecognizeTouch;
@property (strong,nonatomic) XXSYFlipGestureCompletionBlock gestureCompletion;
@property (strong,nonatomic) VisualCustomAnimationBlock visualCustomAnimationBlock;
///缓存PageVC，实现重复使用,index = 0表示最上面
@property (strong,nonatomic) NSMutableArray *reusePageVCArray;

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
    return [self.reusePageVCArray firstObject];
}

-(void)setupInitPageViewController:(XXSYPageViewController*)pageVC withFlipAnimationType:(FlipAnimationType)animationType{
    if (!pageVC) {
        return;
    }
    [self movePageVCToFront:pageVC];
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
}

#pragma mark - pageVC

-(XXSYPageViewController*)getReusePageVC{
    XXSYPageViewController *pageVC = nil;
    if (self.reusePageVCArray.count < self.reuseCacheCount) {
        pageVC = [[XXSYPageViewController alloc] init];
        [self.reusePageVCArray addObject:pageVC];
        return pageVC;
    }
    pageVC = [self.reusePageVCArray lastObject];
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

-(void)movePageVCToFront:(XXSYPageViewController*)pageVC{
    if (![self.childViewControllers containsObject:pageVC]) {
        [pageVC willMoveToParentViewController:self];
        pageVC.view.frame = self.view.bounds;
        [self.view addSubview:pageVC.view];
        pageVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addChildViewController:pageVC];
        [pageVC didMoveToParentViewController:self];
    }
    [self.view bringSubviewToFront:pageVC.view];
    
    [self.reusePageVCArray removeObject:pageVC];
    [self.reusePageVCArray insertObject:pageVC atIndex:0];
}

#pragma mark - pagevc animation
-(void)pageVCAnimationBeginningWithNeedPageVC:(XXSYPageViewController*)needPageVC withCurrentPageVC:(XXSYPageViewController*)pageVC{
    _isFlipAnimating = YES;
    [needPageVC animationTypeChanged:self.animationType];
    [needPageVC flipAnimationStatusChanged:YES];
    [needPageVC currentPageVCChanged:YES];
    [needPageVC willMoveToFront];
    [self movePageVCToFront:needPageVC];
    
    [pageVC willMoveToBack];
    [pageVC currentPageVCChanged:NO];

}

-(void)pageVCAnimationDidFinishedWithNeedPageVC:(XXSYPageViewController*)needPageVC withCurrentPageVC:(XXSYPageViewController*)pageVC withAnimationDirection:(FlipAnimationDirection)direction{
    _isFlipAnimating = NO;
    [needPageVC flipAnimationStatusChanged:NO];
    [needPageVC didMoveToFrontWithDirection:direction];
    
    [pageVC didMoveToBackWithDirection:direction];
}

-(void)pageVCAnimationDidCancelWithNeedPageVC:(XXSYPageViewController*)needPageVC withCurrentPageVC:(XXSYPageViewController*)pageVC{
    _isFlipAnimating = NO;
//    [needPageVC flipAnimationStatusChanged:NO];
    [needPageVC currentPageVCChanged:YES];
    [needPageVC didCancelMoveToBack];
    
    [pageVC currentPageVCChanged:NO];
    [pageVC flipAnimationStatusChanged:NO];
    [pageVC didCancelMoveToFront];
}
#pragma mark - Gesture Handlers

-(void)tapGestureCallback:(UITapGestureRecognizer *)tapGesture{
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    if ([self.touchAfterBezierPath containsPoint:point]) {
        ///下翻页
        XXSYPageViewController *needPageVC = [self getNeedLoadAfterPageVC];
        XXSYPageViewController *currentPageVC = [self currentPageVC];
        if (!needPageVC) {
            return;
        }
        [self pageVCAnimationBeginningWithNeedPageVC:needPageVC withCurrentPageVC:currentPageVC];
        [UIView animateWithDuration:0.5 animations:^{
            
        } completion:^(BOOL finished) {
            [self pageVCAnimationDidFinishedWithNeedPageVC:needPageVC withCurrentPageVC:currentPageVC withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
            //OR
            [self pageVCAnimationDidCancelWithNeedPageVC:currentPageVC withCurrentPageVC:needPageVC];
        }];
        
        return;
    }
    if ([self.touchCenterBezierPath containsPoint:point]) {
        ///中
        
        return;
    }
    if ([self.touchBeforeBezierPath containsPoint:point]) {
        ///上翻页
        XXSYPageViewController *needPageVC = [self getNeedLoadBeforePageVC];
        if (!needPageVC) {
            return;
        }
        
        return;
    }
}

-(void)panGestureCallback:(UIPanGestureRecognizer *)panGesture{
    
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (!self.touchBeforeBezierPath || !self.touchCenterBezierPath || !self.touchAfterBezierPath) {
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
    for (XXSYPageViewController *pageVC in self.reusePageVCArray) {
        [pageVC animationTypeChanged:animationType];
    }
}

-(void)setCustomVisualAnimationBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection animationDirection,CGRect currentViewOriginRect))visualAnimationBlock{
    _visualCustomAnimationBlock = visualAnimationBlock;
}
#pragma mark - property
-(NSMutableArray *)reusePageVCArray{
    if (!_reusePageVCArray) {
        _reusePageVCArray = @[].mutableCopy;
    }
    return _reusePageVCArray;
}

-(NSInteger)reuseCacheCount{
    if (_reuseCacheCount <= 0) {
        _reuseCacheCount = kDefaultPageVCCacheCount;
        return _reuseCacheCount;
    }
    return _reuseCacheCount;
}
@end
