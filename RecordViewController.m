//
//  RecordViewController.m
//  ServiceRecord
//
//  Created by Gray on 2/20/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//
// This ViewController manages a vehicle record

#import "RecordViewController.h"
#import "AppDelegate.h"
#import "ImageViewController.h"
#import "ImageSearchViewController.h"



@interface RecordViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, UIPopoverControllerDelegate>


@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormat;
@property (nonatomic, strong) NSMutableArray *photoRecords;

@property (nonatomic, strong) UITextField *costTextField;
@property (nonatomic, strong) UITextField *dateTextField;
@property (nonatomic, strong) UITextField *odometerTextField;
@property (nonatomic, strong) UITextField *taskTextField;
@property (nonatomic, strong) UITextView *noteTextView;


//- (IBAction)cancel:(id)sender;

@end

enum Properties {
    Task = 0,
    Date,
    Odometer,
    Cost,
    Note,
    Photo,
    PropertyCount
};

//UIActionSheet *pickerViewPopup;
UIView *pickerViewPopup;
UIPopoverController *datePopover;

@implementation RecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.selectedRecord){
        self.title = [NSString stringWithFormat:@"Edit Record"];
    }
    else
    {
        self.title = @"New Record";
    }
    //Handle Flickr image
    if (self.flickrImage) [self flickrImageFound];

    [self.tableView reloadData];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.tableView reloadData];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // UIMotion effects group
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = @-40;
    xAxis.maximumRelativeValue = @40;
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = @-40;
    yAxis.maximumRelativeValue = @40;
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis,yAxis];
    
    // Add save button on Navigation bar
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    //Set today's date as default record date
    self.dateFormat = [NSDateFormatter new];
    [self.dateFormat setDateStyle:NSDateFormatterLongStyle];
    NSDate *today = [NSDate date];

    CGFloat textFieldHeight = 50;
    self.taskTextField = [UITextField new];
    self.taskTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.taskTextField.font = [UIFont systemFontOfSize:15];
    self.taskTextField.placeholder = @"Task";
    self.taskTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    self.taskTextField.keyboardType = UIKeyboardTypeDefault;
    self.taskTextField.returnKeyType = UIReturnKeyDone;
    self.taskTextField.delegate = self;
    self.taskTextField.frame = CGRectMake(0, 10, 150, textFieldHeight);
    
    self.dateTextField = [UITextField new];
    self.dateTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.dateTextField.font = [UIFont systemFontOfSize:15];
    self.dateTextField.placeholder = @"Date";
    self.dateTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.dateTextField.keyboardType = UIKeyboardTypeDefault;
    self.dateTextField.returnKeyType = UIReturnKeyDone;
    self.dateTextField.enabled = NO;
    self.dateTextField.text = [self.dateFormat stringFromDate:today];
    self.dateTextField.frame = CGRectMake(0, 10, 150, textFieldHeight);

    self.odometerTextField = [UITextField new];
    self.odometerTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.odometerTextField.font = [UIFont systemFontOfSize:15];
    self.odometerTextField.placeholder = @"Odometer";
    self.odometerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.odometerTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.odometerTextField.delegate = self;
    self.odometerTextField.frame = CGRectMake(0, 10, 150, textFieldHeight);
    
    self.costTextField = [UITextField new];
    self.costTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.costTextField.font = [UIFont systemFontOfSize:15];
    self.costTextField.placeholder = @"Cost";
    self.costTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.costTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.costTextField.delegate = self;
    self.costTextField.frame = CGRectMake(0, 10, 150, textFieldHeight);
    
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
        self.taskTextField.frame = CGRectMake(0, 10, 300, textFieldHeight);
        self.noteTextView.frame = CGRectMake(0, 10, 300, 80);
    }

    self.photoRecords = [NSMutableArray new];
    
    //Fill in the fields and properties if this is an existing record
    if (self.selectedRecord){
        self.costTextField.text = [NSString stringWithString:[self.selectedRecord.cost stringValue]];
        self.odometerTextField.text = [NSString stringWithString:[self.selectedRecord.odometer stringValue]];
        self.taskTextField.text = self.selectedRecord.task;
        self.dateTextField.text = [self.dateFormat stringFromDate:self.selectedRecord.date];
        self.noteTextView.text = self.selectedRecord.note;
        
        //Enumerate over existing photo objects and add them to the UI
        [self.selectedRecord.photos enumerateObjectsUsingBlock:^(RecordPhoto *b, NSUInteger i, BOOL *stop) {
            UITextField *newTextField = [UITextField new];
            
            //Change text frame for IPAD
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                newTextField.frame = CGRectMake(0, 10, 300, 50);
            else newTextField.frame = CGRectMake(0, 10, 150, 50);

            newTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            newTextField.borderStyle = UITextBorderStyleRoundedRect;
            newTextField.font = [UIFont systemFontOfSize:15];
            newTextField.placeholder = @"Label";
            newTextField.autocorrectionType = UITextAutocorrectionTypeYes;
            newTextField.returnKeyType = UIReturnKeyDone;
            newTextField.delegate = self;
            if (b.label) newTextField.text = b.label;
            UIImage *thumbImage = [self imageWithImage:[UIImage imageWithData:b.photo scale:1.0]convertToSize:CGSizeMake(120,120)];
            [self.photoRecords addObject:@{@"photo":b.photo,@"label":newTextField,@"thumb":thumbImage}];
        }];
    }
}

