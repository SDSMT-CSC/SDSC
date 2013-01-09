//
//  RHBaseStationTableViewController.h
//  RemoteHome
//
//  Created by James Wiegand on 1/3/13.
//  Copyright (c) 2013 James Wiegand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RHBaseStationTableViewController : UITableViewController
<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    NSMutableArray *dataSource;
}

@property (nonatomic) int selectedIndex;
@end
