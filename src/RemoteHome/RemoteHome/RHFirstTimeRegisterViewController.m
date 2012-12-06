	//
//  RHFirstTimeViewController.m
//  RemoteHome
//
//  Created by James Wiegand on 11/25/12.
//  Copyright (c) 2012 James Wiegand. All rights reserved.
//

#import "RHFirstTimeRegisterViewController.h"
#import "RHBaseStationModel.h"
#import "RHAppDelegate.h"

#define ADDRESS @"172.20.10.12"     // DDNS address
#define TIMERTIME 3.0              // Timeout time


@interface RHFirstTimeRegisterViewController ()

@end

@implementation RHFirstTimeRegisterViewController

@synthesize inputStream,outputStream, timeout, setupTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Fetch the context and model from the delegate
        RHAppDelegate *delegate = (RHAppDelegate*)[[UIApplication sharedApplication] delegate];
        context = [delegate managedObjectContext];
        model = [delegate managedObjectModel];
        
        //set delegate
        [[self serialNumberField] setDelegate:self];
        [[self nameField] setDelegate:self];
        [[self passwordField] setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons	

// Create a connection and retrieve the data for that base station object
- (IBAction)userDidPressRegisterButton:(id)sender {
    
    // Check to see if any of the fields are blank
    // If so print an error and return to the UIView
    NSString *serial = [[self serialNumberField] text];
    NSString *name = [[self nameField] text];
    NSString *pass = [[self passwordField] text];
    
    if ([serial isEqualToString:@""]) {
        // Print an error
        UIAlertView *err = [[UIAlertView alloc]
                            initWithTitle:@"Error"
                            message:@"Please enter the serial number in the serial number field."
                            delegate:Nil
                            cancelButtonTitle:@"Okay"
                            otherButtonTitles: nil];
        [err show];
        return;
    }
    else if ([name isEqualToString:@""]) {
        // Print an error
        UIAlertView *err = [[UIAlertView alloc]
                            initWithTitle:@"Error"
                            message:@"Please enter a name in the name field."
                            delegate:Nil
                            cancelButtonTitle:@"Okay"
                            otherButtonTitles: nil];
        [err show];
        return;
    }
    else if ([pass isEqualToString:@""]) {
        // Print an error
        UIAlertView *err = [[UIAlertView alloc]
                            initWithTitle:@"Error"
                            message:@"Please enter the password in the password field."
                            delegate:Nil
                            cancelButtonTitle:@"Okay"
                            otherButtonTitles: nil];
        [err show];
        return;
    }
    
    // Connect to the DDNS to get the address (this should be refactored into a class)
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    // Create a connection
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ADDRESS, 80, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream*)readStream;
    outputStream = (__bridge NSOutputStream*)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    // Open the connection and set the timeout
    [inputStream open];
    [outputStream open];
    
    [self startTimeoutTimer];
    
    // Show the status
    [[self loadingView] setHidden:NO];
    [[self statusLabel] setText:@"Connecting..."];
    
    // Check first responder status
    [[self serialNumberField] resignFirstResponder];
    [[self nameField] resignFirstResponder];
    [[self passwordField] resignFirstResponder];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    // Socket Open
    if(eventCode == NSStreamEventOpenCompleted) {
        // Invalidate timer
        [timeout invalidate];
        
        // Second timeout timer since the system has not ack
        [self startTimeoutTimer];
    }
    
    // Server disconnected
    if(eventCode == NSStreamEventEndEncountered) {
        
        // Close the sockets
        [self cleanUp];

    }
    
    // Error
    if (eventCode == NSStreamEventErrorOccurred) {
        
        // Close the sockets
        [self cleanUp];
        
        // Print an error
        UIAlertView *err = [[UIAlertView alloc]
                            initWithTitle:@"Error"
                            message:@"An error in the connection has been encountered. Please try again."
                            delegate:Nil
                            cancelButtonTitle:@"Okay"
                            otherButtonTitles: nil];
        [err show];
        return;
    }
    
    // By: Ray Wenderlich
    // http://www.raywenderlich.com/3932/how-to-create-a-socket-based-iphone-app-and-server
    // If the system said somthing
    if (eventCode == NSStreamEventHasBytesAvailable) {
        uint8_t buffer[1024];
        int len;
        
        while ([inputStream hasBytesAvailable]) {
            len = [inputStream read:buffer maxLength:sizeof(buffer)];
            if(len > 0) {
                
                
                //Convert the JSON into a dictonary
                NSError *e;
                NSData *inputData = [NSData dataWithBytes:buffer length:len];
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:inputData
                                                                        options:kNilOptions
                                                                        error:&e];
                
                // Search the Dictonary for known responses
                NSArray *resArr;
                
                // Connection response
                resArr = (NSArray*) [response objectForKey:@"DDNSConnected"];
                if (resArr != Nil && resArr[0]) {
                    // Invalidate second timer
                    [timeout invalidate];
                    
                    // Connection established send the registration data
                    [self sendTCPIPData];
                }
                
                // IP address of the base station
                resArr = (NSArray*) [response objectForKey:@"HRHomeStationReply"];
                if (resArr != Nil)
                {
                    // We only need to worry about the first element
                    NSDictionary  *baseSationData = (NSDictionary*) resArr[0];
                    
                    // Find the address, we have the base station
                    
                    // Check for bad base station
                    id baseStationAddress = [baseSationData objectForKey:@"StationIP"] ;
                    if( baseStationAddress == [NSNull null])
                    {
                        [self noSuchBaseStationInDDNS];
                    }
                    
                    // If address is good create a new base station object
                    else
                    {
                        [self createNewBaseStation:(NSString*)baseStationAddress];
                    }
                    
                }
                
            }
        }
    }
    
}

