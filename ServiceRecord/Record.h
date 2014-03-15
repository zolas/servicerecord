//
//  Record.h
//  ServiceRecord
//
//  Created by Gray on 2014-03-10.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Vehicle;

@interface Record : NSManagedObject

@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * odometer;
@property (nonatomic, retain) NSString * task;
@property (nonatomic, retain) Vehicle *vehicle;

@end
