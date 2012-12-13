//
//  GDGarageDoorView.h
//  GarageDoor
//
//  Created by Joshua Kinkade on 10/17/12.
//  Copyright (c) 2012 Joshua Kinkade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//@interface PanelLayer : CALayer
//
//@end

enum {
    GD_DOWN = -1,
    GD_UP = 1,
    GD_STOPPED = 0
    } typedef GD_Direction;

@interface GDGarageDoorView : UIView {
    CGFloat _openedState;
}

@property CGFloat position;
@property CGFloat opened;
@property GD_Direction direction;
@property CGFloat currentState;
@property BOOL objectInDoor;


@property (nonatomic, strong) NSTimer * animationTimer;

-(void)animationLoop:(NSTimer *)timer;

@end
