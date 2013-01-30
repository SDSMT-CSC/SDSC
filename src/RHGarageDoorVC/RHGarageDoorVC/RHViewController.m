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

- (IBAction)toggleDoor:(id)sender {
        
    NSDictionary * request = [self getRequestDictForAction:1 andHumanMessage:@"Hello, World!"];
        
    NSLog(@"%@",[self getValueForKey:@"HumanMessage" fromRequest:request]);
    NSLog(@"%@",[self getValueForKey:@"Data" fromRequest:request]);
    NSLog(@"%@",[self getValueForKey:@"DeviceID" fromRequest:request]);

    
    
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

- (void)requestReturnedData:(NSDictionary *)data
{
    
}

- (void)requestReturnedError:(NSString *)error
{
    
}

- (NSDictionary *)getRequestDictForAction:(NSInteger)action andHumanMessage:(NSString *)msg
{
    NSString * json = [NSString stringWithFormat:@"{\"HRDeviceRequest\":[{\"DeviceID\":\"%@\"},{\"Type\":\"Byte\"},{\"Data\":\"%d\"},{\"HumanMessage\":\"%@\"}]}", self.deviceID, action,msg];
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
@end
