//
//  ImageViewController.h
//  ChainLube
//
//  Created by Gray on 2014-03-26.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleViewController.h"
#import "RecordViewController.h"

@interface ImageViewController : UIViewController
@property (nonatomic) UIImageView *selectedImage;
@property (nonatomic) UIImageView *selectedImageThumb;
@property (nonatomic, weak) VehicleViewController *vehicleDelegate;
@property (nonatomic, weak) RecordViewController *recordDelegate;

@end
