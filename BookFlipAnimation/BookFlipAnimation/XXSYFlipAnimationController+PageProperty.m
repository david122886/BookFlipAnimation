//
//  XXSYFlipAnimationController+PageProperty.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/3.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "XXSYFlipAnimationController+PageProperty.h"

@implementation XXSYFlipAnimationController (PageProperty)

///字体大小
-(void)resetFontSizeWithProperty:(ReadDataProperty*)readProperty{
    NSArray *pageVCS = [self childenPageControllers];
    for (XXSYPageViewController *pageVC in pageVCS) {
        if ([pageVC respondsToSelector:@selector(pageFontSizeChangedWithProperty:)]) {
            [pageVC pageFontSizeChangedWithProperty:readProperty];
        }
    }
}

///字体改变
-(void)resetFontWithProperty:(ReadDataProperty*)readProperty{
    NSArray *pageVCS = [self childenPageControllers];
    for (XXSYPageViewController *pageVC in pageVCS) {
        if ([pageVC respondsToSelector:@selector(pageFontChangedWithProperty:)]) {
            [pageVC pageFontChangedWithProperty:readProperty];
        }
    }
}

///行间距
-(void)resetLineSpaceWithProperty:(ReadDataProperty*)readProperty{
    NSArray *pageVCS = [self childenPageControllers];
    for (XXSYPageViewController *pageVC in pageVCS) {
        if ([pageVC respondsToSelector:@selector(pageLineSpaceChangedWithProperty:)]) {
            [pageVC pageLineSpaceChangedWithProperty:readProperty];
        }
    }
}

///底部信息栏是否显示
-(void)resetBottomTipInfoStatusWithProperty:(ReadDataProperty*)readProperty{
    NSArray *pageVCS = [self childenPageControllers];
    for (XXSYPageViewController *pageVC in pageVCS) {
        if ([pageVC respondsToSelector:@selector(pageBottomTipInfoStatusChangedWithProperty:)]) {
            [pageVC pageBottomTipInfoStatusChangedWithProperty:readProperty];
        }
    }
}

///还原所有设置
-(void)resetAllPropertyWithProperty:(ReadDataProperty*)readProperty{
    NSArray *pageVCS = [self childenPageControllers];
    for (XXSYPageViewController *pageVC in pageVCS) {
        if ([pageVC respondsToSelector:@selector(pageResetAllPropertyWithProperty:)]) {
            [pageVC pageResetAllPropertyWithProperty:readProperty];
        }
    }
}

@end
