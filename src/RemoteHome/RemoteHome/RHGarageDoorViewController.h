/**
 * @brief The class that handles the garage door controller
 * @detail RHGarageDoorViewController sends commands and queries to the base station 
 *         using the network engine and recieves responses from the base station
 *         and keeps the user interface in sync with the physical garage door.
 * @author Joshua Kinkade
 * @date April 13, 2013
 */

#import <UIKit/UIKit.h>

/**
 * Enum that defines the different actions that the garage door is capable of responding to.
 */
enum {
    GD_CMD_TOGGLE = 0,
    GD_CMD_QUERY
} typedef GD_MESSAGE_T;

/**
 * Enum that defines the possible states of the garage door.
 */
enum {
    GD_OPEN = 0,
    GD_OPENING,
    GD_CLOSED,
    GD_CLOSING,
    GD_PARTIAL
} typedef  GD_STATE_T;

@class RHGarageDoorView;

@interface RHGarageDoorViewController : UIViewController <UIAlertViewDelegate>
@property GD_STATE_T doorOpened; //the state of the door
//@property BOOL objectDetected;

//request that the view controller is waiting for a response for
@property (strong, nonatomic) NSDictionary * currentRequest;

//id of the garage door being controlled
@property (strong, nonatomic) NSString * deviceID;

//ip address of the current base station 
@property (strong, nonatomic) NSString * baseStationAddress;

//password of the current base station
@property (strong, nonatomic) NSString * password;

//timer to get the state of the door periodically
@property (strong, nonatomic) NSTimer * stateChecker;

//button to toggle garage door
@property (strong, nonatomic) IBOutlet UIButton *toggleButton;

//swipe up to open the door
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *upSwipeRecognizer;

//swipe down to close the door
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *downSwipeRecognizer;

//garage door picture
@property (strong, nonatomic) IBOutlet RHGarageDoorView *garageDoor;

//toggle the door
- (IBAction)toggleDoor:(id)sender;

//get the state of the door
- (void)checkState;
- (void)confirmDoorClosed;

//send the request to the base station
- (void)sendRequest:(NSDictionary *) request;

//handle a successful connection
- (void)requestReturnedWithData:(NSDictionary *)data;

//handle a failed connection
- (void)requestReturnedWithError:(NSString *)error;

@end
