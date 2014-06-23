//
//  VehicleViewController.m
//  ServiceRecord
//
//  Created by Gray on 2/18/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//
// This ViewController manages vehicle details
// FREE ICON from http://www.visualpharm.com/free_icons.html


#import "VehicleViewController.h"
#import "ImageSearchViewController.h"

@interface VehicleViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSString *units;
@property (nonatomic, strong) UITextView *noteTextView;
@property (nonatomic, strong) UISegmentedControl *unitsSegment;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextView *specTextView;
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) NSData *photoData;

@end

enum Properties {
    Name = 0,
    Spec,
    Note,
    Units,
    Photo,
    PropertyCount
};

UIActionSheet *pickerViewPopup;


@implementation VehicleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Set title based on editing or adding new vehicle information
    if (self.selectedVehicle) self.title = [NSString stringWithFormat:@"Edit Vehicle"];
    else self.title = @"Add New Vehicle";
    
    //Handle Flickr image
    if (self.flickrImage){
        self.photoView = self.flickrImage;
        self.photoView.image = [self imageWithImage:self.photoView.image convertToSize:CGSizeMake(80, 80)];
        [self.photoView sizeToFit];
        self.photoData = UIImagePNGRepresentation(self.photoView.image);
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //Interpolating Motion Effect Group
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = @-40;
    xAxis.maximumRelativeValue = @40;
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = @-40;
    yAxis.maximumRelativeValue = @40;
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis,yAxis];
    
    self.photoView.frame = CGRectMake(0, 30, 40, 40);
    
    // Add vehicle button on Navigation bar
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // UISegmented control for the Units
    self.unitsSegment = [[UISegmentedControl alloc] initWithItems:@[@"km",@"mi"]];
    self.unitsSegment.frame = CGRectMake(0, 10, 150, 50);
    self.unitsSegment.selectedSegmentIndex = 0;
    [self.unitsSegment addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    self.units = @"km"; // default unit
    
    self.specTextView = [UITextView new];
    self.specTextView.font = [UIFont systemFontOfSize:15];
    self.specTextView.layer.borderColor = ([[UIColor lightGrayColor] CGColor]);
    self.specTextView.layer.borderWidth = 0.5f;
    self.specTextView.layer.cornerRadius = 8.0f;
    self.specTextView.layer.masksToBounds = YES;
    self.specTextView.autocorrectionType = UITextAutocorrectionTypeYes;
    self.specTextView.keyboardType = UIKeyboardTypeDefault;
    self.specTextView.returnKeyType = UIReturnKeyDefault;
    self.specTextView.frame = CGRectMake(0, 10, 150, 80);
    
    self.nameTextField = [UITextField new];
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField.font = [UIFont systemFontOfSize:15];
    self.nameTextField.placeholder = @"Name";
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.delegate = self;
    self.nameTextField.frame = CGRectMake(0, 0, 150, 50);
    
    self.noteTextView = [UITextView new];
    self.noteTextView.font = [UIFont systemFontOfSize:15];
    self.noteTextView.autocorrectionType = UITextAutocorrectionTypeYes;
    self.noteTextView.keyboardType = UIKeyboardTypeDefault;
    self.noteTextView.returnKeyType = UIReturnKeyDefault;
    self.noteTextView.layer.borderColor = ([[UIColor lightGrayColor] CGColor]);
    self.noteTextView.layer.borderWidth = 0.5f;
    self.noteTextView.layer.cornerRadius = 8.0f;
    self.noteTextView.layer.masksToBounds = YES;
    self.noteTextView.frame = CGRectMake(0, 10, 150, 80);
    
    //Change text frame for IPAD
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.noteTextView.frame = CGRectMake(0, 10, 300, 80);
        self.nameTextField.frame = CGRectMake(0, 0, 300, 50);
        self.specTextView.frame = CGRectMake(0, 10, 300, 80);
    }
    
    //Fill in the fields and properties if this is an existing vehicle
    if (self.selectedVehicle){
        self.nameTextField.text = self.selectedVehicle.name;
        self.specTextView.text = self.selectedVehicle.spec;
        self.noteTextView.text = self.selectedVehicle.note;
        
        if  (self.selectedVehicle.image){
            self.photoView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.selectedVehicle.image scale:[[UIScreen mainScreen] scale]]];
        }
        
        self.unitsSegment.selectedSegmentIndex = [self.selectedVehicle.units isEqual: @"mi"] ? 1 : 0;
        
        self.units = self.selectedVehicle.units;
    }
}

