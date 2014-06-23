//
//  ImageSearchViewController.m
//  ChainLube
//
//  Created by Gray on 2014-05-04.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import "ImageSearchViewController.h"
#import "VehicleViewController.h"
#import "ImageViewController.h"

#define flickrKey @"61426f3ba050d2fec1cfa17f9a71f95d"


@interface ImageSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>
@property (nonatomic, strong) UICollectionView *flickrResult;
@property (nonatomic, strong) IBOutlet UITextField *searchPhraseTextField;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSMutableArray *flickrThumbPhotos;
@property (nonatomic, strong) NSMutableArray *flickrDisplayPhotos;
@property (nonatomic) NSInteger selectedCell;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property (nonatomic) NSInteger flickrPage;
@property (nonatomic) NSInteger flickrMaxPage;
@property (nonatomic, strong) UIAlertView *alert;

@end

@implementation ImageSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = @-40;
    xAxis.maximumRelativeValue = @40;
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = @-40;
    yAxis.maximumRelativeValue = @40;
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis,yAxis];
    
    [self.alert addMotionEffect:group];
    
    self.flickrThumbPhotos = [NSMutableArray new];
    self.flickrDisplayPhotos = [NSMutableArray new];

    
    self.title = @"Search Flickr";

    self.searchPhraseTextField = [UITextField new];
    self.searchPhraseTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchPhraseTextField.font = [UIFont systemFontOfSize:15];
    self.searchPhraseTextField.placeholder = @"Search keyword";
    self.searchPhraseTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchPhraseTextField.keyboardType = UIKeyboardTypeDefault;
    self.searchPhraseTextField.returnKeyType = UIReturnKeySearch;
    self.searchPhraseTextField.delegate = self;
    self.searchPhraseTextField.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    self.searchPhraseTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.searchPhraseTextField];
    
    [self.searchPhraseTextField becomeFirstResponder];
    
    UICollectionViewFlowLayout *collectionLayout= [[UICollectionViewFlowLayout alloc]init];
    
    self.flickrResult = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, (self.view.frame.size.height - 60)) collectionViewLayout:collectionLayout];

    collectionLayout.collectionView.backgroundColor = [UIColor whiteColor];
    collectionLayout.minimumInteritemSpacing = 1;
    collectionLayout.minimumLineSpacing = 1;
    collectionLayout.itemSize = CGSizeMake(79, 79);
    collectionLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [collectionLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.flickrResult.collectionViewLayout = collectionLayout;
    self.flickrResult.delegate = self;
    self.flickrResult.dataSource = self;
    [self.flickrResult registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.flickrResult.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.flickrResult registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
    [self.view addSubview:self.flickrResult];
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.color = self.navigationController.navigationBar.tintColor;
    self.indicator.frame = CGRectMake(self.searchPhraseTextField.frame.size.width - 60, 10, 40.0, 40.0);
    self.indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin ;
    [self.view addSubview:self.indicator];
    
}

#pragma mark - UICollectionView method implementation

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1 ;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.flickrDisplayPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
        UIImageView *cellBgView =[[UIImageView alloc] initWithImage:self.flickrDisplayPhotos[indexPath.item][@"thumb"]];
        cellBgView.contentMode = UIViewContentModeScaleAspectFill;
        cellBgView.clipsToBounds = YES;
        cell.backgroundView = cellBgView;
        NSLog(@"E7 %@",[NSDate date]);
        cell.layer.borderColor = nil;
        cell.layer.borderWidth = 0.0f;
        
        if (self.selectedCell == indexPath.item){
            cell.layer.borderColor = [UIColor redColor].CGColor;
            cell.layer.borderWidth = 3.0f;
        }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)view didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.searchPhraseTextField resignFirstResponder];
    self.selectedCell = indexPath.item;
    [self.flickrResult reloadData];
    [self showFullscreen:indexPath.item];
    
}

#pragma mark - Search method implementation

