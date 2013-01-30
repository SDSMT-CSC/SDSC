//
//  RHViewController.h
//  RHGarageDoorVC
//
//  Created by Joshua Kinkade on 1/17/13.
//  Copyright (c) 2013 Joshua Kinkade. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHViewController : UIViewController

@property BOOL doorOpened;
@property BOOL objectDetected;

@property (strong, nonatomic) NSString * deviceID;
@property (strong, nonatomic) IBOutlet UIButton *toggleButton;

- (IBAction)toggleDoor:(id)sender;

- (void)requestReturnedData:(NSDictionary *)data;
- (void)requestReturnedError:(NSString *)error;

@end
