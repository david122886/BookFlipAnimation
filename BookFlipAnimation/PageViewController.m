//
//  PageViewController.m
//  BookFlipAnimation
//
//  Created by liudavid on 16/3/9.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()
@property (strong,nonatomic) UILabel *text;
@property (assign,nonatomic) BOOL isBack;
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.text = [[UILabel  alloc] initWithFrame:self.view.bounds];
    self.text.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.text setTextAlignment:NSTextAlignmentCenter];
    [self.text setFont:[UIFont systemFontOfSize:80]];
    [self.view addSubview:self.text];
    
    [self.text setText:[NSString stringWithFormat:@"%ld",self.index]];


    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willMoveToFront{
    [self.text setText:[NSString stringWithFormat:@"%ld",self.index]];
    NSLog(@"%ld-%@- willMoveToFront",self.index,self.isBack?@"Back":@"Front");
}

-(void)didMoveToFrontWithDirection:(FlipAnimationDirection)flipDirection{
    NSString *direction = nil;
    switch (flipDirection) {
        case FlipAnimationDirection_FromLeftToRight:
            direction = @"FromLeftToRight";
            break;
        case FlipAnimationDirection_FromRightToLeft:
            direction = @"FromRightToLeft";
            break;
        case FlipAnimationDirection_None:
            direction = @"None";
            break;
        case FlipAnimationDirection_Other:
            direction = @"Other";
            break;
        default:
            break;
    }
    NSLog(@"%ld-%@-didMoveToFrontWithDirection:%@",self.index,self.isBack?@"Back":@"front",direction);

}

-(void)didCancelMoveToFront{
    NSLog(@"%ld-%@- didCancelMoveToFront",self.index,self.isBack?@"Back":@"Front");

//    self.index = 0;
//    self.text.text = nil;
}


-(void)willMoveToBack{
    NSLog(@"%ld-%@- willMoveToBack",self.index,self.isBack?@"Back":@"Front");

}

-(void)didMoveToBackWithDirection:(FlipAnimationDirection)flipDirection{
    NSString *direction = nil;
    switch (flipDirection) {
        case FlipAnimationDirection_FromLeftToRight:
            direction = @"FromLeftToRight";
            break;
        case FlipAnimationDirection_FromRightToLeft:
            direction = @"FromRightToLeft";
            break;
        case FlipAnimationDirection_None:
            direction = @"None";
            break;
        case FlipAnimationDirection_Other:
            direction = @"Other";
            break;
        default:
            break;
    }
    NSLog(@"%ld-%@-didMoveToBackWithDirection:%@",self.index,self.isBack?@"Back":@"front",direction);


//    self.index = 0;
//    self.text.text = nil;
}

-(void)didCancelMoveToBack{
    NSLog(@"%ld-%@- didCancelMoveToBack",self.index,self.isBack?@"Back":@"Front");

//    [self.text setText:[NSString stringWithFormat:@"%ld",self.index]];
}

-(void)clearAllPageData{
    NSLog(@"%ld-%@- clearAllPageData",self.index,self.isBack?@"Back":@"Front");

//    self.index = 0;
//    self.text.text = nil;
}


#pragma mark - 仿真翻页处理
-(void)copyPageVCDataWithVC:(id<XXSYPageVCProtocol>)pageVC withIsDrawBack:(BOOL)drawBack{
    [super copyPageVCDataWithVC:pageVC withIsDrawBack:drawBack];
    
    self.isBack = drawBack;
    PageViewController *needPageVC = (PageViewController*)pageVC;
    self.index = needPageVC.index;
    self.view.backgroundColor = needPageVC.view.backgroundColor;
    if (self.isViewLoaded) {
        [self.text setText:[NSString stringWithFormat:@"%ld",self.index]];
    }
    
    NSLog(@"%ld-%@- copyPageVCDataWithVC ",self.index,self.isBack?@"Back":@"Front");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
