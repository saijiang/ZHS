//
//  NSDate+TNAppLib.h
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TNAppLib)

+ (NSDate *)dateWithTimeMillisSince1970:(long long)timeMillis;
- (int64_t)timeMillisSince1970;
+ (int64_t)timeMillisSince1970;

-(BOOL) isToday;
@end
