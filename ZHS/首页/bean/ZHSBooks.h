//
//  ZHSBooks.h
//  ZHS
//
//  Created by 邢小迪 on 15/11/25.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHSBooks : MMBaseModel

@property (nonatomic,copy) NSString *ID;//

@property (nonatomic,copy) NSString *isbn;// 书isbn
@property (nonatomic,copy) NSString *isbn10;// isbn 10为


@property (nonatomic,copy) NSString *title;// 书名字
@property (nonatomic,copy) NSString *summary;// 书的简介
@property (nonatomic,copy) NSString *subtitle;//书的副标题

@property (nonatomic,copy) NSMutableArray *images;// t图片,
@property (nonatomic,copy) NSString *pages;// 书的页数
@property (nonatomic,copy) NSString *price;// 书的价钱
@property (nonatomic,copy) NSString *press;// 出版社
@property (nonatomic,copy) NSString *binding; // 精装 简装

@property (nonatomic,copy) NSArray *translators;// 翻译的人,
@property (nonatomic,copy) NSNumber *rank;// 评分
@property (nonatomic,copy) NSArray *tags;// 书本分属类别


@property(nonatomic,strong)NSArray *authors;// 作者
@end