# pragma mark TableView Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return PropertyCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //Clear reusable cell properties
    cell.imageView.image = nil;
    cell.accessoryView = nil;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    
    //Default camera icon
    UIImageView *cameraView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera.png"]];
    
    switch (indexPath.row) {
        case Name:{
            cell.textLabel.text = @"Name";
            cell.accessoryView = self.nameTextField;
            
        }break;
        case Spec:{
            cell.textLabel.text = @"Spec";
            cell.accessoryView = self.specTextView;
            
        }break;
        case Note:{
            cell.textLabel.text = @"Note";
            cell.accessoryView = self.noteTextView;
            
        }break;
        case Units:{
            cell.textLabel.text = @"Units";
            cell.accessoryView = self.unitsSegment;
            
        }break;
        case Photo:{
            cell.textLabel.text = @"Add Photo";
            
            //If we don't have an image yet, use the camera icon
            if (! self.photoView.image)
                cell.accessoryView = cameraView;
            
            else{
                [self.photoView sizeToFit];
                cell.accessoryView = self.photoView;
            }
            
        }break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row){
        case Note:{
            return 100.0;
        }break;
        case Spec:{
            return 100.0;
        }break;
        case Photo:{
            return 120.0;
        }break;
    }
    return 60; // default row height
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case Name:{
            [self.nameTextField becomeFirstResponder];
        }break;
        case Spec:{
            [self.specTextView becomeFirstResponder];
        }break;
        case Note:{
            [self.noteTextView becomeFirstResponder];
        }break;
        case Photo:{
            [self cameraButtonPressed];
        }break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark Segmented Control method Implementations

- (void)segmentedControlValueDidChange:(UISegmentedControl *)segment{
    self.units = segment.selectedSegmentIndex == 1 ? @"mi": @"km";
}

#pragma mark Button press method implementations

- (void)doneButtonPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)saveButtonPressed{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    //Alert the user if the required name is missing
    if ([self.nameTextField.text isEqual: @""]){
        UIAlertView *alert = [[UIAlertView new] initWithTitle:@"Please enter the vehicle name"
                                                      message:@""
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        if (self.selectedVehicle){ //Assign new data to existing object
            self.selectedVehicle.name = self.nameTextField.text;
            self.selectedVehicle.spec = self.specTextView.text;
            self.selectedVehicle.note = self.noteTextView.text;
            self.selectedVehicle.units = self.units;
            self.title = [NSString stringWithFormat:@"Edit %@",self.nameTextField.text];
            
            if  (self.photoData) self.selectedVehicle.image = self.photoData;
            
        }else{  //Create a new object and populate the data
            Vehicle *newVehicle = [NSEntityDescription insertNewObjectForEntityForName:@"Vehicle" inManagedObjectContext:delegate.managedObjectContext];
            newVehicle.name = self.nameTextField.text;
            newVehicle.spec = self.specTextView.text;
            newVehicle.note = self.noteTextView.text;
            newVehicle.odometer = 0;
            newVehicle.units = self.units;
            
            if  (self.photoData) newVehicle.image = self.photoData;
            
            //Clear all fields  - need to investigate
            self.nameTextField.text = Nil;
            self.specTextView.text = Nil;
            self.photoView.image = Nil;
            self.noteTextView.text = Nil;
        }
        
        // Save the object to persistent store
        [delegate saveContext];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)cameraButtonPressed{
    UIAlertView *alert = [[UIAlertView new] initWithTitle:@"How would you like to select a photo?"
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Camera", @"Existing Photo",@"Flickr", nil];
    [alert show];
}

#pragma mark AlertView method implementation

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1){  // Camera
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            NSArray *media = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            
            if ([media containsObject:(NSString*)kUTTypeImage] == YES) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                [picker setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeImage]];
                picker.allowsEditing = YES; // allows image editing
                [picker setDelegate:self];
                [self presentViewController:picker animated:YES completion:nil];
            }else{
                UIAlertView *alert = [[UIAlertView new] initWithTitle:@"Unsupported!"
                                                              message:@"Camera does not support photo capturing."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
                [alert show];
            }
            
        }
    }else if (buttonIndex == 2){  //Existing Photo
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        [picker setDelegate:self];
        [self presentViewController:picker animated:YES completion:nil];
    }else if (buttonIndex == 3){  //Flickr Photo
        ImageSearchViewController *is = [ImageSearchViewController new];
        is.vehicleDelegate = self;
        [self.navigationController pushViewController:is animated:YES];
    }
}

#pragma mark - Image implementation methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"Media Info: %@", info);
    //Save the image
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *photo = info[UIImagePickerControllerEditedImage];
    self.photoView = [[UIImageView alloc] initWithImage:[self imageWithImage:photo convertToSize:CGSizeMake(80, 80)]];
    self.photoData = UIImagePNGRepresentation(self.photoView.image);
    
    if([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage *photoTaken = info[@"UIImagePickerControllerEditedImage"];
        
        //Save Photo to library only if it wasnt already saved
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(photoTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    //TODO make sure mismatched aspect ratio is handled correctly
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView new] initWithTitle:@"Error!"
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
