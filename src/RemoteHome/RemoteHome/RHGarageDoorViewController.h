//
//  RHViewController.h
//  RHGarageDoorVC
//
//  Created by Joshua Kinkade on 1/17/13.
//  Copyright (c) 2013 Joshua Kinkade. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Set of message values which can be passed to the garage door hardware, as
 * somewhat more human-readable.
 */
//enum
//{
//    /** @brief Not Acknowledged. Serial equivalent of logical false. */
//    NAK=0,
//    /** @brief Acknowledged. Used for handshakes and logical true. */
//    ACK,
//    /** @brief Open the door and respond false if it's not open. */
//    OPEN,
//    /** @brief */
//    CLOSE,
//    /** @brief Query the door state; return ACK if open and NAK if closed. */
//    IS_OPEN,
//    /** @brief Query the door state; return ACK if closed and NAK if open. */
//    IS_CLOSED,
//    /** @brief Open the door and return ACK when open. */
//    OPEN_IF_CLOSED,
//    /** @brief Close the door and return ACK when closed, NAK iff error. */
//    CLOSE_IF_OPEN,
//    /** @brief Number of messages which can be passed to a garage door. This
//     * should *ALWAYS* be the very last element, so if more messages are added,
//     * they get added before this message. Note that you should NOT pass this
//     * message to the hardware. */
//    GD_MESSAGE_COUNT
//} typedef GD_MESSAGE_T;

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
@property (strong, nonatomic) NSTimer * stateChecker;

@property (strong, nonatomic) IBOutlet UIButton *toggleButton;
@property (strong, nonatomic) IBOutlet RHGarageDoorView *garageDoor;

- (IBAction)toggleDoor:(id)sender;

- (void)checkState;
- (void)confirmDoorClosed;

- (void)sendRequest:(NSDictionary *) request;

- (void)requestReturnedWithData:(NSDictionary *)data;
- (void)requestReturnedWithError:(NSString *)error;

@end
