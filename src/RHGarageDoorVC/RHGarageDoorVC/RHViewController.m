//
//  RHViewController.m
//  RHGarageDoorVC
//
//  Created by Joshua Kinkade on 1/17/13.
//  Copyright (c) 2013 Joshua Kinkade. All rights reserved.
//

#import "RHViewController.h"
#import "RHNetworkEngine.h"

@interface RHViewController ()

-(NSDictionary *)getRequestDictForAction:(NSInteger)action andHumanMessage:(NSString *)msg;
-(NSString *)getValueForKey:(NSString *)key fromRequest:(NSDictionary *)request;

@end

@implementation RHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //get initial status of door
    self.deviceID = @"Jeff";
    self.doorOpened = NO;
    self.objectDetected = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleDoor:(id)sender
{
        
    self.currentRequest = [self getRequestDictForAction:1 andHumanMessage:@"Hello, World!"];
    
    [self sendRequest:self.currentRequest];
    
    
    if (self.doorOpened) {
        if (!self.objectDetected) {
            //send request to close the door
        }
        else
        {
            //let the user know that there is an object in the door's way
        }
    }
    else
    {
        //send request to open the door
    }
    
}

-(void)sendRequest:(NSDictionary *)request
{
    [RHNetworkEngine sendJSON:request toAddressWithTarget:self withRetSelector:@selector(requestReturnedWithData:) andErrSelector:@selector(requestReturnedWithError:) withMode:RHNetworkModeManaged];
}

- (void)requestReturnedWithData:(NSDictionary *)requestData
{
    NSString * type = [self getValueForKey:@"Type" fromRequest:requestData];
    NSString * data = [self getValueForKey:@"Data" fromRequest:requestData];
    NSString * humanMessage = [self getValueForKey:@"HumanMessage" fromRequest:requestData];
    
}

- (void)requestReturnedWithError:(NSString *)error
{
    NSString * alertTitle = @"Oops.";
    NSString * alertMessage = @"Something bad happend";
    
    if ([error isEqualToString:@"timeout"])
    {
        alertTitle = @"Timeout";
        alertMessage = @"The connection timed out";
    }
    else if ([error isEqualToString:@"NSStreamEventErrorOccurred"])
    {
        alertTitle = error;
        alertMessage = @"An NSStreamEvent occurred";
    }
    else if([error isEqualToString:@"NSStreamEventEndEncountered"])
    {
        alertTitle = error;
        alertMessage = @"The end of the NSStreamEvent was encountered";
    }
    else if([error isEqualToString:@"no address"])
    {
        alertTitle = @"No IP Address";
        alertMessage = @"Tell me where to send the request!";
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                     message:alertMessage
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Retry", nil];
    
    [alert show];
}

- (NSDictionary *)getRequestDictForAction:(NSInteger)action andHumanMessage:(NSString *)msg
{
    NSString * json = [NSString stringWithFormat:@"{\"HRDeviceRequest\":[{\"DeviceID\":\"%@\"},{\"Type\":\"Byte\"},{\"Data\":\"%d\"},{\"HumanMessage\":\"%@\"}]}", self.deviceID, action, msg];
    NSError * error;
    
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
    return dict;
}

- (NSString *)getValueForKey:(NSString *)key fromRequest:(NSDictionary *)request
{
    NSArray * reqArray = [request objectForKey:@"HRDeviceRequest"];
        
    NSString * value;
    
    for (NSDictionary * dict in reqArray) {
        if ([dict objectForKey:key] != nil) {
            value = [dict objectForKey:key];
        }
    }
    
    return value;
}

#pragma mark - UIAlertViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) //if the user pressed the retry button
    {
        [self sendRequest:self.currentRequest];
    }
}
@end
