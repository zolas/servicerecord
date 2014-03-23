//
//  RecordPhoto.h
//  ChainLube
//
//  Created by Gray on 2014-03-22.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Record;

@interface RecordPhoto : NSManagedObject

@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) Record *record;

@end
