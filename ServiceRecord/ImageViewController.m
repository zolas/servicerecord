//
//  ImageViewController.m
//  ChainLube
//
//  Created by Gray on 2014-03-26.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//
// This ViewController shows a selected image fullscreen

#import "ImageViewController.h"

@interface ImageViewController () <UINavigationControllerDelegate,UIScrollViewDelegate>

@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self viewDidLoad];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (self.vehicleDelegate || self.recordDelegate) // Add save button if image came from Flickr search.
    {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveButtonPressed)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
   
    self.selectedImage.backgroundColor = [UIColor whiteColor];
    
    ///AASSSPEEECT RATTTIO////
    // if Width is bigger than height do one thing else do something else (includes square)
    //BUG in rotating display after zooming in portrait mode that it won't zoom in and if you rotate before you select a picture it will have an unusuable portion on screen.
//    if (self.selectedImage.frame.size.width < self.selectedImage.frame.size.height)
//    {
//         CGFloat ratio = self.selectedImage.frame.size.width / self.selectedImage.frame.size.height;
//        self.selectedImage.image = [self imageWithImage:self.selectedImage.image convertToSize:CGSizeMake(self.view.frame.size.height * ratio,self.view.frame.size.height)];
        self.selectedImage.frame = CGRectMake(0, 0, self.view.frame.size.height,self.view.frame.size.height);
//        self.selectedImage.center = self.view.center;
        self.selectedImage.contentMode = UIViewContentModeScaleAspectFit;
        self.selectedImage.clipsToBounds = NO;
//        self.selectedImage.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    
//    }
//    else
//    {
//        CGFloat ratio = self.selectedImage.frame.size.height / self.selectedImage.frame.size.width;
//        self.selectedImage.image = [self imageWithImage:self.selectedImage.image convertToSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.width * ratio)];
//        self.selectedImage.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.width * ratio);
//
//    }
    
//    self.selectedImage.bounds = CGRectMake(0, 0, self.selectedImage.image.size.width, self.selectedImage.image.size.height);
    
    UIScrollView *scrollImage = [UIScrollView new];
    scrollImage.delegate = self;
    scrollImage.clipsToBounds = YES;
    scrollImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    scrollImage.minimumZoomScale=0.25;
    scrollImage.maximumZoomScale=5.0;
    scrollImage.contentMode = UIViewContentModeScaleAspectFit;
    scrollImage.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    scrollImage.contentSize=CGSizeMake(self.selectedImage.frame.size.width, self.selectedImage.frame.size.height);
    scrollImage.showsHorizontalScrollIndicator = NO;
    scrollImage.showsVerticalScrollIndicator = NO;
    [scrollImage addSubview:self.selectedImage];
    [self.view addSubview:scrollImage];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.selectedImage;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)saveButtonPressed{
    if (self.vehicleDelegate) self.vehicleDelegate.flickrImage = self.selectedImage;
    else if (self.recordDelegate) self.recordDelegate.flickrImage = self.selectedImage;
    [self.navigationController popViewControllerAnimated:YES];
}


@end
