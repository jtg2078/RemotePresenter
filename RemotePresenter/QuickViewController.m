//
//  QuickViewController.m
//  RemotePresenter
//
//  Created by jason on 10/23/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import "QuickViewController.h"

@interface QuickViewController ()

@end

@implementation QuickViewController

#pragma mark - synthesize

@synthesize timer1 = _timer1;
@synthesize player = _player;

#pragma mark - dealloc

- (void)dealloc
{
    [_player release];
    [super dealloc];
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

- (void)setupPlayer
{
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intermission.jpg"]] autorelease];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame = CGRectMake(10, 10, 1024 - 320 - 20, 768 - 20 - 44 - 20);
    
    [self.view addSubview:imgView];
    
    _player = [[MPMoviePlayerController alloc] init];
    _player.controlStyle = MPMovieControlStyleEmbedded;
    _player.view.frame = CGRectMake(10, 10, 1024 - 320 - 20, 768 - 20 - 44 - 20);
    _player.shouldAutoplay = NO;
    
    [self.view addSubview: _player.view];
    self.player.view.hidden = YES;
}

- (void)setupNotification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(loadStateChanged:)
                   name:MPMoviePlayerLoadStateDidChangeNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(playbackStateChanged:)
                   name:MPMoviePlayerPlaybackStateDidChangeNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(playbackDidFinish:)
                   name:MPMoviePlayerPlaybackDidFinishNotification
                 object:nil];
}

#pragma mark - handling playback notification

- (void)loadStateChanged:(NSNotification *)notif
{
    NSLog(@"player load state changed: %d", self.player.loadState);
}

- (void)playbackStateChanged:(NSNotification *)notif
{
    NSLog(@"playback state changed: %d time:%f",
          self.player.playbackState,
          self.player.currentPlaybackTime);
    
    int movieId = videoId;
    NSTimeInterval currentTime = self.player.currentPlaybackTime;
    int action = self.player.playbackState;
    
    if(willResignActive == NO)
        [self.movieManager updatePlaybackInfo:movieId time:currentTime action:action];
}

- (void)playbackDidFinish:(NSNotification *)notif
{
    /*
    int movieId = videoId;
    NSTimeInterval currentTime = self.player.currentPlaybackTime;
    int action = MPMoviePlaybackStateStopped;
    
    [self.movieManager updatePlaybackInfo:movieId time:currentTime action:action];
     */
    
    NSLog(@"playback finished");
}

- (void)updatePlaybackTime
{
    NSTimeInterval currentTime = self.player.currentPlaybackTime;
    if (!isnan(currentTime))
        self.movieManager.currentMovieTimestamp = currentTime;
}

#pragma mark - main methods

- (void)playMovie:(NSString *)movieName movieId:(int)movieId
{
    if(self.player.view.hidden == YES)
        self.player.view.hidden = NO;
    
    // play the movie
    NSString *filePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"m4v"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    self.player.contentURL = fileURL;
    
    [self.player prepareToPlay];
    
    videoId = movieId;
    NSString *name = [self.movieManager.namesArray objectAtIndex:movieId];
    NSString *str = [NSString stringWithFormat:@"%d. %@", movieId + 1, name];
    self.title = str;
    [self.player play];
}

- (void)manualSync
{
    int movieId = videoId;
    NSTimeInterval currentTime = self.player.currentPlaybackTime;
    int action = self.player.playbackState;
    
    [self.movieManager updatePlaybackInfo:movieId time:currentTime action:action];
}

- (void)showLogo
{
    int movieId = videoId;
    NSTimeInterval currentTime = self.player.currentPlaybackTime;
    int action = MPMoviePlaybackStateStopped;
    
    [self.movieManager updatePlaybackInfo:movieId time:currentTime action:action];
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    [self setupPlayer];
    [self setupNotification];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"手動同步", nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(manualSync)];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"顯示logo", nil)
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(showLogo)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.timer1 = [NSTimer timerWithTimeInterval:1.0
                                          target:self
                                        selector:@selector(updatePlaybackTime)
                                        userInfo:nil
                                         repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer1 forMode:NSDefaultRunLoopMode];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.timer1 invalidate];
    self.timer1 = nil;
    
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    willResignActive = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    willResignActive = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//BOOL isLandscapeRight = (UIInterfaceOrientationLandscapeRight == interfaceOrientation);
    //return isLandscapeRight;
    return YES;
}

#pragma mark UISplitViewControllerDelegate

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
}

- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
}

@end
