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
#import "ScrollVerticalFlipView.h"

typedef BOOL (^XXSYFlipGestureShouldRecognizeTouchBlock)(XXSYFlipAnimationController * drawerController, UIGestureRecognizer * gesture, UITouch * touch);
typedef void (^XXSYFlipGestureCompletionBlock)(XXSYFlipAnimationController * drawerController, UIGestureRecognizer * gesture);

#pragma mark -




#pragma mark -


@interface XXSYFlipAnimationController ()<UIGestureRecognizerDelegate,UIPageViewControllerDataSource,UIPageViewControllerDelegate,ScrollVerticalFlipViewDataSource,ScrollVerticalFlipViewDelegate>
@property (strong,nonatomic) XXSYFlipGestureShouldRecognizeTouchBlock gestureShouldRecognizeTouch;
@property (strong,nonatomic) XXSYFlipGestureCompletionBlock gestureCompletion;
@property (strong,nonatomic) VisualCustomAnimationBlock visualCustomAnimationBlock;
@property (strong,nonatomic) CustomAnimationStatusBlock customAnimationBeginStatusBlock;
@property (strong,nonatomic) CustomAnimationStatusBlock customAnimationFinishedStatusBlock;

@property (assign,nonatomic) BOOL isFlipAnimating;

///缓存PageAnimationView，实现重复使用,index = 0表示最上面
@property (strong,nonatomic) NSMutableArray *reusePageAnimationViewArray;

@property (strong,nonatomic) Class currentPageVCClass;
@property (strong,nonatomic) Class scrollHeaderClass;
@property (strong,nonatomic) Class scrollFooterClass;

#pragma mark - pan gesture
@property (nonatomic, assign) CGPoint startPanPoint;
@property (nonatomic, assign) CGPoint movePanPoint;
@property (strong,nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong,nonatomic) UITapGestureRecognizer *tapGesture;

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

#pragma mark - 仿真翻页
@property (strong,nonatomic) UIPageViewController *curlPageViewController;
@property (assign,nonatomic) BOOL curlIsLoadAfter;
@property (strong,nonatomic) XXSYPageViewController *tmpNeedPageVC;
@property (strong,nonatomic) XXSYPageViewController *tmpCurrentPageVC;
@property (strong,nonatomic) XXSYPageViewController *tmpBackPageVC;

@property (strong,nonatomic) ScrollVerticalFlipView *scrollVFlipView;

@end

@implementation XXSYFlipAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupGestureRecognizers];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:YES];
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

-(void)registerScrollHeader:(Class)scrollHeader{
    _scrollHeaderClass = scrollHeader;
}

-(void)registerScrollFooter:(Class)scrollFooter{
    _scrollFooterClass = scrollFooter;
}

-(NSArray*)childenPageControllers{
    NSMutableArray *childern = @[].mutableCopy;
    if (self.animationType == FlipAnimationType_scroll || self.animationType == FlipAnimationType_cover || self.animationType == FlipAnimationType_auto) {
        for (PageAnimationView *sub in self.reusePageAnimationViewArray) {
            [childern addObject:sub.pageVC];
        }
        return childern;
    }
    if (self.animationType == FlipAnimationType_curl) {
        return [self.curlPageViewController viewControllers];
    }
    if (self.animationType == FlipAnimationType_scroll_V) {
        return [self.scrollVFlipView getAllPageVCs];
    }
    return nil;
}

///上下拖动翻页需要区分
-(XXSYPageViewController*)getCurrentPageVCForAfter{
    if (self.animationType == FlipAnimationType_scroll_V) {
        return [self.scrollVFlipView getVisibleBottomPageVC];
    }
    return [self currentPageVC];
}
///上下拖动翻页需要区分
-(XXSYPageViewController*)getCurrentPageVCForBefore{
    if (self.animationType == FlipAnimationType_scroll_V) {
        return [self.scrollVFlipView getVisibleTopPageVC];
    }
    return [self currentPageVC];
}

-(CGSize)getPageContentSize{
    CGRect rect = [[UIScreen mainScreen] bounds];
    if (self.animationType == FlipAnimationType_scroll_V) {
        return (CGSize){CGRectGetWidth(rect),CGRectGetHeight(rect) - kPageHeaderHeight*2};
    }
    return rect.size;
}

