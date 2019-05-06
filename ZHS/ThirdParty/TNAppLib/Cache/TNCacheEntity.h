//
//  TNCacheEntity.h
//  TNAppLib
//
//  Created by kiri on 2013-11-08.
//  Copyright (c) 2013年 Telenav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TNCacheEntity : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSString * dataClass;
@property (nonatomic, retain) NSNumber * dataType;
@property (nonatomic, retain) NSNumber * domain;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSNumber * storagePolicy;

@end
