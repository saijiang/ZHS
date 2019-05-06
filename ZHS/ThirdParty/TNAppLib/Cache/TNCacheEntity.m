//
//  TNCacheEntity.m
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import "TNCacheEntity.h"


@implementation TNCacheEntity

@dynamic creationDate;
@dynamic data;
@dynamic dataClass;
@dynamic dataType;
@dynamic domain;
@dynamic key;
@dynamic modificationDate;
@dynamic storagePolicy;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.creationDate = [NSDate date];
}

@end
