//
//  TNSegueTarget.h
//  Tuhu
//
//  Created by 邢小迪 on 15/5/18.
//  Copyright (c) 2015年 telenav. All rights reserved.
//
//****************************************************************************************
// 万能跳转规则对象， 封装跳转信息
//****************************************************************************************
//

#import "MMBaseModel.h"

@interface TNSegueTarget : MMBaseModel
#pragma mark 通用规则
/**
 *  要跳转到的控制器名字
 */
@property (strong, nonatomic) NSString* targetName;
/**
 *  当所需属性为模型对象时，或者为 数组(数组中元素为模型对象)时，对应的键值对写为  属性名<类名> : @{该模型的属性列表}  或   属性名<元素类名> : @[@{该模型的属性列表}，@{该模型的属性列表} ... ]
 *  当属性模型对象嵌套时， 将以上规则嵌套
 *  @brief 要跳转到的控制器所需的属性列表 ，key -> value 形式  属性名 : 对应值
 */
@property (strong, nonatomic) NSMutableDictionary* targetParams;

#pragma mark 特殊规则
/**
 *  跳转前是否需要登录
 */
@property (nonatomic) BOOL needLogin;
@end
