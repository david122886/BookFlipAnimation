//
//  ScrollVerticalFlipView.m
//  BookFlipAnimation
//
//  Created by liudavid on 16/3/18.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "ScrollVerticalFlipView.h"
#define kCachePageCount 5

@interface ScrollPageView:UIView
@property (strong,nonatomic,readonly) XXSYPageViewController *pageVC;
-(instancetype)initWithFrame:(CGRect)frame withPageVC:(XXSYPageViewController*)pageVC;
@end
@implementation ScrollPageView
-(instancetype)initWithFrame:(CGRect)frame withPageVC:(XXSYPageViewController*)pageVC{
    self = [super initWithFrame:frame];
    if (self) {
        _pageVC = pageVC;
        _pageVC.view.frame = (CGRect){0,0,frame.size};
        _pageVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:pageVC.view];
    }
    return self;
}


@end


@interface ScrollVerticalFlipView()<UIScrollViewDelegate>
@property (strong,nonatomic) UIScrollView *scrollView;
@property (assign,nonatomic) CGPoint tmpOffset;

@property (strong,nonatomic) ScrollPageView *tmpVisibleTopPageView;
@property (strong,nonatomic) ScrollPageView *tmpVisibleBottomPageView;

@property (strong,nonatomic,readonly) Class pageVCClass;

@property (strong,nonatomic) ScrollPageView *tmpCallBackTopPageView;
@property (strong,nonatomic) ScrollPageView *tmpCallBackBottomPageView;

@property (strong,nonatomic) UIImageView *backImageView;

@end
@implementation ScrollVerticalFlipView

-(instancetype)initWithFrame:(CGRect)frame withPageVC:(XXSYPageViewController*)pageVC withDataSource:(id<ScrollVerticalFlipViewDataSource>)dataSource withPageVCForClass:(Class)pageVCClass{
    self = [super initWithFrame:frame];
    if (self) {
        _dataSource = dataSource;
        _pageVCClass = pageVCClass;
        
        _backImageView = [[UIImageView alloc] initWithFrame:(CGRect){0,0,frame.size}];
        _backImageView.backgroundColor = [UIColor clearColor];
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_backImageView];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){0,kPageHeaderHeight,CGRectGetWidth(frame),CGRectGetHeight(frame)-kPageHeaderHeight*2}];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = NO;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        _scrollView.delegate = self;
        _scrollView.contentSize = frame.size;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        
        [self resetScrollViewWithPageVC:pageVC];
    }
    return self;
}

-(void)registerScrollHeader:(Class)headerClass{
    if (_scrollHeader) {
        return;
    }
    _scrollHeader = headerClass?[[headerClass alloc] init]:[[UIView alloc] init];
    _scrollHeader.frame = (CGRect){0,0,CGRectGetWidth(self.frame),kPageHeaderHeight};
    _scrollHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollHeader.backgroundColor = [UIColor clearColor];
    [self addSubview:_scrollHeader];
    
}

-(void)registerScrollFooter:(Class)footerClass{
    if (_scrollFooter) {
        return;
    }
    _scrollFooter = footerClass?[[footerClass alloc] init]:[[UIView alloc] init];
    _scrollFooter.frame = (CGRect){0,CGRectGetHeight(self.frame)-kPageHeaderHeight,CGRectGetWidth(self.frame),kPageHeaderHeight};
    _scrollFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollFooter.backgroundColor = [UIColor clearColor];
    [self addSubview:_scrollFooter];
}

-(void)setupBackgroundColorORImage:(id)item{
    if ([item isKindOfClass:[UIColor class]]) {
        self.backImageView.image = nil;
        self.backImageView.backgroundColor = item;
    }else{
        self.backImageView.backgroundColor = [UIColor clearColor];
        self.backImageView.image = item;
    }
}

