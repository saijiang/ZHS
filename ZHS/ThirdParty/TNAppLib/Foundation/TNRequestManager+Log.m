//
//  TNRequestManager+Log.m
//  WeZone
//
//  Created by kiri on 2013-11-04.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNRequestManager+Log.h"

@implementation TNRequestManager (Log)

#pragma mark - LogBatch
- (TNRequest *)requestLogBatchWithData:(NSData *)data sync:(BOOL)isSync completion:(TNRequestCompletionHandler)completion
{
    return [self sendServiceRequestWithSubpath:@"/log/batch" getParams:nil postParams:data responseClass:NULL preparationHandler:^(TNRequest *request) {
        request.HTTPHeaderFields = @{@"Content-Type": @"application/json", @"Content-Encoding": @"gzip"};
    } completion:completion inQueue:isSync ? [NSOperationQueue currentQueue] : self.concurrentQueue waitUntilFinished:isSync needToken:YES];
}

@end
