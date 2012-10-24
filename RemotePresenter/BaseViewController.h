//
//  BaseViewController.h
//  RemotePresenter
//
//  Created by jason on 10/17/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteManager.h"
#import "MovieManager.h"

@interface BaseViewController : UIViewController
{
    
}

@property (nonatomic, assign) RemoteManager *manager;
@property (nonatomic, assign) MovieManager *movieManager;

@end
