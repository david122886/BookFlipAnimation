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

        _pageVC = pageVC;
        _pageVC.view.frame = [PageAnimationView pageViewFrameWithShadowPosion:shadowPosion];
        [self addSubview:pageVC.view];
        
        _shadowPosion = ShadowPosion_None;
        _shadowImageView = [[UIImageView alloc] init];
        [_shadowImageView setHidden:YES];
        _shadowImageView.backgroundColor = [UIColor clearColor];
        [self setShadowPosion:shadowPosion];
        [self addSubview:_shadowImageView];
    }
    return self;
}

-(void)setShadowPosion:(PageAnimationViewShadowPosition)shadowPosion{
    _shadowPosion = shadowPosion;
    if (shadowPosion == ShadowPosion_None) {
        [_shadowImageView setHidden:YES];
        _shadowImageView.image = nil;
        return;
    }
    
    UIImage *image = [[UIImage imageNamed:@"shadow"] resizableImageWithCapInsets:(UIEdgeInsets){0,0,0,0}];
    _shadowImageView.image = image;
    if (shadowPosion == ShadowPosion_Right) {
        _shadowImageView.frame = (CGRect){CGRectGetWidth(self.frame)-kShadowWidth,0,kShadowWidth,CGRectGetHeight(self.frame)};
        _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        return;
    }
    
    if (shadowPosion == ShadowPosion_Bottom) {
        _shadowImageView.frame = (CGRect){0,CGRectGetHeight(self.frame)-kShadowWidth,CGRectGetWidth(self.frame),kShadowWidth};
        _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        return;
    }
    
    if (shadowPosion == ShadowPosion_Top) {
        _shadowImageView.frame = (CGRect){0,0,CGRectGetWidth(self.frame),kShadowWidth};
        _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        return;
    }
    
    if (shadowPosion == ShadowPosion_Left) {
        _shadowImageView.frame = (CGRect){0,CGRectGetHeight(self.frame),kShadowWidth,CGRectGetHeight(self.frame)};
        _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        return;
    }
}

@end
