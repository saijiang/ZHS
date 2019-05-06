//
//  TNWzUrlParse.m
//  WeZone
//
//  Created by Mr.Wang(Wang Zhao) on 14-1-6.
//  Copyright (c) 2014年 Telenav. All rights reserved.
//

#import "TNWzUrlParser.h"

@implementation TNWzUrlParser

+ (BOOL)parseURL:(NSURL *)anURL withWebViewController:(TNWebViewController *)webViewController
{
    return NO;
}

+ (NSDictionary*)dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding
{
    if(query.length == 0) {
        return nil;
    }
    
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString* value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}


@end