-(void)setupScrollOffset{
    _scrollView.contentOffset = (CGPoint){0,1};
    
    ScrollPageView *oldPageView = [self getVisibleTopPageView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollVerticalView:refreshScrollHeader:andRefreshScrollFooter:withCurrentPageVC:)]) {
        [self.delegate scrollVerticalView:self refreshScrollHeader:self.scrollHeader andRefreshScrollFooter:self.scrollFooter withCurrentPageVC:oldPageView.pageVC];
    }
}

#pragma mark - 外部调用接口

-(BOOL)isFlipAnimating{
    return self.scrollView.isDecelerating| self.scrollView.isDragging;
}

-(NSArray*)getAllPageVCs{
    NSArray *allPageViews = [self getAllPageViews];
    NSMutableArray *pageVCs = @[].mutableCopy;
    for (ScrollPageView *sub in allPageViews) {
        [pageVCs addObject:sub.pageVC];
    }
    return pageVCs;
}

-(XXSYPageViewController*)getVisibleBottomPageVC{
    return [[self getVisibleBottomPageView] pageVC];
}
-(XXSYPageViewController*)getVisibleTopPageVC{
    return [[self getVisibleTopPageView] pageVC];
}


-(void)resetScrollViewWithPageVC:(XXSYPageViewController*)pageVC{
    if (!pageVC || [self isFlipAnimating]) {
        return;
    }
    NSArray *allViews = [self getAllPageViews];
    ScrollPageView *animationView = nil;
    for (ScrollPageView *sub in allViews) {
        if (sub.pageVC == pageVC) {
            animationView = sub;
        }
        [sub removeFromSuperview];
    }
    if (!animationView) {
        animationView = [[ScrollPageView alloc] initWithFrame:(CGRect){0,0,_scrollView.frame.size} withPageVC:pageVC];
    }else{
        animationView.frame = (CGRect){0,0,_scrollView.frame.size};
    }
    
    [_scrollView addSubview:animationView];
    
    _scrollView.contentSize = (CGSize){CGRectGetWidth(_scrollView.frame),CGRectGetHeight(_scrollView.frame)+1};

    _tmpCallBackBottomPageView = animationView;
    [self pageVCBeginningWithNeedPageVC:pageVC withCurrentPageVC:nil];
    [self pageVCDidFinishedWithNeedPageVC:pageVC withCurrentPageVC:nil withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
    ;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupScrollOffset];
        });
    });
    
}


#pragma mark - scroll View delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.tmpOffset = scrollView.contentOffset;
}

//-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    
//}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    
    if (scrollView.contentOffset.y > self.tmpOffset.y) {
        self.tmpOffset = scrollView.contentOffset;

        ///scroll up
        ScrollPageView *visiblePageView = [self getVisibleBottomPageView];
        
        if (self.tmpCallBackBottomPageView != visiblePageView) {
            [self pageVCCallBackWithVisibleBottomPageView:visiblePageView withOldTmpPageView:self.tmpCallBackBottomPageView];
            self.tmpCallBackBottomPageView = visiblePageView;
        }
        
        if (visiblePageView && self.tmpVisibleBottomPageView == visiblePageView) {
            return;
        }
        if (CGRectGetMinY(visiblePageView.frame) < scrollView.contentOffset.y + CGRectGetHeight(scrollView.frame)/2) {
            self.tmpVisibleBottomPageView = visiblePageView;
            ///处理之后页需求
            [self loadBottomWithVisibleBottomPageView:visiblePageView];
        }
        return;
    }
    
    if (scrollView.contentOffset.y <= self.tmpOffset.y) {
        self.tmpOffset = scrollView.contentOffset;

        ///scroll down
        ScrollPageView *visiblePageView = [self getVisibleTopPageView];
        
        if (self.tmpCallBackTopPageView != visiblePageView) {
            [self pageVCCallBackWithVisibleTopPageView:visiblePageView withOldTmpPageView:self.tmpCallBackTopPageView];
            self.tmpCallBackTopPageView = visiblePageView;
        }
        
        if (visiblePageView && self.tmpVisibleTopPageView == visiblePageView) {
            return;
        }
        
        if (CGRectGetMaxY(visiblePageView.frame) > scrollView.contentOffset.y + CGRectGetHeight(scrollView.frame)/2) {
            self.tmpVisibleTopPageView = visiblePageView;
            ///处理之前页需求
            [self loadTopWithVisibleTopPageView:visiblePageView];
        }
        
        return;
    }
    
}



