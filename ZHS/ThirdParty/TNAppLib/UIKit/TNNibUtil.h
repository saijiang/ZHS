//
//  TNNibUtil.h
//  TNAppLib
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNNibUtil : NSObject

/**
 *  use this function only when nibname isEqual to class name
 */
+ (id)loadMainObjectFromNib:(NSString *)nibName;

+ (id)loadObjectWithClass:(Class)clazz fromNib:(NSString *)nibName;

@end
