//
//  PageAnimationView.h
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/7.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kShadowWidth 10

@class XXSYPageViewController;
typedef NS_ENUM(NSInteger,PageAnimationViewShadowPosition){
    ShadowPosion_None,
    ShadowPosion_Right,
    ShadowPosion_Left,
    ShadowPosion_Top,
    ShadowPosion_Bottom
};
@interface PageAnimationView : UIView
@property (strong,nonatomic,readonly) XXSYPageViewController *pageVC;
@property (assign,nonatomic,readonly) PageAnimationViewShadowPosition shadowPosion;

-(instancetype)initWithShadowPosion:(PageAnimationViewShadowPosition)shadowPosion withPageVC:(XXSYPageViewController*)pageVC;
-(void)setShadowPosion:(PageAnimationViewShadowPosition)shadowPosion;
@end
