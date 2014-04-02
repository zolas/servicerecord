//
//  ImageViewController.m
//  ChainLube
//
//  Created by Gray on 2014-03-26.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UINavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollImage;


@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self viewDidLoad];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
   
        self.selectedImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
        self.selectedImage.backgroundColor = [UIColor blackColor];
    self.selectedImage.image = [self imageWithImage:self.selectedImage.image convertToSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.width)];
//    self.selectedImage.bounds = CGRectMake(0, 0, self.selectedImage.image.size.width, self.selectedImage.image.size.height);
    self.scrollImage = [UIScrollView new];
    self.scrollImage.delegate = self;
    self.scrollImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.scrollImage.minimumZoomScale=0.5;
    self.scrollImage.maximumZoomScale=5.0;
    self.scrollImage.contentSize=CGSizeMake(1280, 960);

//    self.scrollImage.contentSize = self.selectedImage.image.size;
    self.scrollImage.showsHorizontalScrollIndicator = NO;
    self.scrollImage.showsVerticalScrollIndicator = NO;
    
    
//    UIImage* image = self.selectedImage.image;
    
//    float xNewOrigin = [TCBRandom randomIntLessThan:image.size.width - scrollView.bounds.size.width];
//    float yNewOrigin = [TCBRandom randomIntLessThan:image.size.height - scrollView.bounds.size.height];
    
//    CGRect oldRect = self.scrollImage.bounds;
//    CGRect newRect = CGRectMake(
//                                xNewOrigin,
//                                yNewOrigin,
//                                self.scrollImage.bounds.size.width,
//                                self.scrollImage.bounds.size.height);
    
//    float xDistance = fabs(xNewOrigin - oldRect.origin.x);
//    float yDistance = fabs(yNewOrigin - oldRect.origin.y);
//    float hDistance = sqrtf(powf(xDistance, 2) + powf(yDistance, 2));
//    float hDistanceInPixels = hDistance;
//    
//    float animationDuration = hDistanceInPixels / speedInPixelsPerSecond;
    
//    [UIView beginAnimations:@"pan" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    self.scrollImage.contentOffset = newRect.origin;
//    [UIView commitAnimations];
    
//    [self.selectedImage sizeToFit];
    [self.scrollImage addSubview:self.selectedImage];
        [self.view addSubview:self.scrollImage];
    // Do any additional setup after loading the view.
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.selectedImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (void)pinch:(UIPinchGestureRecognizer *)gesture {
//    if (gesture.state == UIGestureRecognizerStateEnded
//        || gesture.state == UIGestureRecognizerStateChanged) {
//        NSLog(@"gesture.scale = %f", gesture.scale);
//        
////        CGFloat currentScale = self.frame.size.width / self.bounds.size.width;
//        CGFloat currentScale = self.view.frame.size.width / self.view.frame.size.width;
//
//        CGFloat newScale = currentScale * gesture.scale;
//        
//        if (newScale < MINIMUM_SCALE) {
//            newScale = MINIMUM_SCALE;
//        }
//        if (newScale > MAXIMUM_SCALE) {
//            newScale = MAXIMUM_SCALE;
//        }
//        
//        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
//        self.transform = transform;
//        gesture.scale = 1;
//    }
//}
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
