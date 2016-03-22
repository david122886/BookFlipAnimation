//
//  PageHeaderAndFooter.h
//  BookFlipAnimation
//
//  Created by liudavid on 16/3/22.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageHeaderAndFooter : UIView
@property (strong,nonatomic,readonly) NSString *drawString;
-(void)drawString:(NSString*)drawString;
@end
