//
//  ScrollVerticalFlipView.m
//  BookFlipAnimation
//
//  Created by liudavid on 16/3/18.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "ScrollVerticalFlipView.h"
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
        [self addSubview:pageVC.view];
    }
    return self;
}


@end


@interface ScrollVerticalFlipView()<UIScrollViewDelegate>
@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) XXSYPageViewController *pageVC;
@property (assign,nonatomic) NSInteger needPageCount;
@property (assign,nonatomic) BOOL forbiden;
@property (assign,nonatomic) CGPoint tmpOffset;

@property (strong,nonatomic) ScrollPageView *tmpVisibleTopPageView;
@property (strong,nonatomic) ScrollPageView *tmpVisibleBottomPageView;
@property (assign,nonatomic) CGPoint tmpPanVelocity;

@end
@implementation ScrollVerticalFlipView

-(instancetype)initWithFrame:(CGRect)frame withPageVC:(XXSYPageViewController*)pageVC{
    self = [super initWithFrame:frame];
    if (self) {
        _pageVC = pageVC;
        _needPageCount = 100;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){0,0,frame.size}];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = NO;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        _scrollView.delegate = self;
        _scrollView.contentSize = frame.size;
        [self addSubview:_scrollView];
        
        [self setupPageViewsWithCount:1];
        
        ///用在章节只有一页，且前后章节都需要付费时候
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}


-(void)setupPageViewsWithCount:(NSInteger)count{
    for (int index = 0; index < count; index++) {
        ScrollPageView *sub = [self getReusePageView];
        sub.frame = (CGRect){0,CGRectGetHeight(self.frame)*index,self.frame.size};
        sub.backgroundColor = index%2 == 0?[UIColor greenColor]: [UIColor redColor];
        sub.tag = index;
        [self.scrollView addSubview:sub];
    }
    self.scrollView.contentSize = (CGSize){CGRectGetWidth(self.frame),CGRectGetHeight(self.frame)*count};
}
#pragma mark - panGesture


-(void)panGesture:(UIPanGestureRecognizer*)panGesture{
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [panGesture velocityInView:nil];
        if (point.y > 0) {
            ///scroll to top
            [self loadTopWithNeedPageView:[self getVisibleTopPageView]];
        }else{
            ///scroll to bottom
            [self loadBottomWithNeedPageView:[self getVisibleBottomPageView]];
        }
        NSLog(@"panGesture:%@",NSStringFromCGPoint(point));
    }
//    self.scrollView.contentSize = (CGSize){CGRectGetWidth(self.frame),CGRectGetHeight(self.frame)+1};
}

#pragma mark - scroll View delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    CGFloat y = [scrollView.panGestureRecognizer velocityInView:nil].y;
//    NSLog(@"%f",y);
    self.tmpOffset = scrollView.contentOffset;
    
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"888888888888");
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    NSLog(@"end drag,%f",velocity.y);
    self.tmpPanVelocity = velocity;
    if (ABS(velocity.y)  <= 0.001) {
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"scrollViewDidEndDecelerating");
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > self.tmpOffset.y) {
        self.tmpOffset = scrollView.contentOffset;

        ///scroll up
        ScrollPageView *visiblePageView = [self getVisibleBottomPageView];
        if (visiblePageView && self.tmpVisibleBottomPageView == visiblePageView) {
            return;
        }
        if (CGRectGetMinY(visiblePageView.frame) < scrollView.contentOffset.y + CGRectGetHeight(scrollView.frame)/2) {
            self.tmpVisibleBottomPageView = visiblePageView;
            ///处理之后页需求
            [self loadBottomWithNeedPageView:visiblePageView];
        }
        return;
    }
    
    if (scrollView.contentOffset.y <= self.tmpOffset.y) {
        self.tmpOffset = scrollView.contentOffset;

        ///scroll down
        ScrollPageView *visiblePageView = [self getVisibleTopPageView];
        if (visiblePageView && self.tmpVisibleTopPageView == visiblePageView) {
            return;
        }
        
        if (CGRectGetMaxY(visiblePageView.frame) > scrollView.contentOffset.y + CGRectGetHeight(scrollView.frame)/2) {
            self.tmpVisibleTopPageView = visiblePageView;
            ///处理之前页需求
            [self loadTopWithNeedPageView:visiblePageView];
        }
        
        return;
    }
    
}



#pragma mark - pageView helpers

-(void)loadTopWithNeedPageView:(ScrollPageView*)pageView{
    NSLog(@"loadTopWithNeedPageView:%@",pageView);
}

-(void)loadBottomWithNeedPageView:(ScrollPageView*)pageView{
    NSLog(@"loadBottomWithNeedPageView:%@",pageView);
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

-(NSInteger)getPageViewCount{
    NSInteger count = 0;
    for (UIView *sub in self.scrollView.subviews) {
        if ([sub isKindOfClass:[ScrollPageView class]]) {
            count++;
        }
    }
    return count;
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
    ScrollPageView *animationView = [[ScrollPageView alloc] initWithFrame:self.bounds withPageVC:nil];
    
    return animationView;
}
@end
