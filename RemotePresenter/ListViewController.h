//
//  ListViewController.h
//  RemotePresenter
//
//  Created by jason on 10/23/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieManager.h"
#import "QuickViewController.h"

@interface ListViewController : UITableViewController
{
    MovieManager *movieManager;
    int lastSelectedRow;
}

@property (nonatomic, assign) QuickViewController *qvc;

@end
