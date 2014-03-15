//
//  RecordViewController.m
//  ServiceRecord
//
//  Created by Gray on 2/20/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import "RecordViewController.h"
#import "AppDelegate.h"
//#import "HTAutocompleteManager.h"

@interface RecordViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) NSArray *myMaintenanceArray;
@property (nonatomic, strong) NSString *myTitle;
//@property (nonatomic, strong) UITableView *vehicleTableView;
@property (nonatomic, strong) UIToolbar *mainToolbar;
//@property (nonatomic, strong) UITableView *propertyTableView;
@property (nonatomic, strong) UIToolbar *cameraToolbar;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDate *datePicked;
@property (nonatomic, strong) NSDateFormatter *dateFormat;



@property (nonatomic, strong) IBOutlet UITextField *costTextField;
@property (nonatomic, strong) IBOutlet UITextField *dateTextField;
@property (nonatomic, strong) IBOutlet UITextField *odometerTextField;
@property (nonatomic, strong) IBOutlet UITextField *taskTextField;
@property (nonatomic, strong) IBOutlet UITextView *noteTextView;
@property (nonatomic, strong) IBOutlet UIImageView *photoView;
@property (nonatomic, strong) IBOutlet NSData *photoData;
@property (nonatomic, strong) IBOutlet UIImage *photo;

- (IBAction)cancel:(id)sender;

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

UIActionSheet *pickerViewPopup;


@implementation RecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.selectedRecord)
    {
        self.title = [NSString stringWithFormat:@"Edit Record: %@ ",self.selectedRecord.task];

    }
    else
    {
        self.title = @"New Record";
    }
    [self.tableView reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    CGFloat customToolbarHeight = 40;


    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.mainToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - customToolbarHeight , self.view.frame.size.width, customToolbarHeight) ];
    self.mainToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
    
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(save:)]];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)]];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)]];
    
    //self.costTextField.delegate = self;
    [self.mainToolbar setItems:toolbarItems animated:NO];
    // [items release];
//    [self.view addSubview:self.mainToolbar];
    
    
    self.cameraToolbar = [UIToolbar new];
    self.cameraToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    //    self.cameraToolbar.backgroundColor = [UIColor whiteColor];
    self.cameraToolbar.barTintColor =[UIColor whiteColor];
    self.cameraToolbar.frame = CGRectMake(110, 35, 60, 30);

    NSMutableArray *cameraItems = [[NSMutableArray alloc] init];
    
    [cameraItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)]];
    
    [self.cameraToolbar setItems:cameraItems animated:NO];
    
    
    
//    self.propertyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - customToolbarHeight))];
//    self.propertyTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    self.propertyTableView.delegate = self;
//    self.propertyTableView.dataSource = self;
//    [self.view addSubview:self.propertyTableView];
    
    
    ////////////
    
//    self.datePicker = [UIDatePicker new];
//    [self.datePicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
//
    
    self.dateFormat = [NSDateFormatter new];
    [self.dateFormat setDateStyle:NSDateFormatterLongStyle];
    NSDate *today = [NSDate date];

    
    
    /////////////
    self.photoView.frame = CGRectMake(0, 30, 40, 40);

    CGFloat textFieldHeight = 50;

//    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];

    
    self.taskTextField = [UITextField new];
    self.taskTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.taskTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.taskTextField.font = [UIFont systemFontOfSize:15];
    self.taskTextField.placeholder = @"Task";
    self.taskTextField.autocorrectionType = UITextAutocorrectionTypeYes;
//    self.taskTextField.autocorrectionType = HTAutocompleteTypeColor;

    self.taskTextField.keyboardType = UIKeyboardTypeDefault;
    self.taskTextField.returnKeyType = UIReturnKeyDone;
    self.taskTextField.delegate = self;
    self.taskTextField.frame = CGRectMake(0, 10, 150, textFieldHeight);
    
    self.dateTextField = [UITextField new];
