//
//  NSError+TNAppLib.h
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TNErrorDomain;
extern NSString *const TNErrorExceptionKey;

enum {
    TNErrorCodeException = -2,
    TNErrorCodeLibraryMin = -10000,
    TNErrorCodeLibraryMax = 10000,
};

@interface NSError (TNAppLib)

+ (id)errorWithException:(NSException *)exception;
+ (id)errorWithCode:(NSInteger)code format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);
+ (id)errorWithCode:(NSInteger)code;
+ (id)errorWithCode:(NSInteger)code localizedDescription:(NSString *)errorMsg;
+ (id)errorWithCode:(NSInteger)code localizedDescription:(NSString *)errorMsg userInfo:(NSDictionary *)userInfo;
+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)errorMsg userInfo:(NSDictionary *)userInfo;

@end