-(XXSYPageViewController*)currentPageVC{
    XXSYPageViewController *currentPageVC = nil;
    if (self.animationType == FlipAnimationType_auto) {
        currentPageVC= [[self getCurrentPageAnimationView] pageVC];
        return currentPageVC;
    }
    
    if (self.isAnimating) {
        NSAssert(NO, @"正在动画效果，无法获取正确currrentPageVC");
        return nil;
    }
    
    if (self.animationType == FlipAnimationType_cover || self.animationType == FlipAnimationType_scroll) {
        currentPageVC= [[self getCurrentPageAnimationView] pageVC];
    }
    if (self.animationType == FlipAnimationType_curl) {
        currentPageVC = [self getCurlFlipCurrentPageVC];
    }
    if (self.animationType == FlipAnimationType_scroll_V) {
        currentPageVC = [self.scrollVFlipView getVisibleTopPageVC];
    }
    return currentPageVC;
}

-(void)setupInitPageViewController:(XXSYPageViewController*)pageVC withFlipAnimationType:(FlipAnimationType)animationType{
    if (!pageVC) {
        return;
    }
    _animationType = animationType;
    _isFlipAnimating = NO;
    
    if (animationType == FlipAnimationType_curl) {
        [self setupInitPageViewControllerForCurl:pageVC];
        return;
    }
    if (animationType == FlipAnimationType_cover || animationType == FlipAnimationType_scroll || animationType == FlipAnimationType_auto) {
        [self setupInitPageViewControllerForCoverAndScroll:pageVC];
        return;
    }
    if (animationType == FlipAnimationType_scroll_V) {
        [self setupInitPageViewControllerForScroll_V:pageVC];
        return;
    }
}
#pragma mark - init helpers
-(void)setupInitPageViewControllerForCoverAndScroll:(XXSYPageViewController*)pageVC{
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
    
    [self.panGesture setEnabled:YES];
}

-(void)destroyPageViewControllerForCoverAndScroll{
    if ([self isAnimating]) {
        return;
    }
    
    for (PageAnimationView *sub in self.reusePageAnimationViewArray) {
        XXSYPageViewController *pageVC = sub.pageVC;
        [pageVC willMoveToParentViewController:nil];
        [pageVC removeFromParentViewController];
        [sub removeFromSuperview];
        [pageVC didMoveToParentViewController:nil];
    }
    [self.reusePageAnimationViewArray removeAllObjects];
    
}

-(void)setupInitPageViewControllerForCurl:(XXSYPageViewController*)pageVC{
    [self.panGesture setEnabled:NO];
    [self setupCurlPageViewControllerWithPageVC:pageVC];
}

-(void)destroyPageViewControllerForCurl{
    if ([self isAnimating]) {
        return;
    }
    
    [self.curlPageViewController willMoveToParentViewController:nil];
    [self.curlPageViewController.view removeFromSuperview];
    [self.curlPageViewController removeFromParentViewController];
    [self.curlPageViewController didMoveToParentViewController:nil];
    
    self.curlPageViewController = nil;
    
}

-(void)setupInitPageViewControllerForScroll_V:(XXSYPageViewController*)pageVC{
    [self.panGesture setEnabled:NO];
    if (self.scrollVFlipView) {
        return;
    }
    
    self.scrollVFlipView = [[ScrollVerticalFlipView alloc] initWithFrame:[[UIScreen mainScreen] bounds] withPageVC:pageVC withDataSource:self withPageVCForClass:self.currentPageVCClass];
    self.scrollVFlipView.delegate = self;
    [self.scrollVFlipView registerScrollFooter:self.scrollFooterClass];
    [self.scrollVFlipView registerScrollHeader:self.scrollHeaderClass];
    
    [self.view addSubview:self.scrollVFlipView];
    self.scrollVFlipView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
}

-(void)destroyPageViewControllerForScroll_V{
    if ([self isAnimating]) {
        return;
    }
    NSArray *pageVCs = [self.scrollVFlipView getAllPageVCs];
    for (XXSYPageViewController *pageVC in pageVCs) {
        [pageVC willMoveToParentViewController:nil];
        [pageVC removeFromParentViewController];
        [pageVC didMoveToParentViewController:nil];
    }
    [self.scrollVFlipView removeFromSuperview];
    self.scrollVFlipView = nil;
}

