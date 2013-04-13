/**
 * @brief  Class that draws a garage door on the screen
 * @detail Draws a garage door on the screen and animates it when it's state
 *         changes
 * @author Joshua Kinkade
 * @date April 13, 2013
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 * The possible states for the garage door view
 */
enum {
    GD_DOWN = -1,
    GD_UP = 1,
    GD_STOPPED = 0
    } typedef GD_Direction;

/**s
 * Speeds the garage door can move at
 */
enum {
    GD_FAST = 100, //used for background state changes
    GD_SLOW = 20 //used for user initiated state changes
} typedef GD_Speed;

@interface RHGarageDoorView : UIView {
    CGFloat _openedState;
}

//position of the door
//@property CGFloat position;
//how much the door is opened
@property CGFloat opened;
//the direction the door should move
@property GD_Direction direction;
//the current state of the door
@property CGFloat currentState;
//if there is an object in the door
@property BOOL objectInDoor;
//how fast the door should move
@property GD_Speed speed;

//timer to control animation
@property (nonatomic, strong) NSTimer * animationTimer;

//does the animation
-(void)animationLoop:(NSTimer *)timer;

@end
