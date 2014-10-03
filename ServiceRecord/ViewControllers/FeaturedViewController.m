//
//  FeaturedViewController.m
//  ServiceRecord
//
//  Created by Gray on 2/10/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//
// This ViewController is responsible for allowing the user to manage their vehicles.

#import "FeaturedViewController.h"
#import "VehicleViewController.h"
#import "AppDelegate.h"
#import "ServiceViewController.h"
#import <MessageUI/MessageUI.h>
#import "NSManagedObject+Extras.h"



@interface FeaturedViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *vehicles;
@property (nonatomic, strong) NSMutableArray *vehicleThumbs;

@property (nonatomic, strong) NSMutableArray *shareImageData;
@end

@implementation FeaturedViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title=@"ChainLube";
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title=@"";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Fetch and sort the vehicles from persistent data store
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Vehicle"];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortByName]];
    self.vehicles = [[delegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    self.vehicleThumbs = [NSMutableArray new];
    [self updateVehicleThumbs];
    


    
    [self.tableView reloadData];
}
- (void)updateVehicleThumbs{
    [self.vehicles enumerateObjectsUsingBlock:^(Vehicle *v, NSUInteger idxVehicle, BOOL *stop) {
        if (v.image != Nil){
            UIImage *image = [self imageWithImage:[UIImage imageWithData:v.image scale:1.0] convertToSize:CGSizeMake(120,120)]; // Change size to match aspect ratio
            [self.vehicleThumbs addObject:image];
        }
        else
            [self.vehicleThumbs addObject:[NSNull null]];
        
    }];
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];
    
    self.shareImageData = [NSMutableArray new];
    
    //Interpolating Motion Effect Group
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = @-40;
    xAxis.maximumRelativeValue = @40;
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = @-40;
    yAxis.maximumRelativeValue = @40;
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis,yAxis];
    
    self.tableView.rowHeight=80;
    
    // Add vehicle button on Navigation bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(addButtonPressed)];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose  target:self action:@selector(sendMailPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = shareButton;
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData]; //Reload the table view everytime the orientation changes
}

#pragma mark - TableView Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.vehicles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    //Sort the vehicles by Odometer reading
    Vehicle *a = self.vehicles[indexPath.row];
    NSSortDescriptor *sortByOdometer = [[NSSortDescriptor alloc] initWithKey:@"odometer" ascending:NO];
    NSArray *sortedOdometer = [[a.records sortedArrayUsingDescriptors:@[sortByOdometer]] mutableCopy];
    
    if (sortedOdometer.count > 0){
            Record *r = sortedOdometer[0];
            a.odometer = r.odometer;
    }else a.odometer = @0;
    
    cell.textLabel.text = a.name;
    
    //Check if odometer value exists
    if ( a.odometer.integerValue == 0 || ! a.odometer)
        cell.detailTextLabel.text = @"";
    else
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",a.odometer,a.units];
    
    
    //Add vehicle image to the cell
    cell.imageView.image = nil;
    if (self.vehicleThumbs.count >indexPath.item){
        if ([self.vehicleThumbs[indexPath.item] isEqual:[NSNull null]] || [self.vehicleThumbs[indexPath.item] isEqual:nil]){}
        else
            cell.imageView.image = self.vehicleThumbs[indexPath.item];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Confirm deleting vehicle object
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please confirm to delete"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok", nil];
        alert.tag = indexPath.item;
        [alert show];
        //Reload the row if it is being edited. (Maybe better to do it in the didDismiss method)
        if (tableView.isEditing){
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ServiceViewController *sc = [ServiceViewController new];
    sc.selectedVehicle = self.vehicles[indexPath.row];
    [self.navigationController pushViewController:sc animated:YES];
}
         
# pragma mark - AlertView Implementation
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
    //Delete tagged item
    if (buttonIndex == 1){
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate.managedObjectContext deleteObject:self.vehicles[indexPath.row]];
        
        [self.vehicles removeObjectAtIndex:indexPath.row];
        [delegate saveContext];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self viewDidAppear:YES];
        
    }
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)addButtonPressed{
    VehicleViewController *mc = [VehicleViewController new];
    [self.navigationController pushViewController:mc animated:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)sendMailPressed{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"What would you like to send?"
//                                                    message:@""
//                                                   delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                          otherButtonTitles:@"Import ChainLube file",@"Export ChainLube File",@"", nil];
//    [alert show];
    //[coreDataModel jsonStringValue]
    
// ENABLE TO WORK ON EXPORT/IMPORT
//    Vehicle *object = self.vehicles[0];
//    NSString *myObject = [object jsonStringValue];
//    NSLog(@"Object: %@",myObject);

    if ([MFMailComposeViewController canSendMail]) [self showEmailModalView];
}
- (NSString *)getCoreVehicles{
    
    __block NSMutableString *printObject = [NSMutableString new];
    if (self.vehicles.count > 0){
        [self.vehicles enumerateObjectsUsingBlock:^(Vehicle *v, NSUInteger idxVehicle, BOOL *stop) {
            [printObject appendFormat:@"&nbsp;<h3>VEHICLE DESCRIPTION</h3>Name: %@<br>Specifications: %@<br> Notes: %@<br> Units: %@<br> Photo:%@.png<br><h4>VEHICLE RECORDS</h4>",v.name,v.spec,v.note,v.units,v.name];
            if (v.image != nil){
                [self.shareImageData addObject:@{@"image":v.image,@"name":v.name}];
            }
            if (v.records.count > 0){
                [v.records enumerateObjectsUsingBlock:^(Record *r, NSUInteger idxRecord, BOOL *stop) {
                    NSDateFormatter *dateFormat = [NSDateFormatter new];
                    [dateFormat setDateStyle:NSDateFormatterLongStyle];
                    [printObject appendFormat:@"<br>Task: %@<br>Date: %@<br> Odometer: %@<br> Cost: %@<br> Note: %@<br> Photos:",r.task,[dateFormat stringFromDate:r.date],r.odometer,r.cost,r.note];
                    __block NSString *recordName = r.task;
                    [r.photos enumerateObjectsUsingBlock:^(RecordPhoto *p, NSUInteger idxPhoto, BOOL *stop)
                     {
                         if ([p.label  isEqual: @""]){
                             [printObject appendFormat:@"%@.png ",recordName];
                         [self.shareImageData addObject:@{@"image":p.photo,@"name":p.label}];
                         }

                         else{
                             [printObject appendFormat:@"%@.png ",p.label];
//                           [printObject appendFormat:@"<img src=\'cid:%@.png\'>",p.label];
                             [self.shareImageData addObject:@{@"image":p.photo,@"name":p.label}];
                         }
                    }];
                    [printObject appendString:@"<br>"];
                    [printObject appendString:@"</p>"];
                }];
            }
                else [printObject appendString:@"No records found for this vehicle</p>"];
        }];
    }
    else [printObject appendString:@"<p>No Vehicles Found</p>"];
    NSLog(@"%@",printObject);

    return [NSString stringWithString:printObject];
}
-(void)showEmailModalView {
    NSString *vehicleLog = [self getCoreVehicles];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Vehicle Log"];
    
    [self.shareImageData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [picker addAttachmentData:[obj objectForKey:@"image"]  mimeType:@"image/png" fileName:[obj objectForKey:@"name"]];

    }];

    
    [picker setMessageBody:vehicleLog isHTML:YES];
    
    picker.navigationBar.barStyle = UIBarStyleBlack;
    [self presentViewController:picker animated:YES completion:nil];
//    [self.navigationController pushViewController:picker animated:YES];

    
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
@end
