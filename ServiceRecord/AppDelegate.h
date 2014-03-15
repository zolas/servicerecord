//
//  AppDelegate.h
//  ServiceRecord
//
//  Created by Gray on 2/10/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,retain, readonly) NSManagedObjectContext* managedObjectContext;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
