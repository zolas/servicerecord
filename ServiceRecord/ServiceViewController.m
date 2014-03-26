//
//  ServiceViewController.m
//  ServiceRecord
//
//  Created by Gray on 2/20/2014.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import "ServiceViewController.h"
#import "RecordViewController.h"
#import "AppDelegate.h"
#import "FeaturedViewController.h"
#import "VehicleViewController.h"

@interface ServiceViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSString *myTitle;
//@property (nonatomic, strong) UITableView *serviceTableView;
@property (nonatomic, strong) UIToolbar *mainToolbar;
@property (nonatomic, strong) UIToolbar *vehicleToolbar;
@property (nonatomic, strong) IBOutlet UIImageView *photoView;
@property (nonatomic, strong) IBOutlet NSData *photoData;
@property (nonatomic, strong) IBOutlet UIImage *photo;
@property (nonatomic, strong) NSDateFormatter *dateFormat;
@property (nonatomic, strong) NSArray *sortedDate;




@end


@implementation ServiceViewController

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
    
    // Fetch the records from persistent data store
    //    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    self.title = [NSString stringWithFormat:@"%@ Records",self.selectedVehicle.name];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    self.sortedDate = [[self.selectedVehicle.records sortedArrayUsingDescriptors:@[sortByDate]] mutableCopy];
}



