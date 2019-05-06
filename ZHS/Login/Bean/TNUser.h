//
//  TNUser.h
//  ZHS
//
//  Created by 邢小迪 on 16/2/22.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import "MMBaseModel.h"

@interface TNUser : MMBaseModel
/*
 "interests" : <__NSArrayM: 0x7feffd36d490  count = 4>
 [
 0. <__NSDictionaryM: 0x7feffa5e8430  keysCount = 4>
 {
 "id" : 1,
 "name" : "钢琴",
 "category" : "音乐",
 "pivot" : <__NSDictionaryM: 0x7feffd322c00  keysCount = 2>
 {
 "interest_id" : 1,
 "customer_id" : 4,
 },
 },
 1. <__NSDictionaryM: 0x7feffd0f3ae0  keysCount = 4>
 {
 "id" : 3,
 "name" : "舞蹈",
 "category" : "文艺",
 "pivot" : <__NSDictionaryM: 0x7feffd03fd60  keysCount = 2>
 {
 "interest_id" : 3,
 "customer_id" : 4,
 },
 },
 2. <__NSDictionaryM: 0x7feff8455370  keysCount = 4>
 {
 "id" : 5,
 "name" : "跆拳道",
 "category" : "体育",
 "pivot" : <__NSDictionaryM: 0x7feffd367e50  keysCount = 2>
 {
 "interest_id" : 5,
 "customer_id" : 4,
 },
 },
 3. <__NSDictionaryM: 0x7feffd382990  keysCount = 4>
 {
 "id" : 7,
 "name" : "手工DIY",
 "category" : "益智",
 "pivot" : <__NSDictionaryM: 0x7feffd3562e0  keysCount = 2>
 {
 "interest_id" : 7,
 "customer_id" : 4,
 },
 },
 ],

 */
@property (copy, nonatomic) NSMutableArray *interests;
/*
 "school_class_info" : <__NSDictionaryM: 0x7feffd095390  keysCount = 8>
 {
 "school_id" : 2,
 "id" : 4,
 "grade_id" : 0,
 "qty_of_register" : 2,
 "teacher_id" : 0,
 "description" : "精灵二班",
 "qty_of_children" : 30,
 "name" : "精灵二班",
 },
 */
@property (copy, nonatomic) NSMutableDictionary *school_class_info;
/*
 "school_info" : <__NSDictionaryM: 0x7feffd0dcdd0  keysCount = 13>
 {
 "id" : 1,
 "description" : "金水区第一幼儿园",
 "partner_id" : 1,
 "mobile" : "",
 "deposit" : "300.00",
 "area_id" : 410105,
 "city_id" : 410100,
 "address" : "",
 "name_of_director" : "",
 "qty_of_package" : 0,
 "telephone" : "",
 "name" : "金水区第一幼儿园",
 "province_id" : 410000,
 },
 */
@property (copy, nonatomic) NSMutableDictionary *school_info;
/*
 "baby" : <__NSDictionaryM: 0x7feffd0f5e20  keysCount = 5>
 {
 "customer_id" : 4,
 "id" : 2,
 "age" : 4,
 "gender" : "female",
 "name" : "妮妮",
 },
 */
@property (copy, nonatomic) NSMutableDictionary *baby;
@property (copy, nonatomic) NSString *mobile;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *isNewUser;
@property (copy, nonatomic) NSString *Message;
@property (copy, nonatomic) NSString *Code;
@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *family_role;

@property (copy, nonatomic) NSString *school_id;
@property (copy, nonatomic) NSString *payment_status;
@property (copy, nonatomic) NSString *school_class_id;
@property (copy, nonatomic) NSString *invited_code;
/*
 "avatar" : <__NSDictionaryM: 0x7fe4c8a98f70  keysCount = 6>
 {
 "large" : "/resources/book/images/2016/2/27/9a12767d6d2e43c771fb23fb2894b37f.jpg",
 "id" : 3339,
 "medium" : "/resources/book/images/2016/2/27/9a12767d6d2e43c771fb23fb2894b37f.jpg",
 "imagable_type" : "App\Models\Customer\Customer",
 "small" : "/resources/book/images/2016/2/27/9a12767d6d2e43c771fb23fb2894b37f.jpg",
 "imagable_id" : 4,
 },
 */
@property (copy, nonatomic) NSMutableDictionary*avatar;




//@property (nonatomic) BOOL isSignUp;

@property (copy, nonatomic) NSString *severChatID;
@end
