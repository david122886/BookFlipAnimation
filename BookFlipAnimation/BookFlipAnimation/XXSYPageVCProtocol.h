//
//  XXSYPageVCProtocol.h
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/2.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constent.h"
#import "ReadDataProperty.h"
/**
 * 用户不能直接调用这些接口，只能重载
 */
@protocol XXSYPageVCProtocol <NSObject>

#pragma mark - 动画效果

-(void)willMoveToFront;
-(void)didCancelMoveToFront;
-(void)didMoveToFrontWithDirection:(FlipAnimationDirection)flipDirection;



-(void)willMoveToBack;
-(void)didCancelMoveToBack;
-(void)didMoveToBackWithDirection:(FlipAnimationDirection)flipDirection;

#pragma mark - 页面设置
///背景颜色
-(void)pageBackGroundColorChangedWithProperty:(ReadDataProperty*)readProperty;
///字体大小
-(void)pageFontSizeChangedWithProperty:(ReadDataProperty*)readProperty;
///字体改变
-(void)pageFontChangedWithProperty:(ReadDataProperty*)readProperty;
///行间距
-(void)pageLineSpaceChangedWithProperty:(ReadDataProperty*)readProperty;
///底部信息栏是否显示
-(void)pageBottomTipInfoStatusChangedWithProperty:(ReadDataProperty*)readProperty;

///还原所有设置
-(void)pageResetAllPropertyWithProperty:(ReadDataProperty*)readProperty;

#pragma mark - 初始化
-(void)clearAllPageData;

-(void)currentPageVCChanged:(BOOL)isCurrentPageVC;
-(void)flipAnimationStatusChanged:(BOOL)isFlipAnimating;
-(void)animationTypeChanged:(FlipAnimationType)animationType;

#pragma mark - 仿真翻页使用
-(BOOL)isDrawBackForFlipCurl;
-(void)setDrawBackForFlipCurl:(BOOL)drawBack;
-(void)copyPageVCDataWithVC:(id<XXSYPageVCProtocol>)pageVC withIsDrawBack:(BOOL)drawBack;

@end
