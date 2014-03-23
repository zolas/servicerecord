//
//  Record.h
//  ChainLube
//
//  Created by Gray on 2014-03-22.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RecordPhoto, Vehicle;

@interface Record : NSManagedObject

@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * odometer;
@property (nonatomic, retain) NSString * task;
@property (nonatomic, retain) Vehicle *vehicle;
@property (nonatomic, retain) NSOrderedSet *photos;
@end

@interface Record (CoreDataGeneratedAccessors)

- (void)insertObject:(RecordPhoto *)value inPhotosAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhotosAtIndex:(NSUInteger)idx;
- (void)insertPhotos:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePhotosAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPhotosAtIndex:(NSUInteger)idx withObject:(RecordPhoto *)value;
- (void)replacePhotosAtIndexes:(NSIndexSet *)indexes withPhotos:(NSArray *)values;
- (void)addPhotosObject:(RecordPhoto *)value;
- (void)removePhotosObject:(RecordPhoto *)value;
- (void)addPhotos:(NSOrderedSet *)values;
- (void)removePhotos:(NSOrderedSet *)values;
@end
