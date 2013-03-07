//
//  RHViewController.m
//  RHGarageDoorVC
//
//  Created by Joshua Kinkade on 1/17/13.
//  Copyright (c) 2013 Joshua Kinkade. All rights reserved.
//

#import "RHGarageDoorViewController.h"
#import "RHNetworkEngine.h"
#import "RHGarageDoorView.h"

@interface RHGarageDoorViewController ()

-(NSDictionary *)getRequestDictForAction:(NSInteger)action andHumanMessage:(NSString *)msg;
-(NSString *)getValueForKey:(NSString *)key fromRequest:(NSDictionary *)request;

@end

@implementation RHGarageDoorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[RHNetworkEngine sharedManager] setAddress:@"10.250.1.128"];
    
    //get initial status of door
//    self.deviceID = @"Jeff";
//    self.baseStationAddress = @"10.250.1.128";
    self.currentRequest = [self getRequestDictForAction:IS_OPEN
                                        andHumanMessage:@"Open?"];
    [self sendRequest:self.currentRequest];
    
    self.stateChecker = [NSTimer timerWithTimeInterval:30
                                                target:self
                                              selector:@selector(checkState)
                                              userInfo:nil
                                               repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.stateChecker forMode:NSDefaultRunLoopMode];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handlers
- (IBAction)toggleDoor:(id)sender
{
    if (self.doorOpened) {
        self.currentRequest = [self getRequestDictForAction:CLOSE_IF_OPEN
                                            andHumanMessage:@"Close the door"];
    }
    else
    {
        self.currentRequest = [self getRequestDictForAction:OPEN_IF_CLOSED
                                            andHumanMessage:@"Open the door"];
    }
    
    [self sendRequest:self.currentRequest];
    
}

- (void)checkState {
    self.currentRequest = [self getRequestDictForAction:IS_OPEN
                                        andHumanMessage:@"Open?"];
    
    [self sendRequest:self.currentRequest];
}

#pragma mark - Network Handling Methods
-(void)sendRequest:(NSDictionary *)request
{
    [RHNetworkEngine sendJSON:request
          toAddressWithTarget:self
              withRetSelector:@selector(requestReturnedWithData:)
               andErrSelector:@selector(requestReturnedWithError:)
                     withMode:RHNetworkModeManaged];
}

- (void)requestReturnedWithData:(NSDictionary *)requestData
{
    NSString * data = [self getValueForKey:@"Data"
                               fromRequest:requestData];
//    NSString * humanMessage = [self getValueForKey:@"HumanMessage"
//                                       fromRequest:requestData];
    
    NSInteger currentAction = [[self getValueForKey:@"Data" fromRequest:self.currentRequest] integerValue];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Object in Doorway"
                                                     message:@"You're garage door could not close because an object was detected in the doorway."
                                                    delegate:nil
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles: nil];
    
    
    GD_MESSAGE_T message = [data integerValue];
    if (message) {
        switch (currentAction) {
            case OPEN_IF_CLOSED:
                [self.garageDoor setOpened:1.0];
                self.doorOpened = YES;
                [self.toggleButton.titleLabel setText:@"Close"];
                break;
            case CLOSE_IF_OPEN:
                [self.garageDoor setOpened:0.0];
                self.doorOpened = NO;
                [self.toggleButton.titleLabel setText:@"Open"];
                break;
            case IS_OPEN:
                self.doorOpened = YES;
                [self.garageDoor setOpened:1.0];
                [self.toggleButton.titleLabel setText:@"Close"];
                break;
            default:
                break;
        }
    }
    else
    {
        switch (currentAction) {
            case OPEN_IF_CLOSED:
                self.doorOpened = NO;
                break;
            case CLOSE_IF_OPEN:
                self.doorOpened = YES;
                [self.garageDoor setOpened:0.5];
                [alert show];
                break;
            case IS_OPEN:
                self.doorOpened = NO;
                [self.garageDoor setOpened:0.0];
                [self.toggleButton.titleLabel setText:@"Open"];
                break;
            default:
                break;
        }
    }
    
    NSLog(@"%d",self.doorOpened);
}

- (void)requestReturnedWithError:(NSString *)error
{
    NSString * alertTitle = @"Connection Error";
    NSString * alertMessage = @"Could not connect to your base staton";
    
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                     message:alertMessage
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Retry", nil];
    
    [alert show];
}

#pragma mark - Helper Methods
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