-(void)destroyOtherAnimationTypePageVCWithCurrentFlipType:(FlipAnimationType)flipType{
    if (flipType == FlipAnimationType_auto || flipType == FlipAnimationType_cover || flipType == FlipAnimationType_scroll) {
        [self destroyPageViewControllerForCurl];
        [self destroyPageViewControllerForScroll_V];
        return;
    }
    if (flipType == FlipAnimationType_scroll_V) {
        [self destroyPageViewControllerForCurl];
        [self destroyPageViewControllerForCoverAndScroll];
        return;
    }
    if (flipType == FlipAnimationType_curl) {
        [self destroyPageViewControllerForScroll_V];
        [self destroyPageViewControllerForCoverAndScroll];
        return;
    }
}
#pragma mark - helpers
-(void)setupGestureRecognizers{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCallback:)];
    [pan setDelegate:self];
    [self.view addGestureRecognizer:pan];
    self.panGesture = pan;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureCallback:)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    self.tapGesture = tap;
    
    [tap requireGestureRecognizerToFail:pan];
    
    if (self.animationType == FlipAnimationType_curl || self.animationType == FlipAnimationType_scroll_V) {
        [pan setEnabled:NO];
    }else{
        [pan setEnabled:YES];
    }
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

#pragma mark - 仿真翻页 pageVC 回调
#pragma mark - pagevc animation
-(void)pageVCBeginningWithNeedPageVC:(XXSYPageViewController*)needPageVC withCurrentPageVC:(XXSYPageViewController*)pageVC{
    _isFlipAnimating = YES;
    [needPageVC animationTypeChanged:self.animationType];
    [needPageVC flipAnimationStatusChanged:YES];
    [needPageVC currentPageVCChanged:YES];
    [needPageVC willMoveToFront];
    
    [pageVC willMoveToBack];
    [pageVC currentPageVCChanged:NO];
    [pageVC animationTypeChanged:self.animationType];
    [pageVC flipAnimationStatusChanged:YES];
}


-(void)pageVCDidFinishedWithNeedPageVC:(XXSYPageViewController*)needPageVC withCurrentPageVC:(XXSYPageViewController*)pageVC withAnimationDirection:(FlipAnimationDirection)direction{
    _isFlipAnimating = NO;
    
    [needPageVC currentPageVCChanged:YES];
    [needPageVC flipAnimationStatusChanged:NO];
    [needPageVC didMoveToFrontWithDirection:direction];
    
    [pageVC currentPageVCChanged:NO];
    [pageVC flipAnimationStatusChanged:NO];
    [pageVC didMoveToBackWithDirection:direction];
}

-(void)pageVCDidCancelWithNeedPageVC:(XXSYPageViewController*)needPageVC withCurrentPageVC:(XXSYPageViewController*)pageVC{
    _isFlipAnimating = NO;
    
    [needPageVC currentPageVCChanged:NO];
    [needPageVC flipAnimationStatusChanged:NO];
    [needPageVC didCancelMoveToFront];
    
    [pageVC currentPageVCChanged:YES];
    [pageVC flipAnimationStatusChanged:NO];
    [pageVC didCancelMoveToBack];
}

-(void)pageVCAnimationBeginningWithNeedPageView:(PageAnimationView*)needPageView withCurrentPageView:(PageAnimationView*)pageView{
    XXSYPageViewController *needPageVC = needPageView.pageVC;
    XXSYPageViewController *pageVC = pageView.pageVC;
    
    if (![self.childViewControllers containsObject:needPageVC]) {
        [needPageVC willMoveToParentViewController:self];
        [self.view addSubview:needPageView];
        needPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addChildViewController:needPageVC];
        [needPageVC didMoveToParentViewController:self];
    }
    
    [self pageVCBeginningWithNeedPageVC:needPageVC withCurrentPageVC:pageVC];
}

-(void)pageVCAnimationDidFinishedWithNeedPageView:(PageAnimationView*)needPageView withCurrentPageView:(PageAnimationView*)pageView withAnimationDirection:(FlipAnimationDirection)direction{
    [self pageVCDidFinishedWithNeedPageVC:needPageView.pageVC withCurrentPageVC:pageView.pageVC withAnimationDirection:direction];
}