#pragma mark - pageView helpers

-(void)loadTopWithVisibleTopPageView:(ScrollPageView*)visibleTopPageView{
    ScrollPageView *topView = [self getTopPageViewAtPageView:nil];
    ScrollPageView *reusePageView = [self getTopPageViewAtPageView:visibleTopPageView];
    if (!reusePageView) {
        if ([self getPageViewCount] < kCachePageCount) {
            reusePageView = [self getReusePageView];
        }else{
            reusePageView = [self getBottomPageViewUnderPageView:nil];
        }
    }

    [reusePageView.pageVC clearAllPageData];
    XXSYPageViewController *needPageVC = [self.dataSource scrollVerticalView:self refreshBeforePageVCWithReusePageVC:reusePageView.pageVC withCurrentPageVC:visibleTopPageView.pageVC];
    if (!needPageVC) {
        return;
    }
    
    [self pageVCBeginningWithNeedPageVC:reusePageView.pageVC withCurrentPageVC:nil];
    
    if (topView == visibleTopPageView) {
        ///滑到顶部追加pageView
        CGFloat height = CGRectGetHeight(topView.frame);
        if (CGRectGetMinY(topView.frame) <= height) {
            self.scrollView.contentSize = (CGSize){self.scrollView.contentSize.width,self.scrollView.contentSize.height + height};
            NSArray *allPages = [self getAllPageViews];
            for (ScrollPageView *pageView in allPages) {
                pageView.frame = CGRectOffset(pageView.frame, 0, height);
            }
            self.scrollView.contentOffset = (CGPoint){self.scrollView.contentOffset.x,self.scrollView.contentOffset.y + height};
        }
        
        reusePageView.frame = CGRectOffset(topView.frame, 0, -height);
        if (![self.scrollView.subviews containsObject:reusePageView]) {
            [self.scrollView addSubview:reusePageView];
        }
        [self.scrollView sendSubviewToBack:reusePageView];
        
    }
}

-(void)loadBottomWithVisibleBottomPageView:(ScrollPageView*)visibleBottomPageView{
    ScrollPageView *bottomView = [self getBottomPageViewUnderPageView:nil];
    ScrollPageView *reusePageView = [self getBottomPageViewUnderPageView:visibleBottomPageView];
    if (!reusePageView) {
        if ([self getPageViewCount] < kCachePageCount) {
            reusePageView = [self getReusePageView];
        }else{
            reusePageView = [self getTopPageViewAtPageView:nil];
        }
    }
    [reusePageView.pageVC clearAllPageData];
    XXSYPageViewController *needPageVC = [self.dataSource scrollVerticalView:self refreshAfterPageVCWithReusePageVC:reusePageView.pageVC withCurrentPageVC:visibleBottomPageView.pageVC];
    if (!needPageVC) {
        return;
    }
    
    [self pageVCBeginningWithNeedPageVC:reusePageView.pageVC withCurrentPageVC:nil];
    if (bottomView == visibleBottomPageView) {
        ///滑到底部追加pageView
        reusePageView.frame = CGRectOffset(bottomView.frame, 0, CGRectGetHeight(bottomView.frame));
        if (![self.scrollView.subviews containsObject:reusePageView]) {
            [self.scrollView addSubview:reusePageView];
        }
        [self.scrollView bringSubviewToFront:reusePageView];
        
        self.scrollView.contentSize = (CGSize){self.scrollView.contentSize.width,self.scrollView.contentSize.height + CGRectGetHeight(bottomView.frame)};
    }
    
}