//    self.dateTextField.delegate = self;
    self.dateTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.dateTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.dateTextField.font = [UIFont systemFontOfSize:15];
    self.dateTextField.placeholder = @"Date";
    self.dateTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.dateTextField.keyboardType = UIKeyboardTypeDefault;
    self.dateTextField.returnKeyType = UIReturnKeyDone;
    self.dateTextField.enabled = NO;
    // Set current date
    self.dateTextField.text = [self.dateFormat stringFromDate:today];
    self.dateTextField.frame = CGRectMake(0, 10, 150, textFieldHeight);

    
    
    
    self.odometerTextField = [UITextField new];
    self.odometerTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.odometerTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.odometerTextField.font = [UIFont systemFontOfSize:15];
    self.odometerTextField.placeholder = @"Odometer";
    self.odometerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.odometerTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.odometerTextField.returnKeyType = UIReturnKeyDone;
    self.odometerTextField.delegate = self;
    self.odometerTextField.frame = CGRectMake(0, 10, 150, textFieldHeight);
    
    self.costTextField = [UITextField new];
    self.costTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth;
    self.costTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.costTextField.font = [UIFont systemFontOfSize:15];
    self.costTextField.placeholder = @"Cost";
    self.costTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.costTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.costTextField.delegate = self;
    self.costTextField.frame = CGRectMake(0, 10, 150, textFieldHeight);
    
    self.noteTextView = [UITextView new];
    self.noteTextView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth;
   // self.noteTextView.borderStyle = UITextBorderStyleRoundedRect;
    self.noteTextView.font = [UIFont systemFontOfSize:15];
    self.noteTextView.autocorrectionType = UITextAutocorrectionTypeYes;
    self.noteTextView.keyboardType = UIKeyboardTypeDefault;
    self.noteTextView.returnKeyType = UIReturnKeyDone;
    self.noteTextView.layer.borderColor = ([[UIColor lightGrayColor] CGColor]);
    self.noteTextView.layer.borderWidth = 0.5f;
    self.noteTextView.layer.cornerRadius = 8.0f;
    self.noteTextView.layer.masksToBounds = YES;
    self.noteTextView.frame = CGRectMake(0, 10, 150, 80);