-(void)pageVCAnimationDidCancelWithNeedPageView:(PageAnimationView*)needPageView withCurrentPageView:(PageAnimationView*)pageView{
    [self pageVCDidCancelWithNeedPageVC:needPageView.pageVC withCurrentPageVC:pageView.pageVC];
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


-(void)curlTapGestureBeforeAnimationBegining:(UITapGestureRecognizer *)tapGesture{
    XXSYPageViewController *currentPageVC = [self getCurlFlipCurrentPageVC];
    NSAssert(currentPageVC != nil, @"获取当前viewcontroller为空");
    XXSYPageViewController *backPageVC = (XXSYPageViewController*)[self pageViewController:self.curlPageViewController viewControllerBeforeViewController:currentPageVC];
    if (!backPageVC) {
        return;
    }
    XXSYPageViewController *needPageVC = (XXSYPageViewController*)[self pageViewController:self.curlPageViewController viewControllerBeforeViewController:backPageVC];
    
    [self pageVCBeginningWithNeedPageVC:backPageVC withCurrentPageVC:currentPageVC];
    [self pageVCBeginningWithNeedPageVC:needPageVC withCurrentPageVC:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.curlPageViewController setViewControllers:@[needPageVC,backPageVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        [weakSelf pageVCDidFinishedWithNeedPageVC:needPageVC withCurrentPageVC:currentPageVC withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
        [weakSelf pageVCDidFinishedWithNeedPageVC:backPageVC withCurrentPageVC:nil withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
        
        if (weakSelf.gestureCompletion) {
            weakSelf.gestureCompletion(weakSelf,tapGesture);
        }
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(flipAnimationController:FlipFinishedHasAnimation:transitionCompleted:)]) {
            [weakSelf.delegate flipAnimationController:weakSelf FlipFinishedHasAnimation:YES transitionCompleted:YES];
        }
    }];
}

-(void)curlTapGestureAfterAnimationBegining:(UITapGestureRecognizer *)tapGesture{
    XXSYPageViewController *currentPageVC = [self getCurlFlipCurrentPageVC];
    NSAssert(currentPageVC != nil, @"获取当前viewcontroller为空");
    XXSYPageViewController *backPageVC = (XXSYPageViewController*)[self pageViewController:self.curlPageViewController viewControllerAfterViewController:currentPageVC];
    
    XXSYPageViewController *needPageVC = (XXSYPageViewController*)[self pageViewController:self.curlPageViewController viewControllerAfterViewController:backPageVC];
    
    if (!needPageVC) {
        return;
    }
    
    [self pageVCBeginningWithNeedPageVC:backPageVC withCurrentPageVC:currentPageVC];
    [self pageVCBeginningWithNeedPageVC:needPageVC withCurrentPageVC:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.curlPageViewController setViewControllers:@[needPageVC,backPageVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        [weakSelf pageVCDidFinishedWithNeedPageVC:needPageVC withCurrentPageVC:currentPageVC withAnimationDirection:FlipAnimationDirection_FromRightToLeft];
        [weakSelf pageVCDidFinishedWithNeedPageVC:backPageVC withCurrentPageVC:nil withAnimationDirection:FlipAnimationDirection_FromRightToLeft];
        
        if (weakSelf.gestureCompletion) {
            weakSelf.gestureCompletion(weakSelf,tapGesture);
        }
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(flipAnimationController:FlipFinishedHasAnimation:transitionCompleted:)]) {
            [weakSelf.delegate flipAnimationController:weakSelf FlipFinishedHasAnimation:YES transitionCompleted:YES];
        }
    }];
}
#pragma mark - Gesture Type
-(void)autoReadTapGestureHandle:(UITapGestureRecognizer *)tapGesture{
    if (self.autoReadStatus == AutoReadStatus_pause) {
        [self resumeAutoRead];
        return;
    }
    if (self.autoReadStatus == AutoReadStatus_beginning) {
        [self pauseAutoRead];
        return;
    }
}

