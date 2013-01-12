//
//  RHDeviceViewController.m
//  RemoteHome
//
//  Created by James Wiegand on 1/9/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import "RHDeviceViewController.h"
#import "RHDeviceModel.h"
#import "RHErrorViewController.h"

@interface RHDeviceViewController ()

@end

@implementation RHDeviceViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Get the corrisponding object
    RHDeviceModel *currentModel = (RHDeviceModel*)[[self dataSource] objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [[cell textLabel] setText:[currentModel deviceName]];
    
    if ([currentModel errorCode] == 0) {
        [[cell detailTextLabel] setTextColor:[UIColor greenColor]];
        [[cell detailTextLabel] setText:@"Online"];
    } else {
        [[cell detailTextLabel] setTextColor:[UIColor redColor]];
        [[cell detailTextLabel] setText:@"Offline"];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // Get the correct device
    RHDeviceModel *currentDevice = (RHDeviceModel*)[[self dataSource] objectAtIndex:indexPath.row];
    
    // If the device is online load the correct view
    if (currentDevice.errorCode == 0) {
        switch (currentDevice.deviceType) {
            case RHSprinklerType:
                [self loadSprinklerView:currentDevice];
                break;
            case RHGarageDoorType:
                [self loadGarageDoorView:currentDevice];
                break;
            case RHLightType:
                [self loadLightView:currentDevice];
                break;
            default:
                break;
        }
    }
    
}

# pragma mark - Device Views

- (void)loadSprinklerView:(RHDeviceModel*)currentDevice
{
    
}

- (void)loadGarageDoorView:(RHDeviceModel*)currentDevice
{
    
}

-(void)loadLightView:(RHDeviceModel*)currentDevice
{
    
}

@end
