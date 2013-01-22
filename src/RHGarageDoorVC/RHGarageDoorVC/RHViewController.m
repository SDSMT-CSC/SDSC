//
//  RHViewController.m
//  RHGarageDoorVC
//
//  Created by Joshua Kinkade on 1/17/13.
//  Copyright (c) 2013 Joshua Kinkade. All rights reserved.
//

#import "RHViewController.h"
#import "RHNetworkEngine.h"

@interface RHViewController ()

@end

@implementation RHViewController

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

- (IBAction)open:(id)sender {
    NSString * data = [NSString stringWithFormat:@"{\"HRGarageDoorAction\":[{\"Action\":\"open\"}]}"];
    
    NSLog(@"%@", data);
}
@end