-(void)curlFlipTapGestureHandle:(UITapGestureRecognizer *)tapGesture{
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    if ([self.touchAfterBezierPath containsPoint:point]) {
        ///下翻页
        if ([self touchFromLeftToRightIsAfter]) {
            [self curlTapGestureAfterAnimationBegining:tapGesture];
        }else{
            [self curlTapGestureBeforeAnimationBegining:tapGesture];
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
            [self curlTapGestureBeforeAnimationBegining:tapGesture];
        }else{
            [self curlTapGestureAfterAnimationBegining:tapGesture];
        }
        
        return;
    }
}

-(void)coverAndScrollFlipTapGestureHandle:(UITapGestureRecognizer *)tapGesture{
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

-(void)scroll_VFlipTapGestureHandle:(UITapGestureRecognizer *)tapGesture{
    
}

#pragma mark - Gesture Handlers

-(BOOL)touchFromLeftToRightIsAfter{
    CGRect beforeRect = CGPathGetBoundingBox(self.touchBeforeBezierPath.CGPath);
    CGRect afterRect = CGPathGetBoundingBox(self.touchAfterBezierPath.CGPath);
    return CGRectGetMinX(beforeRect) < CGRectGetMinX(afterRect);
}

-(void)tapGestureCallback:(UITapGestureRecognizer *)tapGesture{
    
    if (self.animationType == FlipAnimationType_curl) {
        [self curlFlipTapGestureHandle:tapGesture];
        return;
    }
    if (self.animationType == FlipAnimationType_scroll_V) {
        [self scroll_VFlipTapGestureHandle:tapGesture];
        return;
    }
    if (self.animationType == FlipAnimationType_cover || self.animationType == FlipAnimationType_scroll) {
        [self coverAndScrollFlipTapGestureHandle:tapGesture];
        return;
    }
    if (self.animationType == FlipAnimationType_auto) {
        [self autoReadTapGestureHandle:tapGesture];
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
    if ([self isAnimating]) {
        return;
    }
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

#pragma mark - 背景颜色设置
///背景颜色
-(void)resetBackGroundColorWithProperty:(ReadDataProperty*)readProperty{
    NSArray *allPagesArr = [self childenPageControllers];
    if (self.animationType == FlipAnimationType_scroll_V) {
        [self.scrollVFlipView setupBackgroundColorORImage:nil];
    }
    
    for (XXSYPageViewController *pageVC in allPagesArr) {
        if ([pageVC respondsToSelector:@selector(pageBackGroundColorChangedWithProperty:)]) {
            [pageVC pageBackGroundColorChangedWithProperty:readProperty];
        };
    }
}
#pragma mark - 仿真翻页
-(void)setupCurlPageViewControllerWithPageVC:(XXSYPageViewController*)pageVC{
    
    [self.panGesture setEnabled:NO];
    
    if (self.curlPageViewController) {
        return;
    }
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                        forKey: UIPageViewControllerOptionSpineLocationKey];
    _curlPageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    self.curlPageViewController.doubleSided = YES;
    self.curlPageViewController.delegate = self;
    self.curlPageViewController.dataSource = self;
    for (UIGestureRecognizer *gesture in self.curlPageViewController.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [gesture setEnabled:NO];
        }
    }
    
    
    [self.curlPageViewController willMoveToParentViewController:self];
    [self.view addSubview:self.curlPageViewController.view];
    self.curlPageViewController.view.frame = [[UIScreen mainScreen] bounds];
    self.curlPageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:self.curlPageViewController];
    [self.curlPageViewController didMoveToParentViewController:self];
    
    [pageVC flipAnimationStatusChanged:NO];
    [pageVC currentPageVCChanged:YES];
    [pageVC willMoveToFront];
    
    [self.curlPageViewController setViewControllers:@[pageVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
        [pageVC didMoveToFrontWithDirection:FlipAnimationDirection_None];
    }];
}


-(XXSYPageViewController*)getCurlFlipReusePageVC{
    XXSYPageViewController *needVC = [[self.currentPageVCClass alloc] init];
    [needVC clearAllPageData];
    return needVC;
}

-(XXSYPageViewController*)getCurlFlipCurrentPageVC{
    if (self.tmpNeedPageVC) {
        return self.tmpNeedPageVC;
    }
    return [self.curlPageViewController.viewControllers firstObject];
}


