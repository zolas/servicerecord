//
//  FeaturedViewController.m
//  ServiceRecord
//
//  Created by Gray on 2/10/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import "FeaturedViewController.h"
#import "VehicleViewController.h"
#import "AppDelegate.h"
#import "ServiceViewController.h"


@interface FeaturedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *myVehicleArray;
@property (nonatomic, strong) NSArray *myMaintenanceArray;
//@property (nonatomic, strong) UITableView *vehicleTableView;
@property (nonatomic, strong) UIToolbar *mainToolbar;
@property (nonatomic, strong) IBOutlet UIImageView *photoView;
@property (nonatomic, strong) IBOutlet NSData *photoData;
@property (nonatomic, strong) IBOutlet UIImage *photo;
@property (nonatomic, strong) NSArray *sortedOdometer;


@property (strong) NSMutableArray *vehicles;


@end

@implementation FeaturedViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"ChainLube";
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title=@"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the vehicles from persistent data store
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Vehicle"];
   
 
    self.vehicles = [[delegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
       NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    self.vehicles = [[self.vehicles sortedArrayUsingDescriptors:@[sortByName]] mutableCopy];
    
    [self.tableView reloadData];
}





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
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];

    //    CGFloat customToolbarHeight = 40;
    //
    //
    //    self.myVehicleArray = @[
    //                            @{@"name": @"Suzuki", @"model": @"SV650", @"year": @"2007", @"odometer": @"10,000", @"image": @"im26.jpg"},
    //                            @{@"name": @"Suzuki", @"model": @"tu250", @"year": @"2012", @"odometer": @"8,000", @"image": @"im16.jpg"},
    //                            @{@"name": @"Blacksister", @"model": @"wr250r", @"year": @"2009", @"odometer": @"10,000", @"image": @"im31.jpg"},
    //                            ];
    //    self.myMaintenanceArray = @[
    //                                @{@"date": @"10/15/12", @"task": @"valve check", @"odometer": @"5233", @"cost": @"3233", @"notes": @"very hard"},
    //                                @{@"date": @"10/18/12", @"task": @"valve adjust", @"odometer": @"5265", @"cost": @"3231", @"notes": @"medium"},
    //                                @{@"date": @"10/20/12", @"task": @"valve click", @"odometer": @"5299", @"cost": @"3423", @"notes": @"easy"},
    //                                ];
    //
    //  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Category" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed)];
    // self.navigationItem.leftBarButtonItem = addButton;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(addButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    //self.vehicleTableView = [[UITableView alloc] initWithFrame:CGRectMake(101, 45, 100, 416)];
    //    self.vehicleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height - customToolbarHeight))];
    //    self.vehicleTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    //    self.vehicleTableView.delegate = self;
    //    self.vehicleTableView.dataSource = self;
    //    [self.view addSubview:self.vehicleTableView];
    
    
    
    
    ////TOOL BAR //////////////////////////////////////////////////////////////////////////////////////////
    //    UIToolbar *mainToolbar = [[UIToolbar alloc] init];
    //    self.mainToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - customToolbarHeight , self.view.frame.size.width, customToolbarHeight) ];
    //    self.mainToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    //    NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
    //
    //    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(featuredButtonPressed)]];
    //    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(topBuildsButtonPressed)]];
    //    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed)]];
    //
    //    [self.mainToolbar setItems:toolbarItems animated:NO];
    ////    [self.view addSubview:self.mainToolbar];
    
    // Do any additional setup after loading the view.
}
#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.vehicles.count;
    //return [self.myVehicleArray count];
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    
    cell.imageView.image = nil;
    cell.accessoryView = nil;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    
    Vehicle *a = self.vehicles[indexPath.row];
    
    NSSortDescriptor *sortByOdometer = [[NSSortDescriptor alloc] initWithKey:@"odometer" ascending:NO];
    self.sortedOdometer = [[a.records sortedArrayUsingDescriptors:@[sortByOdometer]] mutableCopy];
    if (self.sortedOdometer.count > 0){
            Record *r = self.sortedOdometer[0];
//            if (r.odometer.integerValue > 0 ){
            a.odometer = r.odometer;
       
    }else{
            a.odometer = @0;
    }
    

    
    if ( a.odometer.integerValue == 0 || ! a.odometer){
        
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", a.name ]];
        cell.detailTextLabel.text = @"";
    }
    else{
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", a.name]];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ %@",a.odometer,a.units]];
    }
    
    
    
    //UIImageView *cellImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:data[@"image"]]];
    
    //cell.backgroundView = cellBgView;
    
    //NSDictionary *data = self.myVehicleArray[indexPath.row];
    //cell.textLabel.text = [NSString stringWithFormat: @"%@ %@", data[@"name"], data[@"model"] ];
    
    self.photoView = [[UIImageView alloc]  initWithImage:[UIImage imageWithData:a.image scale:[[UIScreen mainScreen] scale]]];
    
    cell.imageView.image = self.photoView.image;
    
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please confirm to delete."
                                                        message:@""
                                                       delegate:self
                              
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok", nil];
        alert.tag = indexPath.item;
        [alert show];
        
        if (tableView.isEditing)
        {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        
        
        //        if (editingStyle == UITableViewCellEditingStyleDelete) {
        //        // Delete object from database
        //        [delegate.managedObjectContext deleteObject:[self.vehicles objectAtIndex:indexPath.row]];
        //       // [AppDelegate.NSManagedObjectContext.managedObjectContext deleteObject:[self.vehicles objectAtIndex:indexPath.row]];
        //
        //        NSError *error = nil;
        //        if (![delegate.managedObjectContext save:&error]) {
        //            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        //            return;
        //        }
        //
        //        // Remove a from table view
        //        [self.vehicles removeObjectAtIndex:indexPath.row];
        //        [delegate.managedObjectContext save:Nil];
        //
        //        [self.vehicleTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:alertView.tag inSection:0];
    if (buttonIndex == 1){
        NSLog(@"called my alert");
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate.managedObjectContext deleteObject:[self.vehicles objectAtIndex:indexPath.row]];
        NSError *error = nil;
        if (![delegate.managedObjectContext save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        [self.vehicles removeObjectAtIndex:indexPath.row];
        
        [delegate.managedObjectContext save:Nil];
        // Remove a from table view
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ServiceViewController *sc = [ServiceViewController new];
    sc.selectedVehicle = self.vehicles[indexPath.row];
    [self.navigationController pushViewController:sc animated:YES];
}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
//tableView:shouldIndentWhileEditingRowAtIndexPath

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    switch (indexPath.row) {
    //        case Note:{
    //            return 100.0;
    //        }break;
    //        case Spec:{
    //            return 100.0;
    //        }break;
    //        case Photo:{
    //            return 100.0;
    //        }break;
    //    }
    return 80;
}
-(void)addButtonPressed{
    VehicleViewController *mc = [VehicleViewController new];
    [self.navigationController pushViewController:mc animated:YES];
}
-(void)settingsButtonPressed{ //NULL method ATM needs to be filled
}
-(void)featuredButtonPressed{ //NULL method ATM needs to be filled
}
-(void)topBuildsButtonPressed{ //NULL method ATM needs to be filled
}
-(void)searchButtonPressed{ //NULL method ATM needs to be filled
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
