//
//  VehicleViewController.m
//  ServiceRecord
//
//  Created by Gray on 2/18/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//
/*
 Text fields are too narrow
 What's the relevance to the name vs spec
 touch cell to select UITextField
 When done with DatePicker nothing should be in focus. 
 Make it so that when I click save it pops the user back to the list of vehicles.
 Work on the camera choices
 Add label to the camera icon that says: "Add a photo" - make cell selectable.
 Note section for the vehicle for tire specs or anything like that.
 Be friendlier in errors "Invalid entry!" is scary.
 When user clicks done on the keyboard, the keyboard should hide. Delegate for UITextfield that has that method.
 Draw border around UITextView for notes.
 Put done and cancel on opposite sides of UIDatePicker instead of together.
 w
 Photo is kind of small, can I make it bigggggger!!!?!?!
 Display dates for records in service view.
 Have a list of services to pick from
 To go back after you add a record.
 Organize records according to date. Should be latest records be on top instead of FIFO.
 Bug rotates picture 90 degrees if taken in portrait mode.
 Scale the picture to fit cell size. Make it bigger. that's what she said! 
 Can you confirm delete? ! !? ! ?! ?! ?! ?! !? ! !? ?!? ! ! 
 # Kill user so there won't be any complaints.
 when adding a new vehicle odometer goes down to zero. Don't display odometer if it's zero.
 
 
 #The miles/km can be a simple popup in the vehicle odometer settings. You click on the odometer settings for the vehicle and it asks you miles or km at which point everything gets converted between imperial and metric for all records. 
 #It can also be a slider between miles - km inside the odometer cell. 
 # Or it can be two buttons on the right hand side of the cell. One selected and one deselected with labels of km | miles.
 # Or it can be a units cell/attribute that allows you to select between L/km, Gallon/mi, etc... as evident in MPG.
 
 #Change  model to vehicle specs.
 #Remove odometer from vehicle settings and remove year from vehicle settings.
 #make cells bigger
  # Units still doesn't save or work
 # Image needs to be high res and work on import/export.
 
 Modified core data to include a one to many relationship between a new entity <photorecords> and records. Will add a cell for each photo selected and will add a blank textfield for a label for the photo.
 
 //look for global properties that are only used locally within methods.
 */



#import "VehicleViewController.h"
#import "ImageSearchViewController.h"

@interface VehicleViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSArray *myMaintenanceArray;
@property (nonatomic, strong) NSString *myTitle;
@property (nonatomic, strong) NSString *units;
@property (nonatomic, strong) UITableView *vehicleTableView;
@property (nonatomic, strong) UIToolbar *mainToolbar;
@property (nonatomic, strong) UIToolbar *cameraToolbar;
//@property (nonatomic, strong) UIDatePicker *datePicker;
//@property (nonatomic, strong) NSDateFormatter *dateFormat;
@property (nonatomic, strong) IBOutlet UITextView *noteTextView;
@property (nonatomic, strong) UISegmentedControl *unitsSegment;


@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextView *specTextView;
//@property (nonatomic, strong) IBOutlet UITextField *odometerTextField;
//@property (nonatomic, strong) IBOutlet UITextField *yearTextField;
@property (nonatomic, strong) IBOutlet UIImageView *photoView;
@property (nonatomic, strong) IBOutlet NSData *photoData;
@property (nonatomic, strong) IBOutlet UIImage *photo;
@property (nonatomic, strong) IBOutlet UIImageView *cameraView;





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
    if (self.selectedVehicle)
    {
        self.title = [NSString stringWithFormat:@"Edit Vehicle"];
    }
    else
    {
    self.title = @"Add New Vehicle";
    }
    if (self.flickrImage)
    {
        self.photoView = self.flickrImage;
        self.photoView.image = [self imageWithImage:self.photoView.image convertToSize:CGSizeMake(80, 80)];
        [self.photoView sizeToFit];

    }
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    

//    CGFloat customToolbarHeight = 40;
    self.photoView.frame = CGRectMake(0, 30, 40, 40);
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    ///TOOLBAR
//    self.mainToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - customToolbarHeight , self.view.frame.size.width, customToolbarHeight) ];
//    self.mainToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
//    
//    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(save:)]];
//    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)]];
//    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)]];
//    
//    //self.nameTextField.delegate = self;
//    [self.mainToolbar setItems:toolbarItems animated:NO];
    // [items release];
