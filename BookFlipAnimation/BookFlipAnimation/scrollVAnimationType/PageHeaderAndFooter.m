//
//  PageHeaderAndFooter.m
//  BookFlipAnimation
//
//  Created by liudavid on 16/3/22.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "PageHeaderAndFooter.h"

@implementation PageHeaderAndFooter


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.drawString) {
        [self.drawString drawInRect:rect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
}

-(void)drawString:(NSString*)drawString{
    _drawString = drawString;
    [self setNeedsDisplay];
}
@end