#pragma mark - UIPageViewControllerDataSource
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    self.curlIsLoadAfter = NO;
    
    XXSYPageViewController *needVC = [self getCurlFlipReusePageVC];
    XXSYPageViewController *currentVC = (XXSYPageViewController*)viewController;
    
    if ([currentVC isDrawBackForFlipCurl]) {
        [needVC copyPageVCDataWithVC:currentVC withIsDrawBack:NO];
        self.tmpNeedPageVC = needVC;
        return needVC;
    }
    
    [needVC setDrawBackForFlipCurl:YES];
    if ([self touchFromLeftToRightIsAfter]) {
        needVC = [self.dataSource flipAnimationController:self refreshBeforePageVCWithReusePageVC:needVC withCurrentPageVC:currentVC];
    }else{
        needVC = [self.dataSource flipAnimationController:self refreshAfterPageVCWithReusePageVC:needVC withCurrentPageVC:currentVC];
    }
    if (!needVC) {
        return nil;
    }
    
    self.tmpCurrentPageVC = currentVC;
    self.tmpBackPageVC = needVC;
    return needVC;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    self.curlIsLoadAfter = YES;
    
    XXSYPageViewController *needVC = [self getCurlFlipReusePageVC];
    XXSYPageViewController *currentVC = (XXSYPageViewController*)viewController;
    
    if (![currentVC isDrawBackForFlipCurl]) {
        [needVC copyPageVCDataWithVC:currentVC withIsDrawBack:YES];
        self.tmpBackPageVC = needVC;
        self.tmpCurrentPageVC = currentVC;
        return needVC;
    }
    
    [needVC setDrawBackForFlipCurl:NO];
    if ([self touchFromLeftToRightIsAfter]) {
        needVC = [self.dataSource flipAnimationController:self refreshAfterPageVCWithReusePageVC:needVC withCurrentPageVC:currentVC];
    }else{
        needVC = [self.dataSource flipAnimationController:self refreshBeforePageVCWithReusePageVC:needVC withCurrentPageVC:currentVC];
    }
    if (!needVC) {
        return nil;
    }
    self.tmpNeedPageVC = needVC;
    return needVC;
}

#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSAssert(pendingViewControllers.count <= 1, @"pendingViewControllers count 不为1");
    [self pageVCBeginningWithNeedPageVC:self.tmpBackPageVC withCurrentPageVC:self.tmpCurrentPageVC];
    [self pageVCBeginningWithNeedPageVC:self.tmpNeedPageVC withCurrentPageVC:nil];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (!completed) {
        [self pageVCDidCancelWithNeedPageVC:self.tmpNeedPageVC withCurrentPageVC:self.tmpCurrentPageVC];
        [self pageVCDidCancelWithNeedPageVC:self.tmpBackPageVC withCurrentPageVC:nil];
    }else{
        [self pageVCDidFinishedWithNeedPageVC:self.tmpNeedPageVC withCurrentPageVC:self.tmpCurrentPageVC withAnimationDirection:!self.curlIsLoadAfter?FlipAnimationDirection_FromLeftToRight:FlipAnimationDirection_FromRightToLeft];
        [self pageVCDidFinishedWithNeedPageVC:self.tmpBackPageVC withCurrentPageVC:nil withAnimationDirection:!self.curlIsLoadAfter?FlipAnimationDirection_FromLeftToRight:FlipAnimationDirection_FromRightToLeft];
    }
    
    if (self.gestureCompletion) {
        UIPanGestureRecognizer *panGesture = nil;
        for (UIGestureRecognizer *gesture in pageViewController.gestureRecognizers) {
            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
                panGesture = (UIPanGestureRecognizer*)gesture;
                break;
            }
        }
        self.gestureCompletion(self,panGesture);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(flipAnimationController:FlipFinishedHasAnimation:transitionCompleted:)]) {
        [self.delegate flipAnimationController:self FlipFinishedHasAnimation:finished transitionCompleted:completed];
    }
    
    self.tmpNeedPageVC = nil;
    self.tmpCurrentPageVC = nil;
    self.tmpBackPageVC = nil;
}

