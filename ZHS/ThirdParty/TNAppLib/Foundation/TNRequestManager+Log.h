//
//  TNRequestManager+Log.h
//  WeZone
//
//  Created by kiri on 2013-11-04.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNRequestManager.h"

@interface TNRequestManager (Log)

#pragma mark - LogBatch
/*!
 *  responseObject is nil. Use request.response.statusCode plz.
 *  @param data The post data.
 *  @param isSync Should block current thread.
 *  @param completion Always callback in main thread.
 *  @note If isSync is YES, the request run in current Queue.
 */
- (TNRequest *)requestLogBatchWithData:(NSData *)data sync:(BOOL)isSync completion:(TNRequestCompletionHandler)completion;

@end
