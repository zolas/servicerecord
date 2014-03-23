//
//  Vehicle.h
//  ChainLube
//
//  Created by Gray on 2014-03-22.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Record;

@interface Vehicle : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * odometer;
@property (nonatomic, retain) NSString * spec;
@property (nonatomic, retain) NSString * units;
@property (nonatomic, retain) NSOrderedSet *records;
@end

@interface Vehicle (CoreDataGeneratedAccessors)

- (void)insertObject:(Record *)value inRecordsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRecordsAtIndex:(NSUInteger)idx;
- (void)insertRecords:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRecordsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRecordsAtIndex:(NSUInteger)idx withObject:(Record *)value;
- (void)replaceRecordsAtIndexes:(NSIndexSet *)indexes withRecords:(NSArray *)values;
- (void)addRecordsObject:(Record *)value;
- (void)removeRecordsObject:(Record *)value;
- (void)addRecords:(NSOrderedSet *)values;
- (void)removeRecords:(NSOrderedSet *)values;
@end
