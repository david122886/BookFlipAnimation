//
//  XXSYFlipAnimationController+PageContent.h
//  BookFlipAnimation
//
//  Created by xxsy-ima001 on 16/3/3.
//  Copyright © 2016年 ___xiaoxiangwenxue___. All rights reserved.
//

#import "XXSYFlipAnimationController.h"
/**
 * 页面内容处理
 */
@interface XXSYFlipAnimationController (PageContent)
///当前页负责显示错误信息
-(void)tipErrorMsg:(RequestError*)errorMsg forLoadChapterNode:(ChapterNode*)chapterNode orChapterId:(NSString*)chapterId withBookModel:(BookModel*)bookModel withFromDirection:(FlipAnimationType)fromDirection;
@end
