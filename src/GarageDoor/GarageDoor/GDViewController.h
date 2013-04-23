//
//  GDViewController.h
//  GarageDoor
//
//  Created by Joshua Kinkade on 10/11/12.
//  Copyright (c) 2012 Joshua Kinkade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GDGarageDoorView;

@interface GDViewController : UIViewController

@property (strong, nonatomic) IBOutlet GDGarageDoorView *garageDoor;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeUpRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeDownRecognizer;
@property (strong, nonatomic) IBOutlet UISwitch *toggle;


- (IBAction)toggleGarageDoor:(id)sender;
- (IBAction)swipeUp:(id)sender;
- (IBAction)swipeDown:(id)sender;
-(void)showObjectAlert;

@end
