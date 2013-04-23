//
//  GDGarageDoorView.m
//  GarageDoor
//
//  Created by Joshua Kinkade on 10/17/12.
//  Copyright (c) 2012 Joshua Kinkade. All rights reserved.
//

#import "RHGarageDoorView.h"

@implementation RHGarageDoorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }

    return self;
}

/**
 * @brief initializes view
 * @detail sets the intial state of the door and its properties
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
-(void)awakeFromNib
{
    self.currentState = 0.0;
    self.direction = GD_UP;
    self.objectInDoor = NO;
    self.speed = GD_SLOW;
}

/**
 * @brief returns how much the door view is opened
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
-(CGFloat)opened {
    return _openedState;
}

/**
 * @brief sets how much the door is opened
 * @detail sets how much the door is opened and starts animation to make it
 *         transition smoothly between states
 * @param openedState the amount the door should be open
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
-(void)setOpened:(CGFloat)openedState {
    _openedState = openedState; //set property

    //create timer
    self.animationTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                   interval:1.0/self.speed
                                                     target:self
                                                   selector:@selector(animationLoop:)
                                                   userInfo:nil
                                                    repeats:YES];
    
    //start timer
    [[NSRunLoop currentRunLoop] addTimer:self.animationTimer
                                 forMode:NSDefaultRunLoopMode];
}

/**
 * @brief animates state changes
 * @detail smoothly transitions the door from one state to another when it needs
 *         to be redrawn so it looks like it is opening
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
-(void)animationLoop:(NSTimer *)timer {
    //if the door is not open and the direction is up
    if (self.currentState < self.opened && self.direction > 0) {
        self.currentState += .01; //move it up a little
    }
    //if the door is open and direction is down
    else if (self.currentState > self.opened && self.direction < 0)
    {
        self.currentState -= .01; //move it down a little
    }
    else //if the door is where it should be
    {
        [self.animationTimer invalidate]; //cancel timer
        
        //update direction to new value
        if (self.opened == 1.0) {
            self.direction = GD_DOWN;
        }
        else if (self.opened == 0.0) {
            self.direction = GD_UP;
        }
    }

    [self setNeedsDisplay]; //redraw the door
}

/**
 * @brief draws the door
 * @detail draws a bright red thre panel garage door on a black backround
 * @param rect the rectangle in the superview to draw in
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
- (void)drawRect:(CGRect)rect
{
    CGFloat panelSpacing = 1.0; //space between panels
    CGFloat panelWidth = rect.size.width-panelSpacing*2; //width of panels
    CGFloat panelHeight = rect.size.height/3 - panelSpacing; //Height of panels
    CGFloat panelXPosition = rect.origin.x+panelSpacing; // horizontal position of door
    CGFloat topPanelYPostion = (rect.origin.y-rect.size.height*self.currentState)+panelSpacing; //current vertical postion of the top panel
    
    //make the background black
    [[UIColor blackColor] set];
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:rect];
    [path fill];
    
    //draw the panels
    drawPanel(CGRectMake(panelXPosition, topPanelYPostion, panelWidth, panelHeight));
    
    drawPanel(CGRectMake(panelXPosition, topPanelYPostion + panelHeight + panelSpacing, panelWidth , panelHeight));
    
    drawPanel(CGRectMake(panelXPosition, topPanelYPostion + 2*panelHeight + 2*panelSpacing, panelWidth, panelHeight));
}

/**
 * @brief draws a panel
 * @detail draws a panel in the given rect
 * @param rect the rectangle to draw in
 * @author Joshua Kinkade
 * @date April 13, 2013
 */
void drawPanel(CGRect rect)
{
    [[UIColor redColor] set]; //use red color
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:rect]; //draw path
    
    [path fill]; //fill path with red
}

@end
