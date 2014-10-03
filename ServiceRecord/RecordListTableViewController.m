//
//  RecordListTableViewController.m
//  ChainLube
//
//  Created by Gray on 2014-07-25.
//  Copyright (c) 2014 Black Magma Inc. All rights reserved.
//

#import "RecordListTableViewController.h"
#import "ServiceViewController.h"

@interface RecordListTableViewController ()

@property (nonatomic, strong) NSMutableArray *vehicleThumbs;

@end

@implementation RecordListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.vehicleThumbs = [NSMutableArray new];
    [self updateVehicleThumbs];
    [self.tableView reloadData];
}
- (void)updateVehicleThumbs{
    if  ([self.records count] != 0){
        [self.records enumerateObjectsUsingBlock:^(Record *a, NSUInteger idxVehicle, BOOL *stop) {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedRecords = [[NSMutableArray alloc] init];
    self.tableView.rowHeight = 80;
    
    // Add service record button on Navigation bar
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone  target:self action:@selector(doneButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    self.title = @"Select records to send";
//    self.records = [NSArray new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.records count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    //Clear reusable cell properties
    cell.imageView.image = nil;
    cell.accessoryView = nil;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    if  ([self.records count] != 0){
        Record *a = self.records[indexPath.item];
        
        //Check and assign the first photo to the cell
//        if (a.photos.count >0){
//            RecordPhoto *b = a.photos[0];
//            UIImageView *photoView = [[UIImageView alloc]  initWithImage:[UIImage imageWithData:b.photo scale:[[UIScreen mainScreen] scale]]];
//            cell.imageView.image = photoView.image;
//        }
        if (self.vehicleThumbs.count > indexPath.item){
            if ([self.vehicleThumbs[indexPath.item] isEqual:[NSNull null]] || [self.vehicleThumbs[indexPath.item] isEqual:nil]){}
            else
                cell.imageView.image = self.vehicleThumbs[indexPath.item];
        }
        if ([self.selectedRecords containsObject:self.records[indexPath.row]])
            cell.backgroundColor = self.navigationController.navigationBar.tintColor;
        else    cell.backgroundColor = [UIColor whiteColor];
            

        //Check and assign odometer value to the cell
        if ( a.odometer.integerValue == 0 ){
            [cell.textLabel setText:[NSString stringWithFormat:@"%@", a.task]];
            cell.detailTextLabel.text = @"";
        }
        else{
            [cell.textLabel setText:[NSString stringWithFormat:@"%@", a.task]];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ %@",a.odometer,self.units]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.records.count){
        if (! [self.selectedRecords containsObject:self.records[indexPath.item]])
            [self.selectedRecords addObject:self.records[indexPath.item]];
        
        else if ([self.selectedRecords containsObject:self.records[indexPath.item]])
            [self.selectedRecords removeObject:self.records[indexPath.item]];
    }
    
    [self.tableView reloadData];
}

- (void)doneButtonPressed
{
    if (self.selectedRecords.count == 0){
        UIAlertView *alert = [[UIAlertView new] initWithTitle:@"Please select at least one record"
                                                      message:@""
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
    }
    else{
        self.serviceDelegate.selectedRecords = self.selectedRecords;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