- (void)searchFlickr {
    [self.indicator startAnimating];
    
    NSString *escapedSearchTerm= [self.searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *searchURL = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&sort=relevance&text=%@&per_page=36&page=%d&format=json&nojsoncallback=1",flickrKey,escapedSearchTerm,self.flickrPage ];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSLog(@"E0, %.1f ms", (time-[NSDate timeIntervalSinceReferenceDate])*1000);
        NSString *searchResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL] encoding:NSUTF8StringEncoding error:&error];
        if (error != nil) {
            NSLog(@"E1");
        } else {
            NSData *jsonData = [searchResult dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultParameters = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                             options:kNilOptions
                                                                               error:&error];
            if(error != nil){
                //                completionBlock(term,nil,error);
                NSLog(@"E2");
                
            }else{
                NSString *status = resultParameters[@"stat"];
                if ([status isEqualToString:@"fail"]) {
                    NSLog(@"E3");
                    
                } else {
                    NSLog(@"E4, %.1f ms", (time-[NSDate timeIntervalSinceReferenceDate])*1000);
                    
                    NSArray *resultPhotoArray = resultParameters[@"photos"][@"photo"];
                    if (resultPhotoArray.count > 0){
                        if (self.flickrMaxPage == 0) self.flickrMaxPage = [resultParameters[@"photos"][@"pages"] integerValue];
                        for(NSMutableDictionary *resultPhoto in resultPhotoArray){
                            NSString *photoSizes = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getsizes&api_key=%@&photo_id=%lld&format=json&nojsoncallback=1",flickrKey,[resultPhoto[@"id"] longLongValue]];
                            NSString *sizeResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:photoSizes] encoding:NSUTF8StringEncoding error:&error];
                            if (error != nil) {
                                //            completionBlock(term,nil,error);
                                NSLog(@"E1");
                            } else {
                                
                                
                                NSData *jsonData = [sizeResult dataUsingEncoding:NSUTF8StringEncoding];
                                NSDictionary *resultSizeParameters = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                                
                                if (error != nil) {
                                    //            completionBlock(term,nil,error);
                                    NSLog(@"E1");
                                } else {
                                    if ([resultSizeParameters[@"stat"]  isEqual: @"ok"]){
                                        NSArray *resultPhotoSizeArray = resultSizeParameters[@"sizes"][@"size"];
                                        __block NSString *photoLargeURL = [NSString new];
                                        __block NSString *photoThumbURL = [NSString new];
                                        
                                        //check if photo is landscape or portrait.
                                        __block int smallWidth = 0;
                                        __block int bigWidth = 0;
                                        __block int maxBigWidth = 1610;
                                        __block int minBigWidth = 330;
                                        
                                        
                                        [resultPhotoSizeArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                                            
                                            int maxSmallWidth = 250;
                                            if ([obj[@"label"]  isEqual: @"Large"]){
                                                photoLargeURL = obj[@"source"];
                                                bigWidth = -1;
                                            }else if ([obj[@"label"]  isEqual: @"Thumbnail"]){                                 photoThumbURL = obj[@"source"];
                                                smallWidth = -1;
                                            }else if (smallWidth == 0 && [obj[@"width"] integerValue ]< maxSmallWidth ){
                                                photoThumbURL = obj[@"source"];
                                                smallWidth = [obj[@"width"] integerValue];
                                            }else if (smallWidth > 0 && [obj[@"width"] integerValue ]< smallWidth ){
                                                photoThumbURL = obj[@"source"];
                                                smallWidth = [obj[@"width"] integerValue];
                                            }else if (bigWidth == 0 && [obj[@"width"] integerValue ]> minBigWidth ){
                                                photoLargeURL = obj[@"source"];
                                                bigWidth = [obj[@"width"] integerValue];
                                            }else if (bigWidth > 0 && maxBigWidth > [obj[@"width"] integerValue ] && [obj[@"width"] integerValue ] > bigWidth ){
                                                photoLargeURL = obj[@"source"];
                                                bigWidth = [obj[@"width"] integerValue];
                                                
                                            }
                                        }];
                                        
                                        if (! [photoThumbURL isEqual: [NSNull null]] || ! [photoLargeURL isEqual: [NSNull null]]){
                                            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoThumbURL] options:0 error:&error];
                                            if (error == nil) {
                                                
                                                UIImage *image = [UIImage imageWithData:imageData];
                                                [self.flickrThumbPhotos addObject:@{@"thumb":image,@"bigphotoURL":photoLargeURL}];
                                            }
                                            else{
                                                NSLog(@"Thumb Lost = %@ Large Lost= %@",photoThumbURL,photoLargeURL);
                                            }
                                            
                                            
                                        }else {
                                            //throw error
                                        }
                                    }}}
                            
                            NSLog(@"E5, %.1f ms", (time-[NSDate timeIntervalSinceReferenceDate])*1000);
                            
                        }dispatch_async(dispatch_get_main_queue(),^{
                            [self.indicator stopAnimating];
                            self.flickrDisplayPhotos = self.flickrThumbPhotos;
                            [self.flickrResult reloadData];
                            if (self.flickrPage > 1) {
                                [UIView animateWithDuration:0.2 animations:^{
                                    self.flickrResult.contentOffset = CGPointMake(0, self.flickrResult.contentOffset.y + 70);
                                }];
                            }
                        });}
                    else{
                        dispatch_async(dispatch_get_main_queue(),^{
                        
                        self.alert = [[UIAlertView new] initWithTitle:@"Flickr is not available at this time"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:nil];
                        [self.alert show];
                        [self.indicator stopAnimating];
                        });
                    }
                }
            }
        }
    });
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        //        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (self.indicator.isAnimating) return;
    
    if (self.flickrMaxPage > self.flickrPage) {
        if (self.flickrResult.contentOffset.y > (self.flickrResult.contentSize.height - self.view.frame.size.height - 80)){
                self.flickrPage ++;
                [self searchFlickr];
        }
    }
}

-(void)showFullscreen:(NSInteger) i {

    if (self.flickrDisplayPhotos.count >= i){
        NSError *error = nil;
        ImageViewController *ic = [ImageViewController new];
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.flickrDisplayPhotos[i][@"bigphotoURL"]] options:0 error:&error];
        
        if (error == nil){
            UIImage *image = [UIImage imageWithData:imageData];
            ic.selectedImage = [[UIImageView alloc] initWithImage:image];
            ic.vehicleDelegate = self.vehicleDelegate;
            [self.navigationController pushViewController:ic animated:YES];
        }else{
            self.alert = [[UIAlertView new] initWithTitle:@"Flickr Image is not available at this time"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil];
            [self.alert show];
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.indicator.isAnimating) return;
    [self.flickrResult reloadData];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    [textField resignFirstResponder];
    self.selectedCell = -1;
    self.flickrPage = 1;
    self.flickrMaxPage = 0;
    self.flickrThumbPhotos = [NSMutableArray new];
    self.searchTerm = self.searchPhraseTextField.text;
    
    [self searchFlickr];
    
    return YES;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
