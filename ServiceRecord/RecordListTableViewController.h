//
//  RecordListTableViewController.h
//  ChainLube
//
//  Created by Gray on 2014-07-25.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceViewController.h"

@interface RecordListTableViewController : UITableViewController

@property (nonatomic) NSArray *records;
@property (nonatomic) NSString *units;
@property (nonatomic) NSMutableArray *selectedRecords;
@property (nonatomic, weak) ServiceViewController *serviceDelegate;

@end
