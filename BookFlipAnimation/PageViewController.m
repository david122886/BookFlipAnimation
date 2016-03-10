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
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.text = [[UILabel  alloc] initWithFrame:self.view.bounds];
    self.text.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.text setTextAlignment:NSTextAlignmentCenter];
    [self.text setFont:[UIFont systemFontOfSize:80]];
    [self.view addSubview:self.text];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willMoveToFront{
    [self.text setText:[NSString stringWithFormat:@"%ld",self.index]];
}

-(void)clearAllPageData{
    self.index = 0;
    self.text = nil;
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
