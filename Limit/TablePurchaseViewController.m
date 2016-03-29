//
//  TabelPurchaseTableViewController.m
//  Limit_beta
//
//  Created by Rix on 5/25/15.
//  Copyright (c) 2015 Rix. All rights reserved.
//

#import "TablePurchaseViewController.h"

@interface TablePurchaseViewController ()

@property IAPManager *IAPController;

@end



@implementation TablePurchaseViewController


- (IBAction)RestoreButton:(id)sender{
    [self.IAPController restore];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.IAPController = [[IAPManager alloc] init];
    
    NSArray *product = [NSArray arrayWithObjects:@"California",
                                                   @"Oregon",
                                                   @"Washington",
                                                   nil];
    
    [self.IAPController verifyProductID:product];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





//#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    // Only one section(state)
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    // Number of product
    return [self.IAPController.productID count];
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Set title for the first section
    return @"State";
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"
                                                            forIndexPath:indexPath];
    
    // Load purchase record and check if it is true
    if([Utility loadBoolData:[self.IAPController.productID objectAtIndex:indexPath.row] ])
        // Set Checkmark
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // Set content
    cell.textLabel.text = [self.IAPController.productID objectAtIndex:indexPath.row];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This will be triggered if hardcoded productID doesn't match with
    // the productID from iTunesConnect
    NSLog(@"%d", (int)indexPath.row);
    if((int)indexPath.row >= [self.IAPController.productID count])
        return;

    // Runs if not purchased
    if(![Utility loadBoolData:[self.IAPController.productID objectAtIndex:indexPath.row] ]){
        // Purchase product
        [self.IAPController purchase:(int)indexPath.row];
    }
    
    // Auto deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
