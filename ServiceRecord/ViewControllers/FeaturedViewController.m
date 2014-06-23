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


@interface FeaturedViewController () 

@property (nonatomic, strong) NSMutableArray *vehicles;

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
    
    [self.tableView reloadData];
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
    self.navigationItem.rightBarButtonItem = addButton;
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
    cell.imageView.image = [UIImage imageWithData:a.image scale:[[UIScreen mainScreen] scale]];
    
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
    }
}

- (void)addButtonPressed{
    VehicleViewController *mc = [VehicleViewController new];
    [self.navigationController pushViewController:mc animated:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