//    [self.view addSubview:self.mainToolbar];
    
//    self.cameraToolbar = [UIToolbar new];
//    self.cameraToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
////    self.cameraToolbar.backgroundColor = [UIColor whiteColor];
//    self.cameraToolbar.barTintColor =[UIColor whiteColor];
//    self.cameraToolbar.frame = CGRectMake(0, 0, 60, 30);
    
//    NSMutableArray *cameraItems = [[NSMutableArray alloc] init];
//    
//    [cameraItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)]];
    
//    [self.cameraToolbar setItems:cameraItems animated:NO];
    CGFloat textFieldHeight = 50;

    
    /// FREE ICON from http://www.visualpharm.com/free_icons.html
    
    
    ////////TOOLBAR///////
    
    
    self.unitsSegment = [[UISegmentedControl alloc] initWithItems:@[@"km",@"mi"]];
    self.unitsSegment.frame = CGRectMake(0, 10, 150, textFieldHeight);
    self.unitsSegment.selectedSegmentIndex = 0;
    [self.unitsSegment addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];

    self.units = @"km";
//    self.datePicker = [UIDatePicker new];
//    [self.datePicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
    
//    self.dateFormat = [NSDateFormatter new];
//    [self.dateFormat setDateFormat:@"yyyy"];
    
   
//    self.propertyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - customToolbarHeight))];
//    self.propertyTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    self.propertyTableView.delegate = self;
//    self.propertyTableView.dataSource = self;
//    [self.view addSubview:self.propertyTableView];

    self.cameraView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera.png"]];
    
    self.specTextView = [UITextView new];
    self.specTextView.font = [UIFont systemFontOfSize:15];
//    self.specTextView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth;
    self.specTextView.layer.borderColor = ([[UIColor lightGrayColor] CGColor]);
    self.specTextView.layer.borderWidth = 0.5f;
    self.specTextView.layer.cornerRadius = 8.0f;
    self.specTextView.layer.masksToBounds = YES;
    self.specTextView.autocorrectionType = UITextAutocorrectionTypeYes;
    self.specTextView.keyboardType = UIKeyboardTypeDefault;
    self.specTextView.returnKeyType = UIReturnKeyDefault;
    self.specTextView.frame = CGRectMake(0, 10, 150, 80);

//    self.specTextView.delegate = self;
    

    
//    [self.view addSubview:self.specTextView];
    
    
//    self.odometerTextField = [UITextField new];
//    self.odometerTextField.borderStyle = UITextBorderStyleRoundedRect;
//    self.odometerTextField.font = [UIFont systemFontOfSize:15];
//    self.odometerTextField.placeholder = @"Odometer";
//    self.odometerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
//    self.odometerTextField.keyboardType = UIKeyboardTypeNumberPad;
//    self.odometerTextField.returnKeyType = UIReturnKeyDone;
//    self.odometerTextField.delegate = self;
////    [self.view addSubview:self.odometerTextField];
//    
//    
//    self.yearTextField = [UITextField new];
////    self.yearTextField.delegate = self;
//    self.yearTextField.borderStyle = UITextBorderStyleRoundedRect;
//    self.yearTextField.font = [UIFont systemFontOfSize:15];
//    self.yearTextField.placeholder = @"Year";
//    self.yearTextField.enabled = NO;
//    self.yearTextField.autocorrectionType = UITextAutocorrectionTypeNo;
//    self.yearTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
//    self.yearTextField.returnKeyType = UIReturnKeyDone;
    
//    [self.view addSubview:self.yearTextField];
    
    self.nameTextField = [UITextField new];
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField.font = [UIFont systemFontOfSize:15];
    self.nameTextField.placeholder = @"Name";
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.delegate = self;
    self.nameTextField.frame = CGRectMake(0, 0, 150, textFieldHeight);
    
    
    self.noteTextView = [UITextView new];
