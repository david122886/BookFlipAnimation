//
//  XXSYPageViewController.m
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/2.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "XXSYPageViewController.h"

@interface XXSYPageViewController ()
///是否是反面页,仿真翻页专用
@property (assign,nonatomic,readonly) BOOL isPaperBack;
@end

@implementation XXSYPageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
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



#pragma mark - Page protocol

-(void)willMoveToFront{
    
}

-(void)didCancelMoveToFront{
    
}

-(void)didMoveToFrontWithDirection:(FlipAnimationDirection)flipDirection{
    
}

-(void)willMoveToBack{
    
}

-(void)didCancelMoveToBack{
    
}
-(void)didMoveToBackWithDirection:(FlipAnimationDirection)flipDirection{
    
}

///背景颜色
-(void)pageBackGroundColorChangedWithProperty:(ReadDataProperty*)readProperty{
    
}
///字体大小
-(void)pageFontSizeChangedWithProperty:(ReadDataProperty*)readProperty{
    
}
///字体改变
-(void)pageFontChangedWithProperty:(ReadDataProperty*)readProperty{
    
}
///行间距
-(void)pageLineSpaceChangedWithProperty:(ReadDataProperty*)readProperty{
    
}
///底部信息栏是否显示
-(void)pageBottomTipInfoStatusChangedWithProperty:(ReadDataProperty*)readProperty{
    
}

///还原所有设置
-(void)pageResetAllPropertyWithProperty:(ReadDataProperty*)readProperty{
    
}

///清楚所有数据，准备接受新数据
-(void)clearAllPageData{
    _isPaperBack = NO;
    
}


-(void)currentPageVCChanged:(BOOL)isCurrentPageVC{
    _isCurrentPageVC = isCurrentPageVC;
}

-(void)flipAnimationStatusChanged:(BOOL)isFlipAnimating{
    _isFlipAnimating = isFlipAnimating;
}

-(void)animationTypeChanged:(FlipAnimationType)animationType{
    _animationType = animationType;
}

#pragma mark - 仿真翻页使用
-(BOOL)isDrawBackForFlipCurl{
    return _isPaperBack;
}
-(void)setDrawBackForFlipCurl:(BOOL)drawBack{
    _isPaperBack = drawBack;
}
-(void)copyPageVCDataWithVC:(id<XXSYPageVCProtocol>)pageVC withIsDrawBack:(BOOL)drawBack{
    _isPaperBack = drawBack;
    
}

#pragma mark - setter

@end
