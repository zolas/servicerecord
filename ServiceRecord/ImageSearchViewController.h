//
//  ImageSearchViewController.h
//  ChainLube
//
//  Created by Gray on 2014-05-04.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleViewController.h"
#import "RecordViewController.h"

@interface ImageSearchViewController : UIViewController
@property (nonatomic, weak) VehicleViewController *vehicleDelegate;
@property (nonatomic, weak) RecordViewController *recordDelegate;

@end