//    self.noteTextView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth;
    // self.noteTextView.borderStyle = UITextBorderStyleRoundedRect;
    self.noteTextView.font = [UIFont systemFontOfSize:15];
    self.noteTextView.autocorrectionType = UITextAutocorrectionTypeYes;
    self.noteTextView.keyboardType = UIKeyboardTypeDefault;
    self.noteTextView.returnKeyType = UIReturnKeyDefault;
    self.noteTextView.layer.borderColor = ([[UIColor lightGrayColor] CGColor]);
    self.noteTextView.layer.borderWidth = 0.5f;
    self.noteTextView.layer.cornerRadius = 8.0f;
    self.noteTextView.layer.masksToBounds = YES;
    self.noteTextView.frame = CGRectMake(0, 10, 150, 80);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.noteTextView.frame = CGRectMake(0, 10, 300, 80);
        self.nameTextField.frame = CGRectMake(0, 0, 300, textFieldHeight);
        self.specTextView.frame = CGRectMake(0, 10, 300, 80);
    }

//    self.noteTextView.delegate = self;
//    [self.view addSubview:self.nameTextField];
//    self.photoData = Nil;

if (self.selectedVehicle)
{
    self.nameTextField.text = self.selectedVehicle.name;
//    self.yearTextField.text = [self.dateFormat stringFromDate:self.selectedVehicle.year];
//    self.odometerTextField.text = [NSString stringWithString:[self.selectedVehicle.odometer stringValue]];
    self.specTextView.text = self.selectedVehicle.spec;
    self.noteTextView.text = self.selectedVehicle.note;
    
    if  (self.selectedVehicle.image)
    {
    self.photoView = [[UIImageView alloc]  initWithImage:[UIImage imageWithData:self.selectedVehicle.image scale:[UIScreen mainScreen].scale]];
    [self.photoView sizeToFit];

//    self.photoView.frame = CGRectMake(10,0,40,40);
//    [self.view addSubview:self.photoView];
    }

    if ([self.selectedVehicle.units  isEqual: @"mi"])
    {
        self.unitsSegment.selectedSegmentIndex = 1;
    
    }
    else if ([self.selectedVehicle.units  isEqual: @"km"]) {
        self.unitsSegment.selectedSegmentIndex = 0;
       

    }
    self.units = self.selectedVehicle.units;
}



    
}

//- (void)textFieldDidBeginEditing:(UITextField *)aTextField{
//    // [aTextField resignFirstResponder];
//    if (aTextField == self.yearTextField)
//    {
//        pickerViewPopup = [[UIActionSheet alloc] initWithTitle:@"Year" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//        
//        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
//        self.datePicker.datePickerMode = UIDatePickerModeDate;
//        self.datePicker.hidden = NO;
//        self.datePicker.date = [NSDate date];
//        
//        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//        pickerToolbar.barStyle = UIBarStyleDefault;
//        [pickerToolbar sizeToFit];
//        
//        NSMutableArray *barItems = [[NSMutableArray alloc] init];
//        
//        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//        [barItems addObject:flexSpace];
//        
//        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
//        [barItems addObject:doneBtn];
//        
//        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
//        [barItems addObject:cancelBtn];
//        
//        [pickerToolbar setItems:barItems animated:YES];
//        
//        [pickerViewPopup addSubview:pickerToolbar];
//        [pickerViewPopup addSubview:self.datePicker];
//        [pickerViewPopup showInView:self.view];
//        [pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];
//    }
//}
//- (void)pickerChanged: (id)sender
//{
//    NSLog(@"value: %@",[sender date]);
////    self.yearTextField.text = @"%@",[sender date];
//}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

