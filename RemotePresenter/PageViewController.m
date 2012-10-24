//
//  PageViewController.m
//  RemotePresenter
//
//  Created by jason on 10/17/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()

@end

@implementation PageViewController

@synthesize pageNumber = _pageNumber;
@synthesize numberLabel = _numberLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.numberLabel.text = [NSString stringWithFormat:@"%d", self.pageNumber];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_numberLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setNumberLabel:nil];
    [super viewDidUnload];
}
@end
