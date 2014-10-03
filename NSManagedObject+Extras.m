//
//  NSManagedObject+Extras.m
//  ChainLube
//
//  Created by Gray on 2014-07-15.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import "NSManagedObject+Extras.h"
//#import "NSDictionary+BSJSONAdditions.h"
//#import "NSArray+BSJSONAdditions.h"

@implementation NSManagedObject (NSObject)


//Export
- (NSDictionary *)propertiesDictionary:(NSMutableDictionary *)combinedAttributes
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//    combinedAttributes = [NSMutableDictionary new];
//    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    dispatch_async(queue, ^{
//        NSError *error = nil;
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        
        for (id property in [[self entity] properties])
        {
            //        NSLog(@"Property: %@", property);
            if ([property isKindOfClass:[NSAttributeDescription class]])
            {
                NSAttributeDescription *attributeDescription = (NSAttributeDescription *)property;
                NSString *type = [attributeDescription attributeValueClassName];
                NSString *name = [attributeDescription name];
                NSString *entity = [[attributeDescription entity] name];
                
                if ([type isEqualToString:@"NSString"]){
                    // Check required fields and fill them in if the data cannot be retrieved.
                    if ([entity isEqualToString:@"Vehicle"]&&[name isEqualToString:@"name"] && [[self valueForKey:name] isEqualToString:@""])
                        [properties setValue:@"unknown name" forKey:name];
                    else if ([entity isEqualToString:@"Record"]&&[name isEqualToString:@"task"] && [[self valueForKey:name] isEqualToString:@""])
                        [properties setValue:@"unknown task" forKey:name];
                    else    [properties setValue:[self valueForKey:name] forKey:name];
                }
                else if ([type isEqualToString:@"NSData"]){
                    NSData *object = [self valueForKey:name];
                    NSData *base64Object =[object base64EncodedDataWithOptions:0];
                    [properties setValue:[NSString stringWithUTF8String:[base64Object bytes]] forKey:name];
                    //http://iosdevelopertips.com/core-services/encode-decode-using-base64.html
                }
                else if ([type isEqualToString:@"NSNumber"]){
                    NSNumber *num = [self valueForKey:name];
                    [properties setValue:[num stringValue] forKey:name];
                }
                else if ([type isEqualToString:@"NSDate"]){
                    NSDate *date = [self valueForKey:name];
                    NSDateFormatter *dateFormat = [NSDateFormatter new];
                    [dateFormat setDateStyle:NSDateFormatterLongStyle];
                    [properties setValue:[dateFormat stringFromDate:date] forKey:name];
                }
                //            NSLog(@"Property: ", [self
                
            }
            
            
            if ([property isKindOfClass:[NSRelationshipDescription class]])
            {
                NSRelationshipDescription *relationshipDescription = (NSRelationshipDescription *)property;
                NSString *name = [relationshipDescription name];
                
                if ([relationshipDescription isToMany])
                {
                    NSMutableArray *arr = [properties valueForKey:name];
                    if (!arr)
                    {
                        arr = [[NSMutableArray alloc] init];
                        [properties setValue:arr forKey:name];
                    }
                    
                    //                for (NSManagedObject *o in [self mutableSetValueForKey:name])
                    //                    [arr addObject:[o propertiesDictionary]];
                    
                    
                    
                    if ([self isKindOfClass:[Vehicle class]]){
                        Vehicle *v = self;
                        for (Record *r in v.records){
                            NSMutableDictionary *newRelationship = [NSMutableDictionary new];
                            NSDictionary *entityRelationship = [r propertiesDictionary:newRelationship];
                            [combinedAttributes addEntriesFromDictionary:entityRelationship];
                        }
                    }
                    else if ([self isKindOfClass:[Record class]]){
                        Record *r = self;
                        for (RecordPhoto *rp in r.photos){
                            NSMutableDictionary *newRelationship = [NSMutableDictionary new];

                            NSDictionary *entityRelationship = [rp propertiesDictionary:newRelationship];
                            [combinedAttributes addEntriesFromDictionary:entityRelationship];
                        }
                    }
                    else if ([self isKindOfClass:[RecordPhoto class]]){
                        
                    }
                    
                    
                }
                //            else
                //            {
                //                NSManagedObject *o = [self valueForKey:name];
                //                [properties setValue:[o propertiesDictionary] forKey:name];
                //            }
            }
        }
        [combinedAttributes addEntriesFromDictionary:properties];
    });
    
    return combinedAttributes;

}

- (NSString *)attributesToString{
    
    return @"string";
}

- (NSString *)jsonStringValue
{
    NSMutableDictionary *combinedAttributes = [NSMutableDictionary new];
    return [[self propertiesDictionary:combinedAttributes] description];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