//-(void)doneButtonPressed:(id)sender{
//    //  self.datePicked = [sender date];
//    //self.dateTextField.text = @"%@",[sender date];
//    ////   UIDatePicker *picker = (UIDatePicker *)sender;
//    //    NSDateFormatter *dateFormat = [NSDateFormatter new];
//    //    [dateFormat setDateStyle:NSDateFormatterLongStyle]
//    //    self.dateTextField.text = dateFormat strin;
//    //    self.datePicker.text = [dateFormat stringFromDate:self.datePicker.date];
//
//    self.yearTextField.text = [self.dateFormat stringFromDate:self.datePicker.date];
//    
//    
//    //    self.dateTextField.text = [NSString stringWithFormat:@"%@", self.datePicker.date];
//    [pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
//}
//
//-(void)cancelButtonPressed:(id)sender{
//    [pickerViewPopup dismissWithClickedButtonIndex:1 animated:YES];
//}

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
    cell.imageView.image = nil;
    cell.accessoryView = nil;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    switch (indexPath.row) {
        case Name:{
            cell.textLabel.text = @"Name";
            cell.accessoryView = self.nameTextField;


//            [cell.accessoryView addSubview:self.nameTextField];
//            [cell.accessoryView bringSubviewToFront:self.nameTextField];
        }break;
        case Spec:{
            cell.textLabel.text = @"Spec";
            cell.accessoryView = self.specTextView;
//            [cell.contentView addSubview:self.specTextView];
//            [cell.contentView bringSubviewToFront:self.specTextView];
        }break;
//        case Odometer:{
//            cell.textLabel.text = @"Odometer";
//            self.odometerTextField.frame = CGRectMake(cell.frame.size.width - 180, (cell.frame.size.height - textFieldHeight) /2, 150, textFieldHeight);
//            [cell.contentView addSubview:self.odometerTextField];
//            [cell.contentView bringSubviewToFront:self.odometerTextField];
//        }break;
//        case Year:{
//            cell.textLabel.text = @"Year";
//            self.yearTextField.frame = CGRectMake(cell.frame.size.width - 180, (cell.frame.size.height - textFieldHeight) /2, 150, textFieldHeight);
//            [cell.contentView addSubview:self.yearTextField];
//            [cell.contentView bringSubviewToFront:self.yearTextField];
//        }break;
        case Note:{
            cell.textLabel.text = @"Note";
            cell.accessoryView = self.noteTextView;
//            [cell.contentView addSubview:self.noteTextView];
//            [cell.contentView bringSubviewToFront:self.noteTextView];
        }break;
        case Units:{
//            [[cell.contentView viewWithTag:10]removeFromSuperview];
//            [[cell.contentView viewWithTag:0]removeFromSuperview];
//            [cell.contentView clearsContextBeforeDrawing];
            cell.textLabel.text = @"Units";


            cell.accessoryView = self.unitsSegment;
//            [segmentedControl viewWithTag:10];
//            [cell.contentView addSubview:self.unitsSegment];
        }break;
        case Photo:{
            cell.textLabel.text = @"Add Photo";
            

            if (! self.photoView.image)
            {
                cell.accessoryView = self.cameraView;
            }
            else{
                [self.photoView sizeToFit];
                cell.accessoryView = self.photoView;
            }
        
//            cell.imageView.image = self.photoView.image;

//            [cell.contentView addSubview:self.cameraToolbar];
//            [cell.contentView bringSubviewToFront:self.cameraToolbar];
//            [cell.contentView addSubview:self.photoView];
//            [cell.contentView bringSubviewToFront:self.photoView];
            
            
        }break;
            
        }
    
//    
//    NSManagedObject *device = self.vehicles[indexPath.row];
//    [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", [device valueForKey:@"name"], [device valueForKey:@"odometer"] ]];
//    [cell.detailTextLabel setText:[device valueForKey:@"spec"]];
    
    
    //UIImageView *cellImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:data[@"image"]]];
    
    //cell.backgroundView = cellBgView;
    
    //NSDictionary *data = self.myVehicleArray[indexPath.row];
    //cell.textLabel.text = [NSString stringWithFormat: @"%@ %@", data[@"name"], data[@"spec"] ];
    
    
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
-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            self.units = @"km";
            break;}
        case 1:{
            self.units = @"mi";
            break;}
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
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
        case Name:{
            [self.nameTextField becomeFirstResponder];
            
        }break;
//        case Year:{
//        pickerViewPopup = [[UIActionSheet alloc] initWithTitle:@"Year" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//        
//        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
//        self.datePicker.datePickerMode = UIDatePickerModeDate;
//        self.datePicker.hidden = NO;
//        self.datePicker.date = [NSDate date];
//        
//        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//        pickerToolbar.barStyle = UIBarStyleDefault;
//        [pickerToolbar sizeToFit];
//        
//        NSMutableArray *barItems = [[NSMutableArray alloc] init];
//            
//        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
//        [barItems addObject:cancelBtn];
//
//        
//        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//        [barItems addObject:flexSpace];
//        
//
//        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
//        [barItems addObject:doneBtn];
//        
//        [pickerToolbar setItems:barItems animated:YES];
//        
//        [pickerViewPopup addSubview:pickerToolbar];
//        [pickerViewPopup addSubview:self.datePicker];
//        [pickerViewPopup showInView:self.view];
//        [pickerViewPopup setBounds:CGRectMake(0,0,320, 464)];
//        }break;
        case Spec:{
            [self.specTextView becomeFirstResponder];
        }break;