- (void)viewDidLoad
{
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [super viewDidLoad];
    

    //store vehicle latest odometer
    
    //    self.title = [NSString stringWithFormat:@"%@ Records",self.selectedVehicle.name];
    
    CGFloat customToolbarHeight = 40;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd  target:self action:@selector(addButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.dateFormat = [NSDateFormatter new];
    //    [self.dateFormat setDateFormat:@"MMMM/d/yyyy"];
    
    [self.dateFormat setDateStyle:NSDateFormatterShortStyle];
    
    ///TABLE VIEW///
    //    self.serviceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, customToolbarHeight, self.view.frame.size.width, (self.view.frame.size.height - customToolbarHeight))];
    //    self.serviceTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    //    self.serviceTableView.delegate = self;
    //    self.serviceTableView.dataSource = self;
    //    [self.view addSubview:self.serviceTableView];
	// Do any additional setup after loading the view.
    self.tableView.tableHeaderView = self.vehicleToolbar;
    
    
    ////TOOLBAR ///////////////////////////////////////////////////////////////////////////////
    //    UIToolbar *mainToolbar = [[UIToolbar alloc] init];
    self.vehicleToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0 , self.view.frame.size.width, customToolbarHeight) ];
    self.vehicleToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.tableView.tableHeaderView = self.vehicleToolbar;
    
    NSMutableArray *toolbarVehicleItems = [[NSMutableArray alloc] init];
    
    
    [toolbarVehicleItems addObject:[[UIBarButtonItem alloc] initWithTitle:self.selectedVehicle.name style:UIBarButtonItemStyleDone target:self action:@selector(settingsButtonPressed)]];
    [toolbarVehicleItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStyleDone target:self action:@selector(settingsButtonPressed)]];
    
    
    //[toolbarVehicleItems addObject:[[UIBarButtonItem alloc] initWithTitle:<#(NSString *)#> style:<#(UIBarButtonItemStyle)#> target:<#(id)#> action:<#(SEL)#> target:self action:@selector(topBuildsButtonPressed)]];
    //[toolbarVehicleItems addObject:[[UILabel alloc] initWithFrame: UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed)]];
    
    [self.vehicleToolbar setItems:toolbarVehicleItems animated:NO];
    // [items release];
    [self.view addSubview:self.vehicleToolbar];
    
    
    ////TOOL BAR //////////////////////////////////////////////////////////////////////////////////////////
    //    UIToolbar *mainToolbar = [[UIToolbar alloc] init];
    self.mainToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - customToolbarHeight , self.view.frame.size.width, customToolbarHeight) ];
    self.mainToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    NSMutableArray *toolbarItems = [[NSMutableArray alloc] init];
    
    // [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(featuredButtonPressed)]];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(topBuildsButtonPressed)]];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed)]];
    
    [self.mainToolbar setItems:toolbarItems animated:NO];
    // [items release];
    //    [self.view addSubview:self.mainToolbar];
    
    
    
    // Do any additional setup after loading the view.
    
}
#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.selectedVehicle.records.count;
    //return [self.myVehicleArray count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    //    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    //
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    //    self.myVehicleArray = @[
    //                            @{@"name": @"Suzuki", @"model": @"SV650", @"year": @"2007", @"odometer": @"10,000", @"image": @"im26.jpg"},
    //                            @{@"name": @"Suzuki", @"model": @"tu250", @"year": @"2012", @"odometer": @"8,000", @"image": @"im16.jpg"},
    //                            @{@"name": @"Blacksister", @"model": @"wr250r", @"year": @"2009", @"odometer": @"10,000", @"image": @"im31.jpg"},
    //                            ];
    
    
    //   Record *a = self.selectedVehicle.records[indexPath.item];
    
    //    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    //    [itemArray addObject:itemDictionary];
    
    //    for (int i = 0; i < self.selectedVehicle.records.count ; i++ ){
    //        Record *a = self.selectedVehicle.records[i];
    //        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
    //        [itemDictionary setValue:a.date forKey:@"date"];
    //        [itemDictionary setValue:a forKey:@"record"];
    //
    //        [itemArray addObject:itemDictionary];
    //
    //    }
    ////    itemArray = [itemArray sortedArrayUsingSelector:@selector(compare:)];
    //    NSArray *reverseOrderUsingComparator = [itemArray sortedArrayUsingComparator:
    //                                            ^(id obj1, id obj2) {
    //                                                return [obj2 compare:obj1];
    //                                            }];
    
    //   NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    //   self.sortedDate = [[self.selectedVehicle.records sortedArrayUsingDescriptors:@[sortByDate]] mutableCopy];
    //store vehicle latest odometer
    
    NSLog(@"%@",self.sortedDate);
    cell.imageView.image = nil;
    cell.accessoryView = nil;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    if  ([self.sortedDate count] == 0){
        
    }
    else
    {
        Record *a = self.sortedDate[indexPath.item];
        if (a.photos.count >0){
            
            RecordPhoto *b = a.photos[0];
            self.photoView = [[UIImageView alloc]  initWithImage:[UIImage imageWithData:b.photo scale:[[UIScreen mainScreen] scale]]];
            cell.imageView.image = self.photoView.image;
        }

        if ( a.odometer.integerValue == 0 ){
            
            [cell.textLabel setText:[NSString stringWithFormat:@"%@", a.task]];
            cell.detailTextLabel.text = @"";

            
            
        }
        else{
            //        [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", a.task, a.odometer]];
            [cell.textLabel setText:[NSString stringWithFormat:@"%@", a.task]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ %@",a.odometer,self.selectedVehicle.units]];
        }
        
        // it should be a label
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.text = [NSString stringWithString:[self.dateFormat stringFromDate:a.date]];
        [dateLabel sizeToFit];
        cell.accessoryView = dateLabel;
        

        
        //UIImageView *cellImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:data[@"image"]]];
        
        //cell.backgroundView = cellBgView;
        
        //NSDictionary *data = self.myVehicleArray[indexPath.row];
        //cell.textLabel.text = [NSString stringWithFormat: @"%@ %@", data[@"name"], data[@"model"] ];
        
        //NEED FIXING// cell.imageView.image = [UIImage imageNamed:a.image];
        
        //recipeImageView.image = [UIImage imageNamed:[recipeImages[indexPath.section] objectAtIndex:indexPath.row]];
        
        
        //  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
    }
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
        
        
        // Delete object from database
        //        [self.selectedVehicle removeRecordsObject:a];
        // [AppDelegate.NSManagedObjectContext.managedObjectContext deleteObject:[self.records objectAtIndex:indexPath.row]];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:alertView.tag inSection:0];
    if (buttonIndex == 1){
        NSLog(@"called my alert");
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;

        Record *a = self.sortedDate[indexPath.item];
        //DELETE ALL PHOTO RECORDS
        [a.photos enumerateObjectsUsingBlock:^(RecordPhoto *k, NSUInteger idx, BOOL *stop) {
            [delegate.managedObjectContext deleteObject:k];
        }];
        
        //        Record *a = self.selectedVehicle.records[indexPath.item];
        [delegate.managedObjectContext deleteObject:a];
        [delegate.managedObjectContext save:Nil];
        // Remove device from table view
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
}
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RecordViewController *rc = [RecordViewController new];
    
    rc.selectedVehicle = self.selectedVehicle;
    rc.selectedRecord =  self.sortedDate[indexPath.item];
    //    rc.selectedRecord = self.selectedVehicle.records[indexPath.item];
    [self.navigationController pushViewController:rc animated:YES];
}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
//tableView:shouldIndentWhileEditingRowAtIndexPath
-(void)addButtonPressed{
    RecordViewController *rc = [RecordViewController new];
    rc.selectedVehicle = self.selectedVehicle;
    rc.selectedRecord = Nil;
    [self.navigationController pushViewController:rc animated:YES];
}


-(void)settingsButtonPressed{
    VehicleViewController *vc = [VehicleViewController new];
    vc.selectedVehicle = self.selectedVehicle;
    [self.navigationController pushViewController:vc animated:YES];
    
    //NULL method ATM needs to be filled
}
-(void)topBuildsButtonPressed{ //NULL method ATM needs to be filled
}
-(void)searchButtonPressed{
    VehicleViewController *vc = [VehicleViewController new];
    vc.selectedVehicle = self.selectedVehicle;
    [self.navigationController pushViewController:vc animated:YES];
    
    //NULL method ATM needs to be filled
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
