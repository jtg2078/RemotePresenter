//
//  MainViewController.m
//  RemotePresenter
//
//  Created by jason on 10/17/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import "MainViewController.h"
#import "PageViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

#pragma mark -synthesize

@synthesize myScrollView = _myScrollView;
@synthesize myPageControl = _myPageControl;
@synthesize pageArray = _pageArray;

#pragma mark - dealloc

- (void)dealloc
{
    [_myScrollView release];
    [_myPageControl release];
    [_pageArray release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupScrollView
{
    width = 320;
    height = 416;
    
    self.myScrollView.frame = CGRectMake(0, 0, width, height);
    self.myScrollView.pagingEnabled = YES;
    self.myScrollView.delegate = self;
    
    currentIndex = 0;
    int numPage = 6;
    self.myScrollView.contentSize = CGSizeMake(width * numPage, height);
    self.pageArray = [NSMutableArray arrayWithCapacity:numPage];
    
    for(int i = 0; i < numPage; i++)
    {
        PageViewController *pvc = [[PageViewController alloc] init];
        pvc.pageNumber = i + 1;
        pvc.view.frame = CGRectMake(i * width, 0, width, height);
        
        [self.myScrollView addSubview:pvc.view];
        [self.pageArray addObject:pvc];
        
        [pvc release];
    }
    
    self.myScrollView.showsHorizontalScrollIndicator = NO;

    self.myPageControl.numberOfPages = numPage;
    self.myPageControl.currentPage = currentIndex;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupScrollView];
    
    [self.manager openConnection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleChangePage)
                                                 name:@"ChangePageNotification"
                                               object:nil];
    
}

- (void)viewDidUnload
{
    [self setMyScrollView:nil];
    [self setMyPageControl:nil];
    [super viewDidUnload];
}

#pragma mark - main methods

- (void)handleChangePage
{
    int page = self.manager.currentPage - 1;
    CGRect rect = CGRectMake(page * width, 0, width, height);
    [self.myScrollView scrollRectToVisible:rect animated:YES];
    
    self.myPageControl.currentPage = page;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float potentialPage = scrollView.contentOffset.x / pageWidth;
    
    NSInteger page = lround(potentialPage);
    self.myPageControl.currentPage = page;
}

@end
