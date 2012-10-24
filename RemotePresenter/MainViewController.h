//
//  MainViewController.h
//  RemotePresenter
//
//  Created by jason on 10/17/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MainViewController : BaseViewController <UIScrollViewDelegate>
{
    int currentIndex;
    int width;
    int height;
}

@property (retain, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *myPageControl;
@property (retain, nonatomic) NSMutableArray *pageArray;

- (void)setupScrollView;

@end