//        case Odometer:{
//            [self.odometerTextField becomeFirstResponder];
//        }break;
        case Note:{
            [self.noteTextView becomeFirstResponder];
        }break;
        case Photo:{
            [self cameraButtonPressed];
        }break;
    

            
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneButtonPressed{
    //NULL method ATM needs to be filled
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)saveButtonPressed{
    
   // if ( [self.specTextView.text isEqual: @""] || [self.yearTextField.text isEqual:@""] || [self.odometerTextField.text isEqual:@"" ] || [self.nameTextField.text  isEqual: @""] ){
        
    
   // }
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;

//    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
  //  NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Vehicle" inManagedObjectContext:context];
    
    if ([self.nameTextField.text  isEqual: @""])
    {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter the vehicle name."
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
    else
    {
        
    if (self.selectedVehicle)
    {
        self.selectedVehicle.name = self.nameTextField.text;
//        self.selectedVehicle.odometer = [NSNumber numberWithInt: [self.odometerTextField.text intValue]];
//        self.selectedVehicle.year = [self.dateFormat dateFromString:self.yearTextField.text];
        self.selectedVehicle.spec = self.specTextView.text;
        self.selectedVehicle.note = self.noteTextView.text;
        self.selectedVehicle.units = self.units;
        self.title = [NSString stringWithFormat:@"Edit %@ ",self.nameTextField.text];
        
        if  (self.photoData)
        {
          self.selectedVehicle.image = self.photoData;
        }
        
    }
    else
    {
        
    
    Vehicle *newVehicle = [NSEntityDescription insertNewObjectForEntityForName:@"Vehicle" inManagedObjectContext:delegate.managedObjectContext];
    newVehicle.name = self.nameTextField.text;
    newVehicle.spec = self.specTextView.text;
    newVehicle.note = self.noteTextView.text;
        newVehicle.odometer = 0;
        newVehicle.units = self.units;
//    newVehicle.odometer = [NSNumber numberWithInt: [self.odometerTextField.text intValue]];
//    newVehicle.year = [self.dateFormat dateFromString:self.yearTextField.text];;
    if  (self.photoData)
    {
        newVehicle.image = self.photoData;
    }

 //   newVehicle.image = self.imageTextField.text;
    
        
        //Clear Text Fields.
        self.nameTextField.text = Nil;
//        self.odometerTextField.text = Nil;
//        self.yearTextField.text = Nil;
        self.specTextView.text = Nil;
        self.photoView.image = Nil;
        self.noteTextView.text = Nil;
    }
    
//    [newDevice setValue:self.nameTextField.text forKey:@"name"];
//    [newDevice setValue:self.specTextView.text forKey:@"spec"];
//    [newDevice setValue:self.odometerTextField.text forKey:@"odometer"];
//    [newDevice setValue:self.yearTextField.text forKey:@"year"];
//    [newDevice setValue:self.imageTextField.text forKey:@"image"];
    
    
    //c.photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:contributor[@"photo"]]];
   
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![delegate.managedObjectContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    [delegate.managedObjectContext save:Nil];
    

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
                                          otherButtonTitles:@"Camera", @"Existing Photo", @"Flickr Search", nil];

    [alert show];
    
    

    //NULL method ATM needs to be filled
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
//                CGFloat SCREEN_HEIGHT = 480;
//                CGFloat SCREEN_WIDTH = 320;
//                //SCREEN_HEIGHT = 480 and SCREEN_WIDTH = 320
//                UIView *OverlayView = [[UIView alloc]  initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 100.0)] ;
//                OverlayView *overlay = [[OverlayView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//                [overlay initOverlay:self];
//                imagePicker.cameraOverlayView = overlay;
//                [self presentModalViewController:imagePicker animated:YES];

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
            picker.allowsEditing = YES;

            //           picker.delegate = self;
            [picker setDelegate:self];
            
            [self presentViewController:picker animated:YES completion:nil];
            
            
            //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unavailable!"
            //                                                        message:@"This device does not have a camera."
            //                                                       delegate:nil
            //                                              cancelButtonTitle:@"OK"
            //                                              otherButtonTitles:nil];
            //        [alert show];
        }
        else if (buttonIndex == 3){
            ImageSearchViewController *is = [ImageSearchViewController new];
            is.vehicleDelegate = self;
            [self.navigationController pushViewController:is animated:YES];

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

@end
