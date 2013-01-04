//
//  RHBaseStationTableViewController.m
//  RemoteHome
//
//  Created by James Wiegand on 1/3/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import "RHBaseStationTableViewController.h"
#import "RHAppDelegate.h"
#import "RHBaseStationModel.h"
#import "RHAddBaseStationViewController.h"

@interface RHBaseStationTableViewController ()

@end

@implementation RHBaseStationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        // Fetch the context and model from the delegate
        RHAppDelegate *delegate = (RHAppDelegate*)[[UIApplication sharedApplication] delegate];
        context = [delegate managedObjectContext];
        model = [delegate managedObjectModel];
        
        [self reloadDataSource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBaseStation)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self reloadDataSource];
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get model
    RHBaseStationModel *currModel = [dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = currModel.commonName;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Only support for delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Get the object
        RHBaseStationModel *delModel = [dataSource objectAtIndex:indexPath.row];
        
        // Delete from database
        [context deleteObject:delModel];
        NSError *e;
        [context save:&e];
        
        if(e) {
            // Do some error checking
        }
        
        // Delete the row from the data source
        [dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Helper functions

- (void)reloadDataSource
{
    NSError *e = nil;
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setReturnsObjectsAsFaults:NO];
    NSEntityDescription *desc = [[model entitiesByName] objectForKey:@"RHBaseStationModel"];
    [req setEntity:desc];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"commonName"
                                                               ascending:YES];
    [req setSortDescriptors:@[sortDesc]];
    NSArray *staticDataSource = [context executeFetchRequest:req error:&e];

    // Check to see if there is an error
    if (e) {
        // Do some error checking
    }
    
    dataSource = [[NSMutableArray alloc] initWithArray:staticDataSource];
}

- (void)addBaseStation
{
    // Swap view controller
    RHAddBaseStationViewController *add = [[RHAddBaseStationViewController alloc] initWithNibName:@"RHAddBaseStationViewController" bundle:nil];
    
    // Set the title
    [add setTitle:@"Add Base Station"];
    
    // Push the controller
    [[self navigationController] pushViewController:add animated:YES];
}

@end