#pragma  mark TableView Method Implementations

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.photoRecords.count + PropertyCount;
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
    
    switch (indexPath.row) {
        case Task:{
            cell.textLabel.text = @"Task";
            cell.accessoryView = self.taskTextField;
        }break;
        case Date:{
            cell.textLabel.text = @"Date";
            cell.accessoryView = self.dateTextField;
        }break;
        case Odometer:{
            cell.textLabel.text = [NSString stringWithFormat:@"Odometer (%@) ",self.selectedVehicle.units];
            cell.accessoryView = self.odometerTextField;
        }break;
        case Cost:{
            cell.textLabel.text = @"Cost";
            cell.accessoryView = self.costTextField;
        }break;
        case Note:{
            cell.textLabel.text = @"Note";
            cell.accessoryView = self.noteTextView;
        }break;
        case Photo:{
            cell.textLabel.text = @"Add Photo";
            cell.imageView.image = nil;
            UIImageView *cameraView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera.png"]];
            cell.accessoryView = cameraView;
        }break;
        default:{
            long i = indexPath.row - PropertyCount;

//                   UIImageView *existingPhoto = [[UIImageView alloc]  initWithImage:[UIImage imageWithData:k[@"photo"] scale:[[UIScreen mainScreen] scale]]];
//                    [existingPhoto sizeToFit];
            cell.imageView.image = self.photoRecords[i][@"thumb"];

//                    cell.imageView.image = existingPhoto.image;
                    cell.accessoryView = self.photoRecords[i][@"label"];
        }break;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    switch (indexPath.row) {
        case Task:{
            return 60.0;
        }break;
        case Date:{
            return 60.0;
        }break;
        case Odometer:{
            return 60.0;
        }break;
        case Cost:{
            return 60.0;
        }break;
        default:{
            return 100;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        default:{
            long i = indexPath.row - PropertyCount; //Only edit the image fields to delete photos
            if (i >=0) return YES;
            else return NO;
        }break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //Delete selected photo object
    switch (indexPath.row) {
        default:{
            long i = indexPath.row - PropertyCount;
            if (self.photoRecords.count > i){
                [self.photoRecords removeObjectAtIndex:i];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case Task:{
            [self.taskTextField becomeFirstResponder];
        }break;
        case Date:{
            [self showDatePicker];
        }break;
        case Cost:{
            [self.costTextField becomeFirstResponder];
        }break;
        case Odometer:{
            [self.odometerTextField becomeFirstResponder];
        }break;
        case Note:{
            [self.noteTextView becomeFirstResponder];
        }break;
        case Photo:{
            [self cameraButtonPressed];
        }break;
        default:{ //Calculate what photo must have been selected and show in fullscreen
            long i = indexPath.row - PropertyCount;
            [self.photoRecords enumerateObjectsUsingBlock:^(NSDictionary *k, NSUInteger idx, BOOL *stop) {
                if (idx == i){
                    [self showFullscreen: i]; //Show the photo in full screen
                }
            }];
        }break;
    }
}

#pragma mark DatePicker method implementation

- (void) showDatePicker{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIViewController *popoverContent = [[UIViewController alloc]init];
        UIView *popoverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 300)];
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker.hidden = NO;
        self.datePicker.date = [NSDate date];
        
        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
        pickerToolbar.barStyle = UIBarStyleDefault;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        [barItems addObject:cancelBtn];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        [barItems addObject:doneBtn];
        
        [pickerToolbar setItems:barItems animated:YES];

        popoverContent.view = popoverView;
        [popoverView addSubview:pickerToolbar];
        [popoverView addSubview:self.datePicker];
        popoverContent.preferredContentSize = CGSizeMake(300, 300);
        
        datePopover =[[UIPopoverController alloc] initWithContentViewController:popoverContent];
        [datePopover presentPopoverFromRect:self.dateTextField.frame inView:self.dateTextField.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES ];
        [datePopover setDelegate:self];
        
    }else {
        
//        pickerViewPopup = [[UIActionSheet alloc] initWithTitle:@"Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        pickerViewPopup = [[UIView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 350), self.view.frame.size.width, self.view.frame.size.height)];
        pickerViewPopup.backgroundColor = [UIColor whiteColor];
        [pickerViewPopup becomeFirstResponder];
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker.hidden = NO;
        self.datePicker.date = [NSDate date];
        
        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        pickerToolbar.barStyle = UIBarStyleDefault;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        [barItems addObject:cancelBtn];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        [barItems addObject:doneBtn];
        
        [pickerToolbar setItems:barItems animated:YES];
        [self.view addSubview:pickerViewPopup];
//        [pickerViewPopup showInView:self.view];
        CGFloat datePickerHeight = self.datePicker.frame.size.height + pickerToolbar.frame.size.height;
        [pickerViewPopup setFrame:(CGRectMake(0, self.view.frame.size.height - datePickerHeight , self.view.frame.size.width, datePickerHeight))];
        
        [pickerViewPopup addSubview:pickerToolbar];
        [pickerViewPopup addSubview:self.datePicker];
    }

}

#pragma mark Button Pressed Method Implementations

- (void)doneButtonPressed:(id)sender{
    // Provide a method for picking a date based on if device is iphone or ipad
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [datePopover dismissPopoverAnimated:YES ];
    else{
        [pickerViewPopup resignFirstResponder];
        [pickerViewPopup removeFromSuperview];
//        [pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
    }
    
    self.dateTextField.text = [self.dateFormat stringFromDate:self.datePicker.date];
}

- (void)cancelButtonPressed:(id)sender{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [datePopover dismissPopoverAnimated:YES ];
    else{
//        [pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
        [pickerViewPopup resignFirstResponder];
        [pickerViewPopup removeFromSuperview];

    }
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveButtonPressed{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    // Check if record name is supplied
    if ([self.taskTextField.text  isEqual: @""])
    {
        
        UIAlertView *alert = [[UIAlertView new] initWithTitle:@"Please enter the task name."
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    else{
        if (self.selectedRecord) //Save modifications to existing record
        {
            self.selectedRecord.task = self.taskTextField.text;
            self.selectedRecord.odometer = [NSNumber numberWithInt: [self.odometerTextField.text intValue]];
            self.selectedRecord.date = [self.dateFormat dateFromString:self.dateTextField.text];
            self.selectedRecord.cost = [NSNumber numberWithInt: [self.costTextField.text intValue]];
            self.selectedRecord.note = self.noteTextView.text;
            self.selectedRecord.vehicle = self.selectedVehicle;
            self.title = [NSString stringWithFormat:@"Edit Record: %@ ",self.taskTextField.text];
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;

            if (self.photoRecords.count == 0) { //If record had no photos, add new photos
                [self.selectedRecord.photos enumerateObjectsUsingBlock:^(RecordPhoto *k, NSUInteger idx, BOOL *stop) {
                    [delegate.managedObjectContext deleteObject:k];
                }];
            }else{ //If record had previous photos, overwrite existing photoset with new one
                
                [self.selectedRecord.photos enumerateObjectsUsingBlock:^(RecordPhoto *k, NSUInteger idx, BOOL *stop) {
                [delegate.managedObjectContext deleteObject:k];
                }];

                [self.photoRecords enumerateObjectsUsingBlock:^(NSDictionary *k, NSUInteger i, BOOL *stop) {
                    UITextField *d = k[@"label"];
                    
                    if (self.selectedRecord.photos.count < i){
                        RecordPhoto *c = self.selectedRecord.photos[i];
                        c.photo = k[@"photo"];
                        if (d.text) c.label = d.text;
                    }else{
                        RecordPhoto *c = [NSEntityDescription insertNewObjectForEntityForName:@"RecordPhoto" inManagedObjectContext:delegate.managedObjectContext];
                        if (d.text) c.label = d.text;
                        c.photo = k[@"photo"];
                        c.record = self.selectedRecord;
                    }
                }];
            }
        }else{ //If this is a new record, create and populate the new record object
            Record *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:delegate.managedObjectContext];
            newRecord.task = self.taskTextField.text;
            newRecord.date = [self.dateFormat dateFromString:self.dateTextField.text];
            newRecord.odometer = [NSNumber numberWithInt: [self.odometerTextField.text intValue]];
            newRecord.cost = [NSNumber numberWithInt: [self.costTextField.text intValue]];
            newRecord.note = self.noteTextView.text;
            newRecord.vehicle = self.selectedVehicle;
    
            [self.photoRecords enumerateObjectsUsingBlock:^(NSDictionary *k, NSUInteger i, BOOL *stop) {
                    RecordPhoto *c = [NSEntityDescription insertNewObjectForEntityForName:@"RecordPhoto" inManagedObjectContext:delegate.managedObjectContext];
                    UITextField *d = k[@"label"];
                    c.photo = k[@"photo"];
                    if (d.text) c.label = d.text;
                    c.record = newRecord;
            }];
        
            //Clear text fields
            self.odometerTextField.text = Nil;
            self.dateTextField.text = Nil;
            self.noteTextView.text = Nil;
            self.taskTextField.text = Nil;
            self.costTextField.text = Nil;
        }
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

#pragma mark Image method impelementations

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            NSArray *media = [UIImagePickerController
                              availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
            
            if ([media containsObject:(NSString*)kUTTypeImage] == YES) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                [picker setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeImage]];
                picker.allowsEditing = YES;

                [picker setDelegate:self ];
                [self presentViewController:picker animated:YES completion:nil];
            }else {
                UIAlertView *alert = [[UIAlertView new] initWithTitle:@"Unsupported!"
                                                                message:@"Camera does not support photo capturing."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else if (buttonIndex == 2){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [picker setDelegate:self];
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if (buttonIndex == 3){  //Flickr Photo
        ImageSearchViewController *is = [ImageSearchViewController new];
        is.recordDelegate = self;
        [self.navigationController pushViewController:is animated:YES];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"Media Info: %@", info);
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    UIImage *photo = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImageView *photoView = [[UIImageView alloc]  initWithImage:photo];
    photoView.image = [self imageWithImage:photoView.image convertToSize:CGSizeMake(photoView.image.size.width,photoView.image.size.height)];
    NSData *photoData = UIImagePNGRepresentation(photoView.image);
    
    UITextField *newTextField = [UITextField new];
    newTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    newTextField.borderStyle = UITextBorderStyleRoundedRect;
    newTextField.font = [UIFont systemFontOfSize:15];
    newTextField.placeholder = @"Label";
    newTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    newTextField.returnKeyType = UIReturnKeyDone;
    newTextField.delegate = self;
    newTextField.frame = CGRectMake(0, 10, 150, 50);
    UIImage *thumbImage = [self imageWithImage:[UIImage imageWithData:photoData scale:1.0]convertToSize:CGSizeMake(120,120)];
    [self.photoRecords addObject:@{@"photo":photoData,@"label":newTextField,@"thumb":thumbImage}];

    if([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage *photoTaken = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
        //Save Photo to library only if it wasnt already saved i.e. its just been taken
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(photoTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
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

-(void)showFullscreen:(NSInteger) i {
        
            if (self.photoRecords.count > i ){
                NSDictionary *k = self.photoRecords[i];
                UIImageView *existingPhoto = [[UIImageView alloc]  initWithImage:[UIImage imageWithData:k[@"photo"]]];
                ImageViewController *ic = [ImageViewController new];
                ic.selectedImage = existingPhoto;
                [self.navigationController pushViewController:ic animated:YES];
            }
}

- (void)flickrImageFound{
    self.flickrImage.image = [self imageWithImage:self.flickrImage.image convertToSize:CGSizeMake(self.flickrImage.image.size.width,self.flickrImage.image.size.height)];
    NSData *photoData = UIImagePNGRepresentation(self.flickrImage.image);
    UITextField *newTextField = [UITextField new];
    newTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    newTextField.borderStyle = UITextBorderStyleRoundedRect;
    newTextField.font = [UIFont systemFontOfSize:15];
    newTextField.placeholder = @"Label";
    newTextField.autocorrectionType = UITextAutocorrectionTypeYes;
    newTextField.returnKeyType = UIReturnKeyDone;
    newTextField.delegate = self;
    newTextField.frame = CGRectMake(0, 10, 150, 50);
    UIImage *thumbImage = [self imageWithImage:[UIImage imageWithData:photoData scale:1.0]convertToSize:CGSizeMake(120,120)];

    [self.photoRecords addObject:@{@"photo":photoData,@"label":newTextField,@"thumb":thumbImage}];
    self.flickrImage = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
