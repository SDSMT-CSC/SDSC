//
//  GDViewController.m
//  GarageDoor
//
//  Created by Joshua Kinkade on 10/11/12.
//  Copyright (c) 2012 Joshua Kinkade. All rights reserved.
//

#import "GDViewController.h"
#import "GDGarageDoorView.h"

@interface GDViewController ()

@end

@implementation GDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleGarageDoor:(id)sender {
    if(self.garageDoor.direction == GD_UP)
    {
        self.garageDoor.opened = 1.0;
        //self.button.titleLabel.text = @"Close";
        [self.button setTitle:@"Close" forState:UIControlStateNormal];
    }
    else
    {
        if(self.toggle.on)
        {
            self.garageDoor.opened = 0.5;
            [self showObjectAlert];
        }
        else
        {
            self.garageDoor.opened = 0.0;
            [self.button setTitle:@"Open" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)swipeUp:(id)sender {
    NSLog(@"Swipe up");
    self.garageDoor.opened = 1.0;
    self.swipeUpRecognizer.enabled = NO;
    self.swipeDownRecognizer.enabled = YES;
    [self.button setTitle:@"Close" forState:UIControlStateNormal];
}

- (IBAction)swipeDown:(id)sender {
    NSLog(@"Swipe down");
    if(self.toggle.on)
    {
        self.garageDoor.opened = 0.5;
        [self showObjectAlert];
    }
    else
    {
        self.garageDoor.opened = 0.0;
    }
    self.swipeDownRecognizer.enabled = NO;
    self.swipeUpRecognizer.enabled = YES;
    [self.button setTitle:@"Open" forState:UIControlStateNormal];
}

- (void)showObjectAlert {
    NSString * title = @"Object Detected";
    NSString * message = @"An object has prevented the door from closing";
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
}
@end
