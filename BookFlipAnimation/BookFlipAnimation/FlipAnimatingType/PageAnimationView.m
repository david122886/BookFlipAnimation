//
//  PageAnimationView.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/7.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "PageAnimationView.h"
#import "XXSYPageViewController.h"

@interface PageAnimationView()
@property (strong,nonatomic,readonly) UIImageView *shadowImageView;
@property (strong,nonatomic) UIView *containerView;
@end

@implementation PageAnimationView

+(CGRect)pageAnimationViewFrameWithShadowPosion:(PageAnimationViewShadowPosition)posion{
    CGRect frame = [[UIScreen mainScreen] bounds];
    if (posion == ShadowPosion_None) {
        return frame;
    }
    if (posion == ShadowPosion_Right) {
        return (CGRect){0,0,CGRectGetWidth(frame)+kShadowWidth,CGRectGetHeight(frame)};
    }
    if (posion == ShadowPosion_Bottom) {
        return (CGRect){0,0,CGRectGetWidth(frame),CGRectGetHeight(frame)+kShadowWidth};
    }
    if (posion == ShadowPosion_Left) {
        return (CGRect){-kShadowWidth,0,CGRectGetWidth(frame)+kShadowWidth,CGRectGetHeight(frame)};
    }
    if (posion == ShadowPosion_Top) {
        return (CGRect){0,-kShadowWidth,CGRectGetWidth(frame),CGRectGetHeight(frame)+kShadowWidth};
    }
    return CGRectZero;
}

+(CGRect)pageViewFrameWithShadowPosion:(PageAnimationViewShadowPosition)posion{
    CGRect frame = [[UIScreen mainScreen] bounds];
    if (posion == ShadowPosion_None) {
        return frame;
    }
    if (posion == ShadowPosion_Right) {
        return frame;
    }
    if (posion == ShadowPosion_Bottom) {
        return frame;
    }
    if (posion == ShadowPosion_Left) {
        return (CGRect){kShadowWidth,0,frame.size};
    }
    if (posion == ShadowPosion_Top) {
        return (CGRect){0,kShadowWidth,frame.size};
    }
    return CGRectZero;
}

-(instancetype)initWithShadowPosion:(PageAnimationViewShadowPosition)shadowPosion withPageVC:(XXSYPageViewController*)pageVC{
    self = [super initWithFrame:[PageAnimationView pageAnimationViewFrameWithShadowPosion:shadowPosion]];
    if (self) {
//        self.clipsToBounds = YES;
        
        _containerView = [[UIView alloc] initWithFrame:[PageAnimationView pageViewFrameWithShadowPosion:shadowPosion]];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
        
        _pageVC = pageVC;
        _pageVC.view.frame = [PageAnimationView pageViewFrameWithShadowPosion:shadowPosion];
//        _pageVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _pageVC.view.autoresizingMask = UIViewAutoresizingNone;///自动阅读pageVC.view不会跟着跑
        [_containerView addSubview:pageVC.view];
        
        _shadowPosion = ShadowPosion_None;
        _shadowImageView = [[UIImageView alloc] init];
        [_shadowImageView setHidden:YES];
        _shadowImageView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self setShadowPosion:shadowPosion];
        [self addSubview:_shadowImageView];
    }
    return self;
}

-(void)setShadowPosion:(PageAnimationViewShadowPosition)shadowPosion{
    _shadowPosion = shadowPosion;    
    _containerView.frame = [PageAnimationView pageViewFrameWithShadowPosion:shadowPosion];
    if (shadowPosion == ShadowPosion_None) {
        [_shadowImageView setHidden:YES];
        _shadowImageView.image = nil;
        return;
    }
    
    [_shadowImageView setHidden:NO];
    if (shadowPosion == ShadowPosion_Right) {
        _shadowImageView.frame = (CGRect){CGRectGetWidth(self.frame)-kShadowWidth,0,kShadowWidth,CGRectGetHeight(self.frame)};
        _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        UIImage *shadowImage = [UIImage imageNamed:@"shadow.png"];
        
        CGFloat top = shadowImage.size.height / 2 - 1; // 顶端盖高度
        CGFloat bottom = shadowImage.size.height / 2 + 1 ; // 底端盖高度
        CGFloat left = 0; // 左端盖宽度
        CGFloat right = 0; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        shadowImage = [shadowImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
        _shadowImageView.image = shadowImage;
        
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        return;
    }
    
    if (shadowPosion == ShadowPosion_Bottom) {
        
        _shadowImageView.frame = (CGRect){0,CGRectGetMaxY(self.bounds)-kShadowWidth,CGRectGetWidth(self.bounds),kShadowWidth};
        _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIImage *shadowImage = [UIImage imageNamed:@"shadow.png"];
        shadowImage = [[UIImage alloc] initWithCGImage:shadowImage.CGImage scale:1.0 orientation:UIImageOrientationRight];
        CGFloat top = shadowImage.size.height / 2 - 1; // 顶端盖高度
        CGFloat bottom = shadowImage.size.height / 2 + 1 ; // 底端盖高度
        CGFloat left = 0; // 左端盖宽度
        CGFloat right = 0; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        shadowImage = [shadowImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        _shadowImageView.image = shadowImage;
        
        _containerView.autoresizingMask = UIViewAutoresizingNone;
        return;
    }
    
    if (shadowPosion == ShadowPosion_Top) {
        _shadowImageView.frame = (CGRect){0,0,CGRectGetWidth(self.frame),kShadowWidth};
        _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        return;
    }
    
    if (shadowPosion == ShadowPosion_Left) {
        _shadowImageView.frame = (CGRect){0,CGRectGetHeight(self.frame),kShadowWidth,CGRectGetHeight(self.frame)};
        _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        return;
    }
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (self.shadowPosion == ShadowPosion_Bottom) {
        _shadowImageView.frame = (CGRect){0,CGRectGetMaxY(frame)-kShadowWidth,CGRectGetWidth(frame),kShadowWidth};
        _containerView.frame = (CGRect){0,0,CGRectGetWidth(frame),CGRectGetHeight(frame)-kShadowWidth};
    }
}

@end
