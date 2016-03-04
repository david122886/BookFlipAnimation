//
//  XXSYFlipAnimationController+PageProperty.h
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/3.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "XXSYFlipAnimationController.h"
/**
 * 页面文本排版调用
 */
@interface XXSYFlipAnimationController (PageProperty)
///背景颜色
-(void)resetBackGroundColorWithProperty:(ReadDataProperty*)readProperty;
///字体大小
-(void)resetFontSizeWithProperty:(ReadDataProperty*)readProperty;
///字体改变
-(void)resetFontWithProperty:(ReadDataProperty*)readProperty;
///行间距
-(void)resetLineSpaceWithProperty:(ReadDataProperty*)readProperty;
///底部信息栏是否显示
-(void)resetBottomTipInfoStatusWithProperty:(ReadDataProperty*)readProperty;

///还原所有设置
-(void)resetAllPropertyWithProperty:(ReadDataProperty*)readProperty;
@end
