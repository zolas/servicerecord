//
//  ImageSearchViewController.m
//  ChainLube
//
//  Created by Gray on 2014-05-04.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import "ImageSearchViewController.h"
#import "VehicleViewController.h"

#define flickrKey @"61426f3ba050d2fec1cfa17f9a71f95d"


@interface ImageSearchViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>
@property (nonatomic, strong) UICollectionView *flickrResult;
@property (nonatomic, strong) IBOutlet UITextField *searchPhraseTextField;
@property (nonatomic, strong) NSMutableArray *flickrPhotos;


@end

@implementation ImageSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
//self.vehicleDelegate.flickrImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"im31.jpg"]];
    
    
    // float width = self.view.bounds.size.width;
    //  float height = self.view.bounds.size.height;
    
    //[self.label setFrame:CGRectMake(width-100,height-100, 100, 100)];
    
  UILabel *labelSearch = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    labelSearch.text = @"Search Flickr";
  labelSearch.backgroundColor = [UIColor clearColor];
  labelSearch.textColor = [UIColor blackColor];
  [labelSearch sizeToFit];
//  labelSearch.center = CGPointMake(self.view.center.x,labelSearch.frame.size.height/2);
  labelSearch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//  labelSearch.center = (self.view.frame.size.width / 2, 22);
    //    [self.view addSubview:labelCategory];
  [self.view addSubview:labelSearch];
    self.searchPhraseTextField = [UITextField new];
    self.searchPhraseTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchPhraseTextField.font = [UIFont systemFontOfSize:15];
    self.searchPhraseTextField.placeholder = @"Search for Images";
    self.searchPhraseTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchPhraseTextField.keyboardType = UIKeyboardTypeDefault;
    self.searchPhraseTextField.returnKeyType = UIReturnKeyDone;
    self.searchPhraseTextField.delegate = self;
    self.searchPhraseTextField.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    [self.view addSubview:self.searchPhraseTextField];
    
    UICollectionViewFlowLayout *collectionLayout= [[UICollectionViewFlowLayout alloc]init];
    
    self.flickrResult = [[UICollectionView alloc] initWithFrame:CGRectMake(90, 0, self.view.frame.size.width, (self.view.frame.size.height - 40)) collectionViewLayout:collectionLayout];
    collectionLayout.collectionView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    collectionLayout.minimumInteritemSpacing = 15;
    // [collectionLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.flickrResult.collectionViewLayout = collectionLayout;
    self.flickrResult.delegate = self;
    self.flickrResult.dataSource = self;
    //    UICollectionViewFlowLayout *collectionViewLayout2 = (UICollectionViewFlowLayout*)self.flickrResult.collectionViewLayout;
    //    collectionViewLayout2.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    [self.flickrResult registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.flickrResult.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.flickrResult registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
    
    
    
    [self.view addSubview:self.flickrResult];
    

}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [ self.flickrResult reloadData];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self searchFlickr:textField.text];
    [self.flickrResult reloadData];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    [self searchFlickr:textField.text];
    [self.flickrResult reloadData];
    
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    //return [self.collectionArray count];
    return self.flickrPhotos.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    //UIImageView *cellBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.collectionArray[indexPath.section] objectAtIndex:indexPath.row]]];
    //recipeImageView.image = [UIImage imageNamed:[recipeImages[indexPath.section] objectAtIndex:indexPath.row]];
    UIImageView *cellBgView =[[UIImageView alloc] initWithImage:self.flickrPhotos[indexPath.item]];
    cell.backgroundView = cellBgView;
    return cell;
    
    
    
    
    //    CGFloat i = indexPath.item / 10.0;
    // cell.contentView.backgroundColor = [UIColor colorWithRed:i green:1.-i blue:0.2 alpha:1];
    
}
#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //if cv = ...
    return CGSizeMake(80, 60);
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)view didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)searchFlickr:(NSString *)searchTerm {
    self.flickrPhotos = [NSMutableArray new];
    searchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *searchURL = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&per_page=15&format=json&nojsoncallback=1",flickrKey,searchTerm];
//    NSString *searchURL = [Flickr flickrSearchURLForSearchTerm:term];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSString *searchResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL] encoding:NSUTF8StringEncoding error:&error];
        if (error != nil) {
//            completionBlock(term,nil,error);
        }
        else
        {
            // Parse the JSON Response
            NSData *jsonData = [searchResult dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultParameters = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                              options:kNilOptions
                                                                                error:&error];
            if(error != nil){
//                completionBlock(term,nil,error);
            }else{
                NSString *status = resultParameters[@"stat"];
                if ([status isEqualToString:@"fail"]) {
//                    NSError  *error = [[NSError alloc] initWithDomain:@"FlickrSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: resultParameters[@"message"]}];
////                    completionBlock(term, nil, error);
                } else {
                    
//                    self.flickrPhotos = resultParameters[@"photos"][@"photo"];
                    NSArray *resultPhotoArray = resultParameters[@"photos"][@"photo"];
//                    NSMutableArray *flickrPhotos = [@[] mutableCopy];
                    for(NSMutableDictionary *resultPhoto in resultPhotoArray){
//                        FlickrPhoto *photo = [[FlickrPhoto alloc] init];
//                        [self.flickrPhotos addObject: @{@"photoid": @"BlackMamba", @"farm" : @"im1.jpg", @"server" : @"dfd", @"secret" : @"sdfsd", @"Image": @"im.png", @"Thmbimg" : @"im3.jpg"}];
//                        photo.farm = [resultPhoto[@"farm"] intValue];
//                        photo.server = [resultPhoto[@"server"] intValue];
//                        photo.secret = resultPhoto[@"secret"];
//                        photo.photoID = [resultPhoto[@"id"] longLongValue];
                        NSString *size = @"m";
                        NSString *photoURL = [NSString stringWithFormat:@"http://farm%d.staticflickr.com/%d/%lld_%@_%@.jpg",[resultPhoto[@"farm"] intValue],[resultPhoto[@"server"] intValue],[resultPhoto[@"id"] longLongValue],resultPhoto[@"secret"],size];

//                        NSString *searchURL = [Flickr flickrPhotoURLForFlickrPhoto:photo size:@"m"];
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]
                                                                  options:0
                                                                    error:&error];
                        UIImage *image = [UIImage imageWithData:imageData];
//                        photo.thumbnail = image;
                        [self.flickrPhotos addObject:image];
//                        [flickrPhotos addObject:photo];
                    }
                    
//                    completionBlock(term,flickrPhotos,nil);
                }
            }
        }
        [self.flickrResult reloadData];

    });

}

/*
 
 self.myNewBuildArray = @[
 @{@"photoid": @"BlackMamba", @"farm" : @"im1.jpg", @"server" : @"dfd", @"secret" : "sdfsd", @"Image": @"im.png", @"Thmbimg" : @"im3.jpg"},
 @{@"name": @"Cphynx", @"image" : @"im2.jpg"},
 @{@"name": @"Croku", @"image" : @"im3.jpg"},
 @{@"name": @"DezyMu", @"image" : @"im4.jpg"},
 @{@"name": @"mikaL", @"image" : @"im5.jpg"},
 @{@"name": @"Stanche", @"image" : @"im6.jpg"},
 @{@"name": @"glenReeves", @"image" : @"im7.jpg"},
 @{@"name": @"wrinok", @"image" : @"im8.jpg"},
 @{@"name": @"subrest", @"image" : @"im9.jpg"},
 @{@"name": @"moskann", @"image" : @"im10.jpg"},
 @{@"name": @"catylist", @"image" : @"im11.jpg"},
 @{@"name": @"barpokil", @"image" : @"im12.jpg"},
 @{@"name": @"thecayotee", @"image" : @"im13.jpg"},
 @{@"name": @"thecayotee2", @"image" : @"im14.jpg"},
 ];

*/


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