#pragma mark - pagevc animation

-(void)pageVCCallBackWithVisibleBottomPageView:(ScrollPageView*)visibleBottomPageView withOldTmpPageView:(ScrollPageView*)oldPageView{
    if (oldPageView) {
        ScrollPageView *willBackView = [self getTopPageViewAtPageView:oldPageView];
        ScrollPageView *willFrontView = visibleBottomPageView;
        [self pageVCBeginningWithNeedPageVC:nil withCurrentPageVC:willBackView.pageVC];
        [self pageVCDidFinishedWithNeedPageVC:willFrontView.pageVC withCurrentPageVC:willBackView.pageVC withAnimationDirection:FlipAnimationDirection_FromLeftToRight];
        
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollVerticalView:refreshScrollHeader:andRefreshScrollFooter:withCurrentPageVC:)]) {
        [self.delegate scrollVerticalView:self refreshScrollHeader:self.scrollHeader andRefreshScrollFooter:self.scrollFooter withCurrentPageVC:oldPageView.pageVC];
    }
    
}

-(void)pageVCCallBackWithVisibleTopPageView:(ScrollPageView*)visibleTopPageView withOldTmpPageView:(ScrollPageView*)oldPageView{
    if (oldPageView) {
        ScrollPageView *willBackView = [self getBottomPageViewUnderPageView:oldPageView];
        ScrollPageView *willFrontView = visibleTopPageView;
        [self pageVCBeginningWithNeedPageVC:nil withCurrentPageVC:willBackView.pageVC];
        [self pageVCDidFinishedWithNeedPageVC:willFrontView.pageVC withCurrentPageVC:willBackView.pageVC withAnimationDirection:FlipAnimationDirection_FromRightToLeft];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollVerticalView:refreshScrollHeader:andRefreshScrollFooter:withCurrentPageVC:)]) {
            [self.delegate scrollVerticalView:self refreshScrollHeader:self.scrollHeader andRefreshScrollFooter:self.scrollFooter withCurrentPageVC:oldPageView.pageVC];
        }
    }
}

-(void)pageVCBeginningWithNeedPageVC:(XXSYPageViewController*)needPageVC withCurrentPageVC:(XXSYPageViewController*)pageVC{
    [needPageVC animationTypeChanged:FlipAnimationType_scroll_V];
    [needPageVC flipAnimationStatusChanged:YES];
    [needPageVC currentPageVCChanged:YES];
    [needPageVC willMoveToFront];
    
    [pageVC willMoveToBack];
    [pageVC currentPageVCChanged:NO];
    [pageVC animationTypeChanged:FlipAnimationType_scroll_V];
    [pageVC flipAnimationStatusChanged:YES];
}


-(void)pageVCDidFinishedWithNeedPageVC:(XXSYPageViewController*)needPageVC withCurrentPageVC:(XXSYPageViewController*)pageVC withAnimationDirection:(FlipAnimationDirection)direction{
    
    [needPageVC currentPageVCChanged:YES];
    [needPageVC flipAnimationStatusChanged:NO];
    [needPageVC didMoveToFrontWithDirection:direction];
    
    [pageVC currentPageVCChanged:NO];
    [pageVC flipAnimationStatusChanged:NO];
    [pageVC didMoveToBackWithDirection:direction];
}

#pragma mark - scrollView helpers
-(ScrollPageView*)subPageViewAtOffset:(CGPoint)offset{
    ScrollPageView *needView = nil;
    for (ScrollPageView *sub in self.scrollView.subviews) {
        if (offset.y > CGRectGetMinY(sub.frame) - CGRectGetHeight(sub.frame)/2 && offset.y <= CGRectGetMinY(sub.frame) + CGRectGetHeight(sub.frame)/2) {
            needView = sub;
            break;
        }
    }
    return needView;
}