#pragma mark - 垂直拖动翻页
#pragma mark - ScrollVerticalFlipViewDataSource
-(XXSYPageViewController*)scrollVerticalView:(ScrollVerticalFlipView*)scrollView refreshBeforePageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC{
    if (![self.childViewControllers containsObject:reusePageVC]) {
        [reusePageVC willMoveToParentViewController:self];
        [self addChildViewController:reusePageVC];
        [reusePageVC didMoveToParentViewController:self];
    }
    return [self.dataSource flipAnimationController:self refreshBeforePageVCWithReusePageVC:reusePageVC withCurrentPageVC:currentPageVC];
}

-(XXSYPageViewController*)scrollVerticalView:(ScrollVerticalFlipView*)scrollView refreshAfterPageVCWithReusePageVC:(XXSYPageViewController*)reusePageVC withCurrentPageVC:(XXSYPageViewController*)currentPageVC{
    if (![self.childViewControllers containsObject:reusePageVC]) {
        [reusePageVC willMoveToParentViewController:self];
        [self addChildViewController:reusePageVC];
        [reusePageVC didMoveToParentViewController:self];
    }
    return [self.dataSource flipAnimationController:self refreshAfterPageVCWithReusePageVC:reusePageVC withCurrentPageVC:currentPageVC];
}

#pragma mark - ScrollVerticalFlipViewDelegate
-(void)scrollVerticalView:(ScrollVerticalFlipView *)scrollView refreshScrollHeader:(UIView *)header andRefreshScrollFooter:(UIView *)footer withCurrentPageVC:(XXSYPageViewController *)currentPageVC{
    if (self.delegate && [self.delegate respondsToSelector:@selector(flipAnimationController:refreshScrollHeader:andRefreshScrollFooter:withCurrentPageVC:)]) {
        [self.delegate flipAnimationController:self refreshScrollHeader:header andRefreshScrollFooter:footer withCurrentPageVC:currentPageVC];
    }
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
    if (self.isAnimating || self.animationType == animationType) {
        return;
    }
    
    XXSYPageViewController *currentPageVC = [self currentPageVC];
    
    FlipAnimationType oldType = self.animationType;
    _animationType = animationType;///必须要
    
    if (animationType == FlipAnimationType_auto) {
        if (oldType == FlipAnimationType_cover || oldType == FlipAnimationType_scroll) {
            for (PageAnimationView *pageView in self.reusePageAnimationViewArray) {
                [pageView.pageVC animationTypeChanged:animationType];
            }
            return;
        }
    }
    
    if (animationType == FlipAnimationType_cover || animationType == FlipAnimationType_scroll) {
        if (oldType == FlipAnimationType_auto) {
            for (PageAnimationView *pageView in self.reusePageAnimationViewArray) {
                [pageView.pageVC animationTypeChanged:animationType];
            }
            return;
        }
    }
    
    XXSYPageViewController *needPageVC = [[self.currentPageVCClass alloc] init];
    [needPageVC copyPageVCDataWithVC:currentPageVC withIsDrawBack:currentPageVC.isDrawBackForFlipCurl];
    [self setupInitPageViewController:needPageVC withFlipAnimationType:animationType];
    [self destroyOtherAnimationTypePageVCWithCurrentFlipType:animationType];
    
    [currentPageVC  animationTypeChanged:animationType];

}

-(void)setCustomVisualAnimationBlock:(void (^)(XXSYFlipAnimationController *animationController,NSArray *allAnimationViewsStack,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection,CGRect currentViewOriginRect,CGPoint translatePoint))visualAnimationBlock
       withAnimationBeginStatusBlock:(void (^)(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection))animationBeginStatus
          withAnimationFinishedBlock:(void (^)(XXSYFlipAnimationController *animationController,NSMutableArray *allAnimationViewsStack,PageAnimationView *reuseView,PageAnimationView *currentView,FlipAnimationDirection originDirection,FlipAnimationDirection finalDirection))animationFinishedStatus{
    _visualCustomAnimationBlock = visualAnimationBlock;
    _customAnimationBeginStatusBlock = animationBeginStatus;
    _customAnimationFinishedStatusBlock = animationFinishedStatus;
}

-(BOOL)isAnimating{
    if (self.animationType == FlipAnimationType_scroll_V) {
        return self.scrollVFlipView.isFlipAnimating;
    }
    return _isFlipAnimating;
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
