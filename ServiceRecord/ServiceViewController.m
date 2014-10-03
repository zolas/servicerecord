//
//  ServiceViewController.m
//  ServiceRecord
//
//  Created by Gray on 2/20/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//
// This ViewController manages the service records for a vehicle

#import "ServiceViewController.h"
#import "RecordViewController.h"
#import "AppDelegate.h"
#import "FeaturedViewController.h"
#import "VehicleViewController.h"
#import "RecordListTableViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ServiceViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *sortedRecordByDate;
@property (nonatomic, strong) NSMutableArray *shareImageData;
@property (nonatomic, strong) NSMutableArray *vehicleThumbs;



@end


@implementation ServiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    self.sortedRecordByDate = [[self.selectedVehicle.records sortedArrayUsingDescriptors:@[sortByDate]] mutableCopy];
    if (self.selectedRecords.count > 0) [self showEmailModalView];
    [super viewDidAppear:animated];
    self.title = [NSString stringWithFormat:@"%@ Records",self.selectedVehicle.name];
    self.vehicleThumbs = [NSMutableArray new];
    [self updateVehicleThumbs];
    [self.tableView reloadData];

}

- (void)updateVehicleThumbs{
    if  ([self.sortedRecordByDate count] != 0){
        [self.sortedRecordByDate enumerateObjectsUsingBlock:^(Record *a, NSUInteger idxVehicle, BOOL *stop) {
        if (a.photos.count >0){
            RecordPhoto *b = a.photos[0];
            UIImage *image = [self imageWithImage:[UIImage imageWithData:b.photo scale:1.0] convertToSize:CGSizeMake(120,120)];
            [self.vehicleThumbs addObject:image];
        }
        else
            [self.vehicleThumbs addObject:[NSNull null]];
        
        }];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    self.sortedRecordByDate = [[self.selectedVehicle.records sortedArrayUsingDescriptors:@[sortByDate]] mutableCopy];
}

- (void)viewDidLoad{
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];
    
    self.shareImageData = [NSMutableArray new];
    
    // UIMotion effects group
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = @-40;
    xAxis.maximumRelativeValue = @40;
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = @-40;
    yAxis.maximumRelativeValue = @40;
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis,yAxis];
    
    CGFloat customToolbarHeight = 40;
    
    // Add service record button on Navigation bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(addButtonPressed)];

    self.navigationItem.rightBarButtonItem = addButton;
    
    // Toolbar to go into vehicle properties
    UIToolbar *vehicleToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0 , self.view.frame.size.width, customToolbarHeight) ];
    vehicleToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.tableView.tableHeaderView = vehicleToolbar;
    NSMutableArray *toolbarVehicleItems = [[NSMutableArray alloc] init];
    [toolbarVehicleItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose  target:self action:@selector(shareButtonPressed)]];
    [toolbarVehicleItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
    [toolbarVehicleItems addObject:[[UIBarButtonItem alloc] initWithTitle:@"Edit Vehicle" style:UIBarButtonItemStyleDone target:self action:@selector(settingsButtonPressed)]];
    [vehicleToolbar setItems:toolbarVehicleItems animated:NO];
    self.tableView.tableHeaderView = vehicleToolbar;
    [self.view addSubview:vehicleToolbar];
    
    self.tableView.rowHeight = 80;
}

