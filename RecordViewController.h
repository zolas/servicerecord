//
//  RecordViewController.h
//  ServiceRecord
//
//  Created by Gray on 2/20/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceViewController.h"

@interface RecordViewController : UITableViewController

@property (nonatomic) Vehicle *selectedVehicle;
@property (nonatomic) Record *selectedRecord;

@end
