//
//  GDAppDelegate.h
//  GarageDoor
//
//  Created by Joshua Kinkade on 10/11/12.
//  Copyright (c) 2012 Joshua Kinkade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GDViewController;

@interface GDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GDViewController *viewController;

@end
