//
//  NSError+TNAppLib.m
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "NSError+TNAppLib.h"

NSString *const TNErrorExceptionKey = @"TNErrorExceptionKey";
NSString *const TNErrorDomain = @"TNErrorDomain";

@implementation NSError (TNAppLib)

+ (id)errorWithException:(NSException *)exception
{
    NSMutableDictionary *userInfo = nil;
    if (exception) {
        userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:exception forKey:TNErrorExceptionKey];
        if (exception.reason) {
            [userInfo setObject:exception.reason forKey:NSLocalizedDescriptionKey];
            [userInfo setObject:exception.reason forKey:NSLocalizedFailureReasonErrorKey];
        }
    }
    
    return [self errorWithDomain:TNErrorDomain code:TNErrorCodeException userInfo:userInfo];
}

+ (id)errorWithCode:(NSInteger)code format:(NSString *)format, ...
{
    va_list ap;
    va_start(ap, format);
    NSString *localizedDescription = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    return [self errorWithCode:code localizedDescription:localizedDescription];
}

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)errorMsg userInfo:(NSDictionary *)userInfo
{
    NSMutableDictionary *newUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    if (errorMsg) {
        [newUserInfo setObject:errorMsg forKey:NSLocalizedDescriptionKey];
    } else {
        [newUserInfo removeObjectForKey:NSLocalizedDescriptionKey];
    }
    return [self errorWithDomain:domain code:code userInfo:userInfo];
}

+ (id)errorWithCode:(NSInteger)code localizedDescription:(NSString *)errorMsg userInfo:(NSDictionary *)userInfo
{
    return [self errorWithDomain:TNErrorDomain code:code localizedDescription:errorMsg userInfo:userInfo];
}

+ (id)errorWithCode:(NSInteger)code localizedDescription:(NSString *)errorMsg
{
    if (errorMsg) {
        return [self errorWithDomain:TNErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
    }
    return [self errorWithDomain:TNErrorDomain code:code userInfo:nil];
}

+ (id)errorWithCode:(NSInteger)code
{
    return [self errorWithCode:code localizedDescription:nil];
}

@end