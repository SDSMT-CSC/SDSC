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
// build a request dictionary
-(NSDictionary *)getRequestDictForAction:(NSInteger)action andHumanMessage:(NSString *)msg;

//get the value of a key from the dictionary
-(NSString *)getValueForKey:(NSString *)key fromRequest:(NSDictionary *)request;

@end

@implementation RHGarageDoorViewController

/**
 * @brief get the view controller ready
 * @detail sets up the user interface, sends a query for the current state of the 
 *         garage door and sets up a periodic state checker
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the button
    [self.toggleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    //get initial status of door
    self.currentRequest = [self getRequestDictForAction:GD_CMD_QUERY
                                        andHumanMessage:@"Open?"];
    [self sendRequest:self.currentRequest];
    
    //create timer to check state
    self.stateChecker = [NSTimer timerWithTimeInterval:30
                                                target:self
                                              selector:@selector(checkState)
                                              userInfo:nil
                                               repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.stateChecker forMode:NSDefaultRunLoopMode];
    
}

/**
 * @brief cleans up viewcontroller
 * @detail cancels state checker timer before the view disappears
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (void)viewWillDisappear:(BOOL)animated {
    [self.stateChecker invalidate];
}

/**
 * @brief frees any unnecessary resources to save memory
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handlers

/**
 * @brief toggles the door
 * @detail sets the current request to a toggle request and sends it and makes
 *         sure swipe gestures will only work in the correct direction
 * @param sender the object that sent the toggleDoor message
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (IBAction)toggleDoor:(id)sender
{
    
    NSLog(@"Toggling");
    
    //should not toggle if the door is opened when user tries to open it.
    if (sender == self.upSwipeRecognizer && self.doorOpened == 1.0) {
        return;
    }
    
    //should not toggle if the door is closed when user tries to close it.
    if (sender == self.downSwipeRecognizer && (self.doorOpened == 0.0 || self.doorOpened == 0.5) ) {
        return;
    }
    
    //used for debugging
    if (sender == self.upSwipeRecognizer) {
        NSLog(@"Swipe up");
    }
    else if( sender == self.downSwipeRecognizer) {
        NSLog(@"Swipe down");
    }
    
    //build request dictionary
    self.currentRequest = [self getRequestDictForAction:GD_CMD_TOGGLE
                                        andHumanMessage:@"Toggle"];
    
    //send the request
    [self sendRequest:self.currentRequest];
    
}

/**
 * @brief check the state of the door
 * @detail checks the state of the door if there is not a request in progress,
 *         used by the background state checker.
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (void)checkState {
    
    //creating another request while the app is waiting for a response
    //causes problems, so don't let the background state checker do anything
    //if there is an existing request
    if (self.currentRequest != nil) {
        return;
    }
    
    //get query request dictionary
    self.currentRequest = [self getRequestDictForAction:GD_CMD_QUERY
                                        andHumanMessage:@"Open?"];
    
    //send it
    [self sendRequest:self.currentRequest];
}

/**
 * @brief check the state of the door
 * @detail checks the state of the door, used for user initiated actions
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (void)confirmDoorClosed {
    self.currentRequest = [self getRequestDictForAction:GD_CMD_QUERY
                                        andHumanMessage:@"Closed?"];
    
    [self sendRequest:self.currentRequest];
}

#pragma mark - Network Handling Methods

/**
 * @brief send a request
 * @param request the request dictionary to be sent to the base station
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
-(void)sendRequest:(NSDictionary *)request
{
    [RHNetworkEngine sendJSON:request
          toAddressWithTarget:self
              withRetSelector:@selector(requestReturnedWithData:)
               andErrSelector:@selector(requestReturnedWithError:)
                     withMode:RHNetworkModeManaged];
}

/**
 * @brief handles successful request response
 * @detail updates the user interface to reflect the current state of the door
 *         after the current request has completed
 * @param requestData dictionary containing the response data from the base station
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (void)requestReturnedWithData:(NSDictionary *)requestData
{
    //get the message from the response
    NSString * data = [self getValueForKey:@"Data"
                               fromRequest:requestData];
    

    //if response is bad don't continue
    if( data == nil || self.currentRequest == nil )
    {
        return;
    }
    
    //get the action that the request was sending
    NSString * actionString = [self getValueForKey:@"Data" fromRequest:self.currentRequest];
    
    // currentRequest is bad don't continue
    if(actionString == nil )
    {
        return;
    }
    
    NSInteger currentAction = [actionString integerValue];
    
    //prepare to alert the user that there is an object in the door
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Object in Doorway"
                                                     message:@"You're garage door could not close because an object was detected in the doorway."
                                                    delegate:nil
                                           cancelButtonTitle:@"Okay"
                                           otherButtonTitles: nil];
    
    GD_MESSAGE_T message = [data integerValue];
    
    switch (currentAction) {
        case GD_CMD_TOGGLE: //just toggled the door
            if (self.doorOpened == GD_OPEN) { //open the door
                NSLog(@"Closing");
                //update the UI to reflect garage door state
                [self.garageDoor setSpeed:GD_SLOW];
                [self.garageDoor setOpened:0.0];
                [self.toggleButton.titleLabel setText:@"Open"];
                self.doorOpened = GD_CLOSED;
                
                //make sure the door really closed in case something ran under
                //the door
                NSTimer * checkTimer = [NSTimer timerWithTimeInterval:12
                                                               target:self
                                                             selector:@selector(checkState)
                                                             userInfo:nil repeats:NO];
                
                [[NSRunLoop mainRunLoop] addTimer:checkTimer
                                          forMode:NSDefaultRunLoopMode];
            }
            else if(self.doorOpened == GD_CLOSED) { //close the door
                NSLog(@"Opening");
                //update the UI to reflect the garage door state
                [self.garageDoor setSpeed:GD_SLOW];
                [self.garageDoor setOpened:1.0];
                [self.toggleButton.titleLabel setText:@"Close"];
                self.doorOpened = GD_OPEN;
                
                self.currentRequest = nil; //prepare for new request

            }
            else if(self.doorOpened == GD_PARTIAL) { //open the door
                NSLog(@"Opening");
                //update the UI to reflect the garage door state
                [self.garageDoor setSpeed:GD_SLOW];
                [self.garageDoor setOpened:1.0];
                [self.toggleButton.titleLabel setText:@"Close"];
                self.doorOpened = GD_OPEN;
                
                self.currentRequest = nil; //prepare for new request
            }
            break;
        case GD_CMD_QUERY: //just querried the door's state
            if (message == GD_OPEN) {
                NSLog(@"Open");
                //update the UI to reflect the new garage door state
                [self.garageDoor setSpeed:GD_FAST];
                [self.garageDoor setOpened:1.0];
                [self.toggleButton.titleLabel setText:@"Close"];
                
                self.currentRequest = nil; //prepare for new request
            }
            else if (message == GD_CLOSED) {
                NSLog(@"Closed");
                //update the UI to reflect the new garage door state
                [self.garageDoor setSpeed:GD_FAST];
                [self.garageDoor setOpened:0.0];
                [self.toggleButton.titleLabel setText:@"Open"];
                
                self.currentRequest = nil; //prepare for new request
            }
            else if (message == GD_PARTIAL) {
                NSLog(@"Partial");
                
                //[alert show];
                //update the UI to reflect the new garage door state

                [self.garageDoor setSpeed:GD_FAST];
                [self.garageDoor setOpened:0.5];
                [self.toggleButton.titleLabel setText:@"Open"];
                
                self.currentRequest = nil; //prepare for new request
            }
            self.doorOpened = message; //update door state property
            break;
        default:
            break;
    }
    
    NSLog(@"%d",self.doorOpened);
}

/**
 * @brief handles failed request response
 * @detail alerts the user when the app couldn't connect to base station
 * @param error string describing the error
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (void)requestReturnedWithError:(NSString *)error
{
    NSLog(@"%@",error);
    NSString * alertTitle = @"Connection Error";
    NSString * alertMessage = @"Could not connect to your base staton";
    
    //create the alert with two buttons: cancel and retry
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                     message:alertMessage
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Retry", nil];
    
    [alert show];
}

#pragma mark - Helper Methods
/**
 * @brief build a request dictionary
 * @detail builds a HRDeviceRequest with the given action and human message
 * @param action action message to send to base station
 * @param msg human readable message to send to base station
 * @return a dictionary containing the request
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (NSDictionary *)getRequestDictForAction:(NSInteger)action andHumanMessage:(NSString *)msg
{
    //write json data
    NSString * json = [NSString stringWithFormat:@"{\"HRDeviceRequest\":{\"DeviceID\":\"%@\",\"Password\":\"%@\",\"Type\":\"Str\",\"Data\":\"%d\",\"HumanMessage\":\"%@\"}}", self.deviceID, self.password, action, msg];
    
    NSError * error;
    
    //convert to dictionary
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
    return dict;
}

/**
 * @brief gets the value of a key
 * @detail searches the request for the desired key
 * @param key the key to search for
 * @param request the request that should contain the desired key
 * @return the string value of the key or "-1" if it is not found
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (NSString *)getValueForKey:(NSString *)key fromRequest:(NSDictionary *)request
{
    NSString * str;
    
    //get key from value
    @try {
        NSDictionary * reqDict = [request objectForKey:@"HRDeviceRequest"];
        str = [reqDict objectForKey:key];
    }
    @catch (NSException *exception) {
        //if it doesn't exist return "-1"
        NSLog(@"Error while parsing request");
        return @"-1";
    }
   
    return str;
}

#pragma mark - UIAlertViewDelegate Methods
/**
 * @brief handles alert view buttons
 * @detail handles button presses on the connection error alert. for retry, sends
 *         the current request again. for cancel, returns user to devices list
 * @param alertView the active alert view
 * @param buttonIndex the index of the button that was pressed
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) //if the user pressed the retry button
    {
        [self sendRequest:self.currentRequest]; //resend request
    }
    else //user pressed cancel button
    {
        //go back to devices list
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
