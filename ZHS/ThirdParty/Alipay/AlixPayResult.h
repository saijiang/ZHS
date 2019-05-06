//
//  AlixPayResult.h
//  MSPInterface
//
//  Created by 邢小迪 on 15-1-06.
//  Copyright 2015 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlixPayResult : NSObject {
	int		  _statusCode;
	NSString *_statusMessage;
	NSString *_resultString;
	NSString *_signString;
	NSString *_signType;
}

@property(nonatomic, readonly) int statusCode;
@property(nonatomic, readonly) NSString *statusMessage;
@property(nonatomic, readonly) NSString *resultString;
@property(nonatomic, readonly) NSString *signString;
@property(nonatomic, readonly) NSString *signType;

- (id)initWithString:(NSDictionary *)string;
@end
