//
//  RHUpdateBaseStationViewController.m
//  RemoteHome
//
//  Created by James Wiegand on 1/8/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import "RHUpdateBaseStationViewController.h"
#import "RHAppDelegate.h"

@interface RHUpdateBaseStationViewController ()

@end

@implementation RHUpdateBaseStationViewController

@synthesize addressField, nameField, serialField, passwordField, selectedModel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Fetch the context and model from the delegate
        RHAppDelegate *delegate = (RHAppDelegate*)[[UIApplication sharedApplication] delegate];
        context = [delegate managedObjectContext];
        model = [delegate managedObjectModel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[self nameField] setText:[selectedModel commonName]];
    [[self passwordField] setText:[selectedModel hashedPassword]];
    [[self serialField] setText:[selectedModel serialNumber]];
    [[self addressField] setText:[selectedModel ipAddress]];
    
    [nameField setDelegate:self];
    [passwordField setDelegate:self];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

- (IBAction)userDidPressUpInsideTheUpdateButton:(id)sender {
    NSString *name = [[self nameField] text];
    NSString *newPassword = nil;
    
    if (![[[self passwordField] text] isEqualToString:[selectedModel hashedPassword]]) {
        newPassword = [passwordField text];
    }
    
    // Fetch the managed object (stupid workaround because context was NOT saving!)
    
    NSError *e = nil;
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setReturnsDistinctResults:NO];
    NSEntityDescription *desc = [NSEntityDescription entityForName:@"RHBaseStationModel" inManagedObjectContext:context];
    [req setEntity:desc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"serialNumber == %@", [selectedModel serialNumber]];
    [req setPredicate:pred];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"serialNumber" ascending:YES];
    NSArray *sortDesc = @[sort];
    [req setSortDescriptors:sortDesc];
    
    NSManagedObject *managedBaseStationModel = [[context executeFetchRequest:req error:&e] lastObject];
    
    [context deleteObject:managedBaseStationModel];
    
    [managedBaseStationModel setValue:name forKey:@"commonName"];
    
    RHBaseStationModel *newBaseStation = [NSEntityDescription insertNewObjectForEntityForName:@"RHBaseStationModel" inManagedObjectContext:context];
    
    [newBaseStation setCommonName:name];
    [newBaseStation setIpAddress:[selectedModel ipAddress]];
    [newBaseStation setSerialNumber:[selectedModel serialNumber]];
    
    if (newPassword) {
        [newBaseStation setHashedPassword:newPassword];
    } else {
        [newBaseStation setPasswordWithoutHash:[selectedModel hashedPassword]];
    }
    
    selectedModel = newBaseStation;
    
    if (![context save:&e]) {
        NSLog(@"%@", e.localizedDescription);
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