//    self.noteTextView.delegate = self;



    
    if (self.selectedRecord)
    {
        self.costTextField.text = [NSString stringWithString:[self.selectedRecord.cost stringValue]];
        self.odometerTextField.text = [NSString stringWithString:[self.selectedRecord.odometer stringValue]];
        self.taskTextField.text = self.selectedRecord.task;
        self.dateTextField.text = [self.dateFormat stringFromDate:self.selectedRecord.date];
        self.noteTextView.text = self.selectedRecord.note;

        
        if  (self.selectedRecord.image)
        {
            self.photoView = [[UIImageView alloc]  initWithImage:[UIImage imageWithData:self.selectedRecord.image scale:[[UIScreen mainScreen] scale]]];
            [self.photoView sizeToFit];
//            self.photoView.frame = CGRectMake(10,0,40,40);
//            [self.view addSubview:self.photoView];
        }

        
        
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
//- (void)pickerChanged: (id)sender
//{
//    NSLog(@"value: %@",[sender date]);
////    self.dateTextField.text = @"%@",[sender date];
//}

//- (void)textFieldDidBeginEditing:(UITextField *)aTextField{
//   // [aTextField resignFirstResponder];
//    if (aTextField == self.dateTextField)
//    {
//    pickerViewPopup = [[UIActionSheet alloc] initWithTitle:@"Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    
//    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
//    self.datePicker.datePickerMode = UIDatePickerModeDate;
//    self.datePicker.hidden = NO;
//    self.datePicker.date = [NSDate date];
//    
//    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    pickerToolbar.barStyle = UIBarStyleDefault;
//    [pickerToolbar sizeToFit];
//    
//    NSMutableArray *barItems = [[NSMutableArray alloc] init];
//    
//    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    [barItems addObject:flexSpace];
//    
//    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
//    [barItems addObject:doneBtn];
//    
//    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
//    [barItems addObject:cancelBtn];
//    
//    [pickerToolbar setItems:barItems animated:YES];
//    
//    [pickerViewPopup addSubview:pickerToolbar];
//    [pickerViewPopup addSubview:self.datePicker];
//    [pickerViewPopup showInView:self.view];
//    [pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];
//    }
//}

-(void)doneButtonPressed:(id)sender{
  //  self.datePicked = [sender date];
    //self.dateTextField.text = @"%@",[sender date];
 ////   UIDatePicker *picker = (UIDatePicker *)sender;
//    NSDateFormatter *dateFormat = [NSDateFormatter new];
//    [dateFormat setDateStyle:NSDateFormatterLongStyle]
//    self.dateTextField.text = dateFormat strin;
//    self.datePicker.text = [dateFormat stringFromDate:self.datePicker.date];

    self.dateTextField.text = [self.dateFormat stringFromDate:self.datePicker.date];
    
    [pickerViewPopup resignFirstResponder];
//    self.dateTextField.text = [NSString stringWithFormat:@"%@", self.datePicker.date];
    [pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
}

-(void)cancelButtonPressed:(id)sender{
    [pickerViewPopup dismissWithClickedButtonIndex:0 animated:YES];
    [pickerViewPopup resignFirstResponder];
}

-(void)doneButtonPressed{
    //NULL method ATM needs to be filled
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return PropertyCount;
    //return [self.myVehicleArray count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    

    switch (indexPath.row) {
        case Task:{
            cell.textLabel.text = @"Task";
            cell.accessoryView = self.taskTextField;
//            [cell.contentView addSubview:self.taskTextField];
//            [cell.contentView bringSubviewToFront:self.taskTextField];
        }break;
        case Date:{
            cell.textLabel.text = @"Date";
            cell.accessoryView = self.dateTextField;
//            [cell.contentView addSubview:self.dateTextField];
//            [cell.contentView bringSubviewToFront:self.dateTextField];
        }break;
        case Odometer:{
            cell.textLabel.text = [NSString stringWithFormat:@"Odometer (%@) ",self.selectedVehicle.units];
            cell.accessoryView = self.odometerTextField;
//            [cell.contentView addSubview:self.odometerTextField];
//            [cell.contentView bringSubviewToFront:self.odometerTextField];
        }break;
        case Cost:{
            cell.textLabel.text = @"Cost";
            cell.accessoryView = self.costTextField;

//            [cell.contentView addSubview:self.costTextField];
//            [cell.contentView bringSubviewToFront:self.costTextField];
        }break;
        case Note:{
            cell.textLabel.text = @"Note";
            cell.accessoryView = self.noteTextView;
//            [cell.contentView addSubview:self.noteTextView];
//            [cell.contentView bringSubviewToFront:self.noteTextView];
        }break;
        case Photo:{
            cell.textLabel.text = @"Add Photo";
            //            cell.imageView.image = self.photoView.image;
            [cell.contentView addSubview:self.cameraToolbar];
            [cell.contentView bringSubviewToFront:self.cameraToolbar];
            [self.photoView sizeToFit];
            cell.accessoryView = self.photoView;
        
//            [cell.contentView addSubview:self.photoView];
//            [cell.contentView bringSubviewToFront:self.photoView];
            
            
        }break;
            
    }
    
    //
    //    NSManagedObject *device = self.vehicles[indexPath.row];
    //    [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", [device valueForKey:@"name"], [device valueForKey:@"odometer"] ]];
    //    [cell.detailTextLabel setText:[device valueForKey:@"model"]];
    
    
    //UIImageView *cellImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:data[@"image"]]];
    
    //cell.backgroundView = cellBgView;
    
    //NSDictionary *data = self.myVehicleArray[indexPath.row];
    //cell.textLabel.text = [NSString stringWithFormat: @"%@ %@", data[@"name"], data[@"model"] ];
    
    
    //    cell.imageView.image = self.photoView.image;
    
    
    //ADD A new button to cell
    //    UIButton *vehicleEditButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    [vehicleEditButton addTarget:self action:@selector(vehicleEdit) forControlEvents:UIControlEventTouchDown];
    //    vehicleEditButton.frame = CGRectMake(cell.frame.size.width - 80, (cell.frame.size.height - 20) /2, 80, 20);
    //    [vehicleEditButton setTitle:@"Edit" forState:UIControlStateNormal];
    //    vehicleEditButton.backgroundColor = [UIColor whiteColor];
    //    [vehicleEditButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [cell.contentView addSubview:vehicleEditButton];
    //    [cell.contentView bringSubviewToFront:vehicleEditButton];
    
    
    
    //  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    switch (indexPath.row) {
        case Note:{
            return 100.0;
        }break;
        case Photo:{
            return 100.0;
        }break;
    }
    return 60;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case Task:{
            [self.taskTextField becomeFirstResponder];
        
        }break;
        case Date:{
            
            pickerViewPopup = [[UIActionSheet alloc] initWithTitle:@"Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            [pickerViewPopup becomeFirstResponder];
            self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            self.datePicker.hidden = NO;
            self.datePicker.date = [NSDate date];
            
            UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
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
            
            [pickerViewPopup addSubview:pickerToolbar];
            [pickerViewPopup addSubview:self.datePicker];
            [pickerViewPopup showInView:self.view];
            [pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];

            
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
    }
}

-(void)saveButtonPressed{
    
    // if ( [self.dateTextField.text isEqual: @""] || [self.imageTextField.text isEqual:@""] || [self.odometerTextField.text isEqual:@"" ] || [self.costTextField.text  isEqual: @""] ){
    
    
    // }
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    // Create a new Record or exit existing record
    if ([self.taskTextField.text  isEqual: @""])
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter the task name."
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    else{
    if (self.selectedRecord)
    {
        self.selectedRecord.task = self.taskTextField.text;
        self.selectedRecord.odometer = [NSNumber numberWithInt: [self.odometerTextField.text intValue]];
        self.selectedRecord.date = [self.dateFormat dateFromString:self.dateTextField.text];
        self.selectedRecord.cost = [NSNumber numberWithInt: [self.costTextField.text intValue]];
        self.selectedRecord.note = self.noteTextView.text;

        self.selectedRecord.vehicle = self.selectedVehicle;
        self.title = [NSString stringWithFormat:@"Edit Record: %@ ",self.taskTextField.text];
        if  (self.photoData)
        {
            self.selectedRecord.image = self.photoData;
        }
//        [ServiceViewController.serviceTableView reloadData];

    }
    else
    {
    Record *newRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Record" inManagedObjectContext:delegate.managedObjectContext];
    newRecord.task = self.taskTextField.text;
    newRecord.date = [self.dateFormat dateFromString:self.dateTextField.text];
    newRecord.odometer = [NSNumber numberWithInt: [self.odometerTextField.text intValue]];
    newRecord.cost = [NSNumber numberWithInt: [self.costTextField.text intValue]];
    newRecord.note = self.noteTextView.text;
    newRecord.vehicle = self.selectedVehicle;
        
    if  (self.photoData)
    {
        newRecord.image = self.photoData;
    }

        
        
        //Clear text fields
        self.odometerTextField.text = Nil;
        self.dateTextField.text = Nil;
        self.noteTextView.text = Nil;
        self.taskTextField.text = Nil;
        self.costTextField.text = Nil;
        self.photoView.image = Nil;
    }
    NSError *error = nil;
    // Save the object to persistent store
    if (![delegate.managedObjectContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    //save changes
    [delegate.managedObjectContext save:Nil];


    
//    [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)settingsButtonPressed{ //NULL method ATM needs to be filled
}
-(void)featuredButtonPressed{ //NULL method ATM needs to be filled
}
-(void)topBuildsButtonPressed{ //NULL method ATM needs to be filled
}
-(void)cameraButtonPressed{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How would you like to select a photo?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Camera", @"Existing Photo", nil];
    
    [alert show];
    
    
    
}
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
                //[picker release];
                
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsupported!"
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
        //picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        //   [picker setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeImage]];
        
        //           picker.delegate = self;
        [picker setDelegate:self];
        picker.allowsEditing = YES;

        [self presentViewController:picker animated:YES completion:nil];
        
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unavailable!"
        //                                                        message:@"This device does not have a camera."
        //                                                       delegate:nil
        //                                              cancelButtonTitle:@"OK"
        //                                              otherButtonTitles:nil];
        //        [alert show];
    }
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"Media Info: %@", info);
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    //self.selectedVehicle.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // self.selectedVehicle.image = [NSData dataWithContentsOfFile:[info valueForKey:UIImagePickerControllerMediaType]];
    
    self.photo = [info objectForKey:UIImagePickerControllerEditedImage];
    //    self.photoData = UIImagePNGRepresentation(self.photo);
    //self.selectedVehicle.image = imageData;
    // UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 40)];
    // imageView.image = image;
    self.photoView = [[UIImageView alloc]  initWithImage:self.photo ];
    self.photoView.image = [self imageWithImage:self.photoView.image convertToSize:CGSizeMake(80, 80)];
    [self.photoView sizeToFit];
    self.photoData = UIImagePNGRepresentation(self.photoView.image);
    //    self.photoView.frame = CGRectMake(10,0,40,40);
    //    [self.view addSubview:self.photoView];
    // [self.view addSubview:imageView];
    
    
    //PNG// UIImage *image = [UIImage imageNamed:@"imageName.png"];
    //PNG// NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    //JPG// UIImage *image = [UIImage imageNamed:@"imageName.jpg"];
    //JPG// NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    //save-to-core-data// [newManagedObject setValue:imageData forKey:@"image"];
    //LOAD//
    //    NSManagedObject *selectedObject = [[self yourFetchCOntroller] objectAtIndexPath:indexPath];
    //    UIImage *image = [UIImage imageWithData:[selectedObject valueForKey:@"image"]];
    //    // and set this image in to your image View
    //    yourimageView.image=image;
    
    
    if([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage *photoTaken = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
        //Save Photo to library only if it wasnt already saved i.e. its just been taken
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(photoTaken, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    // [picker release];
}
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertView *alert;
    //NSLog(@"Image:%@", image);
    if (error) {
        alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                           message:[error localizedDescription]
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
        //  [alert release];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
