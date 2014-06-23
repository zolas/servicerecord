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

@interface ServiceViewController ()

@property (nonatomic, strong) NSArray *sortedRecordByDate;

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
    [super viewDidAppear:animated];
    self.title = [NSString stringWithFormat:@"%@ Records",self.selectedVehicle.name];
    [self.tableView reloadData];
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
        if (a.photos.count >0){
            RecordPhoto *b = a.photos[0];
            UIImageView *photoView = [[UIImageView alloc]  initWithImage:[UIImage imageWithData:b.photo scale:[[UIScreen mainScreen] scale]]];
            cell.imageView.image = photoView.image;
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

-(void)settingsButtonPressed{
    //Go to VehicleViewController to manage existing vehicle
    VehicleViewController *vc = [VehicleViewController new];
    vc.selectedVehicle = self.selectedVehicle;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:alertView.tag inSection:0];
    
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
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
