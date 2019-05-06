//
//  TNBean.h
//  TNAppLib
//
//  Created by kiri on 2013-10-14.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNJsonObject.h"
#import "TNBeanSupport.h"

/*!
 *  A bean is an object that can be serialized, specially, by 
 */
@interface TNBean : NSObject <TNJsonObject, NSSecureCoding, TNBeanSupport>

@end
