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
    
    self.currentRequest = [self getRequestDictForAction:GD_CMD_TOGGLE
                                        andHumanMessage:@"Toggle"];
    
    [self sendRequest:self.currentRequest];
    
}

- (void)checkState {
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
    
    NSInteger currentAction = [[self getValueForKey:@"Data" fromRequest:self.currentRequest] integerValue];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Object in Doorway"
                                                     message:@"You're garage door could not close because an object was detected in the doorway."
                                                    delegate:nil
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles: nil];
    NSTimer * confirmClosedTimer;
    
    GD_MESSAGE_T message = [data integerValue];
//    if (message) {
//        switch (currentAction) {
//            case OPEN_IF_CLOSED:
//                [self.garageDoor setSpeed:GD_SLOW];
//                [self.garageDoor setOpened:1.0];
//                self.doorOpened = YES;
//                [self.toggleButton.titleLabel setText:@"Close"];
//                break;
//            case CLOSE_IF_OPEN:
//                [self.garageDoor setSpeed:GD_SLOW];
//                [self.garageDoor setOpened:0.0];
//                self.doorOpened = NO;
//                [self.toggleButton.titleLabel setText:@"Open"];
//                
//                confirmClosedTimer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(confirmDoorClosed) userInfo:nil repeats:NO];
//                
//                [[NSRunLoop mainRunLoop] addTimer:confirmClosedTimer forMode:NSDefaultRunLoopMode];
//                
//                break;
//            case IS_OPEN:
//                self.doorOpened = YES;
//                [self.garageDoor setSpeed:GD_FAST];
//                [self.garageDoor setOpened:1.0];
//                [self.toggleButton.titleLabel setText:@"Close"];
//                break;
//            case IS_CLOSED:
//                //do nothing, door is already closed
//            default:
//                break;
//        }
//    }
//    else
//    {
//        switch (currentAction) {
//            case OPEN_IF_CLOSED:
//                self.doorOpened = NO;
//                break;
//            case CLOSE_IF_OPEN:
//                self.doorOpened = YES;
//                [self.garageDoor setSpeed:GD_FAST];
//                [self.garageDoor setOpened:0.5];
//                [alert show];
//                break;
//            case IS_OPEN:
//                self.doorOpened = NO;
//                [self.garageDoor setSpeed:GD_FAST];
//                [self.garageDoor setOpened:0.0];
//                [self.toggleButton.titleLabel setText:@"Open"];
//                break;
//            case IS_CLOSED:
//                self.doorOpened = YES;
//                [self.garageDoor setSpeed:GD_FAST];
//                [self.garageDoor setOpened:0.5];
//                [self.toggleButton.titleLabel setText:@"Close"];
//                [alert show];
//            default:
//                break;
//        }
//    }
    
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
                

            }
            else if(self.doorOpened == GD_PARTIAL) {
                NSLog(@"Opening");
                [self.garageDoor setSpeed:GD_SLOW];
                [self.garageDoor setOpened:1.0];
                [self.toggleButton.titleLabel setText:@"Close"];
                self.doorOpened = GD_OPEN;
            }
            break;
        case GD_CMD_QUERY:
            if (message == GD_OPEN) {
                NSLog(@"Open");
                [self.garageDoor setSpeed:GD_FAST];
                [self.garageDoor setOpened:1.0];
                [self.toggleButton.titleLabel setText:@"Close"];
            }
            else if (message == GD_CLOSED) {
                NSLog(@"Closed");
                [self.garageDoor setSpeed:GD_FAST];
                [self.garageDoor setOpened:0.0];
                [self.toggleButton.titleLabel setText:@"Open"];
            }
            else if (message == GD_PARTIAL) {
                NSLog(@"Partial");
                
                [alert show];
                
                [self.garageDoor setSpeed:GD_FAST];
                [self.garageDoor setOpened:0.5];
                [self.toggleButton.titleLabel setText:@"Open"];
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
    NSString * json = [NSString stringWithFormat:@"{\"HRDeviceRequest\":{\"DeviceID\":\"%@\",\"Type\":\"Str\",\"Data\":\"%d\",\"HumanMessage\":\"%@\"}}", self.deviceID, action, msg];
    NSError * error;
    
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
    return dict;
}

- (NSString *)getValueForKey:(NSString *)key fromRequest:(NSDictionary *)request
{
    NSDictionary * reqDict = [request objectForKey:@"HRDeviceRequest"];
        
    return [reqDict objectForKey:key];
}

#pragma mark - UIAlertViewDelegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) //if the user pressed the retry button
    {
        [self sendRequest:self.currentRequest];
    }
}
@end
