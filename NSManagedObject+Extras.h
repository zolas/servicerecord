//
//  NSManagedObject+Extras.h
//  ChainLube
//
//  Created by Gray on 2014-07-15.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (NSObject)

- (NSString *)jsonStringValue;
- (NSDictionary *)propertiesDictionary:(NSMutableDictionary *)combinedAttributes;

@end