-(NSArray*)getAllPageViews{
    NSMutableArray *pages = @[].mutableCopy;
    NSArray *allSubs = self.scrollView.subviews;
    for (UIView *sub in allSubs) {
        if ([sub isKindOfClass:[ScrollPageView class]]) {
            [pages addObject:sub];
        }
    }
    return pages;
}

-(NSInteger)getPageViewCount{
    return [self getAllPageViews].count;
}

-(ScrollPageView*)getVisibleTopPageView{
    NSArray *pageViews = [self visiblePageViews];
    if (pageViews.count > 1) {
        ScrollPageView *pageV1 = [pageViews firstObject];
        ScrollPageView *pageV2 = [pageViews lastObject];
        if (CGRectGetMaxY(pageV1.frame) > CGRectGetMaxY(pageV2.frame)) {
            return pageV2;
        }
        return pageV1;
    }
    if (pageViews.count == 1) {
        return [pageViews firstObject];
    }
    
    return nil;
}



-(ScrollPageView*)getVisibleBottomPageView{
    NSArray *pageViews = [self visiblePageViews];
    if (pageViews.count > 1) {
        ScrollPageView *pageV1 = [pageViews firstObject];
        ScrollPageView *pageV2 = [pageViews lastObject];
        if (CGRectGetMaxY(pageV1.frame) > CGRectGetMaxY(pageV2.frame)) {
            return pageV1;
        }
        return pageV2;
    }
    if (pageViews.count == 1) {
        return [pageViews firstObject];
    }
    
    return nil;
}

-(ScrollPageView*)getTopPageViewAtPageView:(ScrollPageView*)currentPageView{
    NSArray *allSubViews = self.scrollView.subviews;

    if (!currentPageView) {
        for (UIView *sub in allSubViews) {
            if ([sub isKindOfClass:[ScrollPageView class]]) {
                return (ScrollPageView*)sub;
            }
        }
    }
    
    for (NSInteger index = allSubViews.count-1; index >= 0; index--) {
        UIView *sub = allSubViews[index];
        if ([sub isKindOfClass:[ScrollPageView class]] && CGRectGetMinY(sub.frame) < CGRectGetMinY(currentPageView.frame)) {
            return (ScrollPageView*)sub;
        }
    }

    return nil;
}

-(ScrollPageView*)getBottomPageViewUnderPageView:(ScrollPageView*)currentPageView{
    NSArray *allSubViews = self.scrollView.subviews;
    if (!currentPageView) {
        for (NSInteger index = allSubViews.count-1; index >= 0; index--) {
            UIView *sub = allSubViews[index];
            if ([sub isKindOfClass:[ScrollPageView class]]) {
                return (ScrollPageView*)sub;
            }
        }
    }
    for (NSInteger index = 0; index < allSubViews.count; index++) {
        UIView *sub = allSubViews[index];
        if ([sub isKindOfClass:[ScrollPageView class]] && CGRectGetMinY(sub.frame) > CGRectGetMinY(currentPageView.frame)) {
            return (ScrollPageView*)sub;
        }
    }
    
    return nil;
}


-(NSArray*)visiblePageViews{
    NSMutableArray *pageViews = @[].mutableCopy;
    CGRect rect = self.scrollView.bounds;
    for (UIView *sub in self.scrollView.subviews) {
        if ([sub isKindOfClass:[ScrollPageView class]]) {
            if (!CGRectIsNull(CGRectIntersection(rect, sub.frame))) {
                [pageViews addObject:sub];
            }
        }
    }
    return pageViews.count >0?pageViews:nil;
}

#pragma mark - property

-(ScrollPageView*)getReusePageView{
    ScrollPageView *animationView = [[ScrollPageView alloc] initWithFrame:self.bounds withPageVC:[[self.pageVCClass alloc] init]];
    
    return animationView;
}


@end
