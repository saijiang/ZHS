//
//  NSFileManager+TNAppLib.m
//  TNAppLib
//
//  Created by kiri on 2013-11-11.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "NSFileManager+TNAppLib.h"

@implementation NSFileManager (TNAppLib)

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[self defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL *)applicationCachesDirectory
{
    return [[[self defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL *)applicationPrivateDirectory
{
    NSString *appName = [[NSBundle mainBundle].infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
    NSURL *url = [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:appName isDirectory:YES];
    BOOL isDir = YES;
    if (![[self defaultManager] fileExistsAtPath:url.path isDirectory:&isDir] || !isDir) {
        if (![[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil]) {
            return nil;
        }
    }
    return url;
}
@end
