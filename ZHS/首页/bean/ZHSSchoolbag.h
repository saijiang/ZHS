//
//  ZHSSchoolbag.h
//  ZHS
//
//  Created by 邢小迪 on 15/12/22.
//  Copyright © 2015年 邢小迪. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ZHSSchoolbag : MMBaseModel
@property(nonatomic,copy)NSNumber *ID;
@property(nonatomic,copy)NSString *code;
@property(nonatomic,copy)NSString *class_level;

@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *qty_borrow;

@property(nonatomic,copy)NSString *status;


@property(nonatomic,copy)NSString *descriptions;  // 描述
@property(nonatomic,strong)NSNumber *ranking; // 评分
@property(nonatomic,strong)NSDictionary *images; // 书包照片

@property(nonatomic,strong)NSMutableArray *books_list;

@property(nonatomic,strong)NSMutableArray *tags; // 标签


@end