#pragma mark - TableView DataSource Implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.selectedVehicle.records.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    //Clear reusable cell properties
    cell.imageView.image = nil;
    cell.accessoryView = nil;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    
    if  ([self.sortedRecordByDate count] != 0){
        Record *a = self.sortedRecordByDate[indexPath.item];
        
        //Check and assign the first photo to the cell
        if (self.vehicleThumbs.count >indexPath.item){
            if ([self.vehicleThumbs[indexPath.item] isEqual:[NSNull null]] || [self.vehicleThumbs[indexPath.item] isEqual:nil]){}
            else
                cell.imageView.image = self.vehicleThumbs[indexPath.item];
        }

        
        //Check and assign odometer value to the cell
        if ( a.odometer.integerValue == 0 ){
            [cell.textLabel setText:[NSString stringWithFormat:@"%@", a.task]];
            cell.detailTextLabel.text = @"";
        }
        else{
            [cell.textLabel setText:[NSString stringWithFormat:@"%@", a.task]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ %@",a.odometer,self.selectedVehicle.units]];
        }
        
        //Assign record date to the cell
        UILabel *dateLabel = [[UILabel alloc] init];
        NSDateFormatter *dateFormat = [NSDateFormatter new];
        [dateFormat setDateStyle:NSDateFormatterShortStyle];
        dateLabel.text = [NSString stringWithString:[dateFormat stringFromDate:a.date]];
        [dateLabel sizeToFit];
        cell.accessoryView = dateLabel;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView new] initWithTitle:@"Please confirm to delete."
                                                        message:@""
                                                       delegate:self
                              
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok", nil];
        alert.tag = indexPath.item;
        [alert show];
        
        if (tableView.isEditing){
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Go to RecordViewController to manage the specific record
    RecordViewController *rc = [RecordViewController new];
    rc.selectedVehicle = self.selectedVehicle;
    rc.selectedRecord =  self.sortedRecordByDate[indexPath.item];
    [self.navigationController pushViewController:rc animated:YES];
}

#pragma mark Button Press Method Implementations

-(void)addButtonPressed{
    //Go to RecordViewController to add a new record
    RecordViewController *rc = [RecordViewController new];
    rc.selectedVehicle = self.selectedVehicle;
    rc.selectedRecord = Nil;
    [self.navigationController pushViewController:rc animated:YES];
}

-(void)shareButtonPressed{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Records"
                                         message:@"What would you like to send?"
                                         delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Full Record Log",@"Specific Records", nil];
    [alert show];
}

- (NSString *)getCoreVehicles{
    
    __block NSMutableString *printObject = [NSMutableString new];
    self.shareImageData = [NSMutableArray new];
    
            [printObject appendFormat:@"&nbsp;<h3>VEHICLE DESCRIPTION</h3>Name: %@<br>Specifications: %@<br> Notes: %@<br> Units: %@<br> Photo:%@.png<br><h4>VEHICLE RECORDS</h4>",self.selectedVehicle.name,self.selectedVehicle.spec,self.selectedVehicle.note,self.selectedVehicle.units,self.selectedVehicle.name];
            if (self.selectedVehicle.image != nil){
                [self.shareImageData addObject:@{@"image":self.selectedVehicle.image,@"name":self.selectedVehicle.name}];
            }
            //Check if the user wants to send specific records, if no selected records, we choose all records.
            if (self.selectedRecords.count == 0) self.selectedRecords = self.sortedRecordByDate;
            if  ([self.selectedRecords count] != 0){
                [self.selectedRecords enumerateObjectsUsingBlock:^(Record *r, NSUInteger idxRecord, BOOL *stop) {
                    NSDateFormatter *dateFormat = [NSDateFormatter new];
                    [dateFormat setDateStyle:NSDateFormatterLongStyle];
                    [printObject appendFormat:@"<br>Task: %@<br>Date: %@<br> %@ %@ %@ Photos:",r.task,[dateFormat stringFromDate:r.date],
                     r.odometer.intValue > 0 ? [NSString stringWithFormat:@"Odometer: %@<br>",r.odometer] : @"",
                     r.cost.intValue > 0 ? [NSString stringWithFormat:@"Cost: %@<br>",r.cost] : @"",
                     r.note.length > 0 ? [NSString stringWithFormat:@"Note: %@<br>",r.note] : @""];
                    
                    __block NSString *recordName = r.task;
                    [r.photos enumerateObjectsUsingBlock:^(RecordPhoto *p, NSUInteger idxPhoto, BOOL *stop)
                     {
                         if ([p.label  isEqual: @""]){
                             [printObject appendFormat:@"%@.png ",recordName];
                             [self.shareImageData addObject:@{@"image":p.photo,@"name":p.label}];
                         }
                         else{
                             [printObject appendFormat:@"%@.png ",p.label];
                             [self.shareImageData addObject:@{@"image":p.photo,@"name":p.label}];
                         }
                     }];
                    [printObject appendString:@"<br>"];
                    [printObject appendString:@"</p>"];
                }];
            }
            else [printObject appendString:@"<p>No records found for this vehicle</p>"];
            
    NSLog(@"%@",printObject);
    
    return [NSString stringWithString:printObject];
}
-(void)showEmailModalView {
    NSString *vehicleLog = [self getCoreVehicles];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Vehicle Log"];
    
    [self.shareImageData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        //        NSData *image = [obj objectForKey:@"image"];
        [picker addAttachmentData:[obj objectForKey:@"image"]  mimeType:@"image/png" fileName:[obj objectForKey:@"name"]];
        
    }];
    //    Vehicle *k = self.vehicles[0];
    //
    //    [picker addAttachmentData:k.image mimeType:@"image/png" fileName:@"fook.jpg"];
    
    [picker setMessageBody:vehicleLog isHTML:YES];
    
    picker.navigationBar.barStyle = UIBarStyleBlack;
    [self presentViewController:picker animated:YES completion:^{
        self.selectedRecords = Nil;
    }];
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed, you cannot send messages at this time."
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
            
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)settingsButtonPressed{
    //Go to VehicleViewController to manage existing vehicle
    VehicleViewController *vc = [VehicleViewController new];
    vc.selectedVehicle = self.selectedVehicle;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:alertView.tag inSection:0];
    if ([alertView.message isEqualToString:@"What would you like to send?"]){
        if (buttonIndex == 1){  //Full Record Log
            if ([MFMailComposeViewController canSendMail]) [self showEmailModalView];
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed, you cannot send messages at this time."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];

            }
            
        }
        else if (buttonIndex == 2){ //Specific Records
            if (self.sortedRecordByDate.count >1){
                self.selectedRecords = [NSArray new];
                RecordListTableViewController *rl = [RecordListTableViewController new];
                rl.records = self.sortedRecordByDate;
                rl.units = self.selectedVehicle.units;
                rl.serviceDelegate = self;
                [self.navigationController pushViewController:rl animated:YES];
            }
            else if (self.sortedRecordByDate.count == 1){
                if ([MFMailComposeViewController canSendMail]) [self showEmailModalView];
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed, you cannot send messages at this time."
                                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"No records found."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                }
        }
    }
    else if ([alertView.title isEqualToString:@"Please confirm to delete."]){
        if (buttonIndex == 1){ //Delete record
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
            Record *a = self.sortedRecordByDate[indexPath.item];
            
            //Delete all photo records
            [a.photos enumerateObjectsUsingBlock:^(RecordPhoto *k, NSUInteger idx, BOOL *stop) {
                [delegate.managedObjectContext deleteObject:k];
            }];
            
            [delegate.managedObjectContext deleteObject:a];
            [delegate saveContext];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self viewDidAppear:YES];
        }
    }
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
