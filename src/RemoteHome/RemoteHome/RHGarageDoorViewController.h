//
//  RHViewController.h
//  RHGarageDoorVC
//
//  Created by Joshua Kinkade on 1/17/13.
//  Copyright (c) 2013 Joshua Kinkade. All rights reserved.
//

#import <UIKit/UIKit.h>


enum {
    GD_CMD_TOGGLE = 0,
    GD_CMD_QUERY
} typedef GD_MESSAGE_T;

enum {
    GD_OPEN = 0,
    GD_OPENING,
    GD_CLOSED,
    GD_CLOSING,
    GD_PARTIAL
} typedef  GD_STATE_T;

@class RHGarageDoorView;

@interface RHGarageDoorViewController : UIViewController <UIAlertViewDelegate>
@property GD_STATE_T doorOpened;
@property BOOL objectDetected;
@property (strong, nonatomic) NSDictionary * currentRequest;
@property (strong, nonatomic) NSString * deviceID;
@property (strong, nonatomic) NSString * baseStationAddress;
@property (strong, nonatomic) NSString * password;
@property (strong, nonatomic) NSTimer * stateChecker;

@property (strong, nonatomic) IBOutlet UIButton *toggleButton;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *upSwipeRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *downSwipeRecognizer;
@property (strong, nonatomic) IBOutlet RHGarageDoorView *garageDoor;

- (IBAction)toggleDoor:(id)sender;

- (void)checkState;
- (void)confirmDoorClosed;

- (void)sendRequest:(NSDictionary *) request;

- (void)requestReturnedWithData:(NSDictionary *)data;
- (void)requestReturnedWithError:(NSString *)error;

@end
