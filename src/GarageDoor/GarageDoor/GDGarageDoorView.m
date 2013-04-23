//
//  GDGarageDoorView.m
//  GarageDoor
//
//  Created by Joshua Kinkade on 10/17/12.
//  Copyright (c) 2012 Joshua Kinkade. All rights reserved.
//

#import "GDGarageDoorView.h"

//@implementation PanelLayer
//
//-(void)drawInContext:(CGContextRef)ctx {
//    UIGraphicsPushContext(ctx);
//    
//    [[UIColor redColor] set];
//    
//    UIBezierPath * path = [UIBezierPath bezierPathWithRect:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height)];
//    
//    [path fill];
//    
//    UIGraphicsPopContext();
//}
//
//@end

@implementation GDGarageDoorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }

    return self;
}

-(void)awakeFromNib
{
    self.currentState = 0.0;
    self.direction = GD_UP;
    self.objectInDoor = NO;
}

-(CGFloat)opened {
    return _openedState;
}

-(void)setOpened:(CGFloat)openedState {
    _openedState = openedState;

    
    self.animationTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1.0/50 target:self selector:@selector(animationLoop:) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.animationTimer
                                 forMode:NSDefaultRunLoopMode];
}

-(void)animationLoop:(NSTimer *)timer {    
    if (self.currentState < self.opened && self.direction > 0) {
        self.currentState += .01;
    }
    else if (self.currentState > self.opened && self.direction < 0)
    {
//        if(self.objectInDoor)
//        {
//            self.currentState = .5;
//            [self.animationTimer invalidate];
//        }
//        else
//        {
//            self.currentState -= .01;
//        }
        self.currentState -= .01;
    }
    else
    {
        [self.animationTimer invalidate];
        
        if (self.opened == 1.0) {
            self.direction = GD_DOWN;
        }
        else if (self.opened == 0.0) {
            self.direction = GD_UP;
        }
    }

    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGFloat panelSpacing = 1.0;
    CGFloat panelWidth = rect.size.width-panelSpacing*2;
    CGFloat panelHeight = rect.size.height/3 - panelSpacing;
    CGFloat panelXPosition = rect.origin.x+panelSpacing;
    CGFloat topPanelYPostion = (rect.origin.y-rect.size.height*self.currentState)+panelSpacing;
    
    [[UIColor blackColor] set];
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:rect];
    
    [path fill];
    
    
    drawPanel(CGRectMake(panelXPosition, topPanelYPostion, panelWidth, panelHeight));
    
    drawPanel(CGRectMake(panelXPosition, topPanelYPostion + panelHeight + panelSpacing, panelWidth , panelHeight));
    
    drawPanel(CGRectMake(panelXPosition, topPanelYPostion + 2*panelHeight + 2*panelSpacing, panelWidth, panelHeight));
}

void drawPanel(CGRect rect)
{
    [[UIColor redColor] set];
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:rect];
    
    [path fill];
}

void drawX(CGRect rect)
{
    
}

@end
