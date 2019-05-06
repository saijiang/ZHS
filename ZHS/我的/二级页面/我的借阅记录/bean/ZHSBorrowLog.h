//
//  ZHSBorrowLog.h
//  ZHS
//
//  Created by 邢小迪 on 16/1/13.
//  Copyright © 2016年 邢小迪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHSSchoolbag.h"
@interface ZHSBorrowLog : MMBaseModel
@property(nonatomic,copy)NSNumber *ID;
@property(nonatomic,copy)NSString *borrow_code;
@property(nonatomic,copy)NSString *status;


@property(nonatomic,copy)NSString *borrow_start;
@property(nonatomic,copy)NSString *borrow_end;
@property(nonatomic,copy)NSString *return_at;

@property(nonatomic,copy)NSString *updated_at;
@property(nonatomic,copy)NSString *created_at;
//@property(nonatomic,copy)NSString *created_at;


//@property(nonatomic,copy)NSString *updated_at;
//
//@property(nonatomic,copy)NSString *updated_at;



@property(nonatomic,strong)ZHSSchoolbag *schoolbag;
@end