#pragma mark - Network Communications

// Packages the data into JSON format and transmits it over the line
- (void)sendTCPIPData
{
    // Update the label that we have connected
    [[self statusLabel] setText:@"Connected"];
    
    NSString *msg = [ NSString stringWithFormat:
                            @"{ \"HRHomeStationsRequest\" : [ { \"StationDID\" : \"%@\" } ] }",
                            [[self serialNumberField] text] ];
    NSData *data = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
    
    [[self statusLabel] setText:@"Registering Base Station"];
}

// Create new base station object with ip address
- (void)createNewBaseStation:(NSString *) addr
{
    RHBaseStationModel *newBaseStation = [NSEntityDescription insertNewObjectForEntityForName:@"RHBaseStationModel" inManagedObjectContext:context];
    
    // Get the data from fields
    NSString *serial = [[self serialNumberField] text];
    NSString *name = [[self nameField] text];
    NSString *pass = [[self passwordField] text];
    
    // Set the correct data
    [newBaseStation setSerialNumber:serial];
    [newBaseStation setCommonName:name];
    [newBaseStation setHashedPassword:pass];
    [newBaseStation setIpAddress:addr];
    
    // Place the base station into the SQLLite DB
    NSError *e;
    [context save:&e];
    
    
    //!DEBUG
    // Test to see if we can get the items out
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setReturnsObjectsAsFaults:NO];
    NSEntityDescription *desc = [[model entitiesByName] objectForKey:@"RHBaseStationModel"];
    [req setEntity:desc];
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"commonName"
                                                               ascending:YES];
    [req setSortDescriptors:@[sortDesc]];
    NSArray *res = [context executeFetchRequest:req error:&e];
    
    // Print each element
    for (RHBaseStationModel *b in res) {
        NSLog(@"======Entry======");
        NSLog(@"Name : %@", [b commonName]);
        NSLog(@"Serial Number : %@", [b serialNumber]);
        NSLog(@"Address : %@", [b ipAddress]);
        NSLog(@"Password : %@", [b hashedPassword]);
    }
    //!ENDDEBUG
    
    
    // Close the connection and tell the user it was a success
    [self cleanUp];
    
    UIAlertView *err = [[UIAlertView alloc]
                        initWithTitle:@"Success"
                        message:@"The station was successfully registered"
                        delegate:Nil
                        cancelButtonTitle:@"Continue"
                        otherButtonTitles: nil];
    
    [err show];
}

// If a the station is not registered
- (void)noSuchBaseStationInDDNS
{
    // Close the connections
    [self cleanUp];
    
    // Show an error message
    UIAlertView *err = [[UIAlertView alloc]
                        initWithTitle:@"Error"
                        message:@"The station ID was not found. Please check to make sure your station ID was entered correctly and that your station was properly set up."
                        delegate:Nil
                        cancelButtonTitle:@"Okay"
                        otherButtonTitles: nil];
    [err show];
}

#pragma mark - Timeout

- (void)startTimeoutTimer
{
    timeout = [NSTimer scheduledTimerWithTimeInterval:TIMERTIME
                                            target:self
                                            selector:@selector(timeoutFire)
                                            userInfo:nil
                                            repeats:NO];
}


// Closes connections and cleans up
- (void)timeoutFire
{
    // Close sockets
    [self cleanUp];
    
    // Show an error message
    // Print an error
    UIAlertView *err = [[UIAlertView alloc]
                        initWithTitle:@"Error"
                        message:@"Could not connect to the DDNS server. Please check your connection and try again."
                        delegate:Nil
                        cancelButtonTitle:@"Okay"
                        otherButtonTitles: nil];
    [err show];
    return;
}

// closes the sockets
- (void)cleanUp
{
    // Check for timers
    if(timeout.isValid)
    {
        [timeout invalidate];
    }
    
    // Hide the loading view
    [[self loadingView] setHidden:YES];
    
    [inputStream close];
    [outputStream close];
}

#pragma mark - UITextFieldDelegate


@end
