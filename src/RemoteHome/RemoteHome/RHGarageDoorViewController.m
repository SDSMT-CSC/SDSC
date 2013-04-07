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
    
    // Set up the button
    [self.toggleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    //get initial status of door
    self.currentRequest = [self getRequestDictForAction:GD_CMD_QUERY
                                        andHumanMessage:@"Open?"];
    [self sendRequest:self.currentRequest];
    
    self.stateChecker = [NSTimer timerWithTimeInterval:30
                                                target:self
                                              selector:@selector(checkState)
                                              userInfo:nil
                                               repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.stateChecker forMode:NSDefaultRunLoopMode];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self.stateChecker invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handlers
- (IBAction)toggleDoor:(id)sender
{
//    if (self.doorOpened) {
//        self.currentRequest = [self getRequestDictForAction:CLOSE_IF_OPEN
//                                            andHumanMessage:@"Close the door"];
//    }
//    else
//    {
//        self.currentRequest = [self getRequestDictForAction:OPEN_IF_CLOSED
//                                            andHumanMessage:@"Open the door"];
//    }
    
    NSLog(@"Toggling");
    
    //don't let another request begin if there is already one in progress
//    while (self.currentRequest != nil) {
//        //wait
//    }
    
    if (sender == self.upSwipeRecognizer && self.doorOpened == 1.0) {
        return;
    }
    
    if (sender == self.downSwipeRecognizer && (self.doorOpened == 0.0 || self.doorOpened == 0.5) ) {
        return;
    }
    
    if (sender == self.upSwipeRecognizer) {
        NSLog(@"Swipe up");
    }
    else if( sender == self.downSwipeRecognizer) {
        NSLog(@"Swipe down");
    }
    
    self.currentRequest = [self getRequestDictForAction:GD_CMD_TOGGLE
                                        andHumanMessage:@"Toggle"];
    
    [self sendRequest:self.currentRequest];
    
}

- (void)checkState {
    
    //creating another request while the app is waiting for a response
    //causes problems, so don't let the background state checker do anything
    //if there is an existing request
    if (self.currentRequest != nil) {
        return;
    }
    
    self.currentRequest = [self getRequestDictForAction:GD_CMD_QUERY
                                        andHumanMessage:@"Open?"];
    
    [self sendRequest:self.currentRequest];
}

- (void)confirmDoorClosed {
    self.currentRequest = [self getRequestDictForAction:GD_CMD_QUERY
                                        andHumanMessage:@"Closed?"];
    
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
    

    
    if( data == nil || self.currentRequest == nil )
    {
        return;
    }
    
    NSString * actionString = [self getValueForKey:@"Data" fromRequest:self.currentRequest];
    
    if(actionString == nil )
    {
        return;
    }
    
    NSInteger currentAction = [actionString integerValue];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Object in Doorway"
                                                     message:@"You're garage door could not close because an object was detected in the doorway."
                                                    delegate:nil
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles: nil];
    
    GD_MESSAGE_T message = [data integerValue];
    
    switch (currentAction) {
        case GD_CMD_TOGGLE:
            if (self.doorOpened == GD_OPEN) {
                NSLog(@"Closing");
                [self.garageDoor setSpeed:GD_SLOW];
                [self.garageDoor setOpened:0.0];
                [self.toggleButton.titleLabel setText:@"Open"];
                self.doorOpened = GD_CLOSED;
                
                NSTimer * checkTimer = [NSTimer timerWithTimeInterval:12
                                                               target:self
                                                             selector:@selector(checkState)
                                                             userInfo:nil repeats:NO];
                
                [[NSRunLoop mainRunLoop] addTimer:checkTimer
                                          forMode:NSDefaultRunLoopMode];
            }
            else if(self.doorOpened == GD_CLOSED) {
                NSLog(@"Opening");
                [self.garageDoor setSpeed:GD_SLOW];
                [self.garageDoor setOpened:1.0];
                [self.toggleButton.titleLabel setText:@"Close"];
                self.doorOpened = GD_OPEN;
                
                self.currentRequest = nil;

            }
            else if(self.doorOpened == GD_PARTIAL) {
                NSLog(@"Opening");
                [self.garageDoor setSpeed:GD_SLOW];
                [self.garageDoor setOpened:1.0];
                [self.toggleButton.titleLabel setText:@"Close"];
                self.doorOpened = GD_OPEN;
                
                self.currentRequest = nil;
            }
            break;
        case GD_CMD_QUERY:
            if (message == GD_OPEN) {
                NSLog(@"Open");
                [self.garageDoor setSpeed:GD_FAST];
                [self.garageDoor setOpened:1.0];
                [self.toggleButton.titleLabel setText:@"Close"];
                
                self.currentRequest = nil;
            }
            else if (message == GD_CLOSED) {
                NSLog(@"Closed");
                [self.garageDoor setSpeed:GD_FAST];
                [self.garageDoor setOpened:0.0];
                [self.toggleButton.titleLabel setText:@"Open"];
                
                self.currentRequest = nil;
            }
            else if (message == GD_PARTIAL) {
                NSLog(@"Partial");
                
                [alert show];
                
                [self.garageDoor setSpeed:GD_FAST];
                [self.garageDoor setOpened:0.5];
                [self.toggleButton.titleLabel setText:@"Open"];
                
                self.currentRequest = nil;
            }
            self.doorOpened = message;
            break;
        default:
            break;
    }
    
    NSLog(@"%d",self.doorOpened);
}

- (void)requestReturnedWithError:(NSString *)error
{
    NSLog(@"%@",error);
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
    NSString * json = [NSString stringWithFormat:@"{\"HRDeviceRequest\":{\"DeviceID\":\"%@\",\"Password\":\"%@\",\"Type\":\"Str\",\"Data\":\"%d\",\"HumanMessage\":\"%@\"}}", self.deviceID, self.password, action, msg];
    NSError * error;
    
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
    return dict;
}

- (NSString *)getValueForKey:(NSString *)key fromRequest:(NSDictionary *)request
{
    NSString * str;
    @try {
        NSDictionary * reqDict = [request objectForKey:@"HRDeviceRequest"];
        str = [reqDict objectForKey:key];
    }
    @catch (NSException *exception) {
        NSLog(@"Error while parsing request");
        return @"-1";
    }
   
    return str;
}

#pragma mark - UIAlertViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) //if the user pressed the retry button
    {
        [self sendRequest:self.currentRequest];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
