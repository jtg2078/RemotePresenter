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
    _player = [[MPMoviePlayerController alloc] init];
    _player.controlStyle = MPMovieControlStyleEmbedded;
    //_player.view.frame = CGRectMake(100, 100, 500, 500);
    _player.view.frame = CGRectMake(10, 10, 1024 - 320 - 20, 768 - 20 - 44 - 20);
    _player.shouldAutoplay = NO;
    /*
    UIView *bg = [[[UIView alloc] init] autorelease];
    bg.frame = CGRectMake(0, 0, 100, 100);
    bg.backgroundColor = [UIColor yellowColor];
    [_player.backgroundView addSubview:bg];
     */
    
    
    
    [self.view addSubview: _player.view];
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

/*
 2012-10-24 12:29:05.098 RemotePresenter[257:707] did failed
 2012-10-24 12:29:08.357 RemotePresenter[257:707] player load state changed: 3
 2012-10-24 12:29:14.088 RemotePresenter[257:707] playback state changed: 1
 2012-10-24 12:29:17.511 RemotePresenter[257:707] playback state changed: 2
 2012-10-24 12:29:19.189 RemotePresenter[257:707] playback state changed: 1
 2012-10-24 12:29:22.924 RemotePresenter[257:707] playback state changed: 0
 2012-10-24 12:29:22.929 RemotePresenter[257:707] player load state changed: 0
 2012-10-24 12:29:22.948 RemotePresenter[257:707] playback finished
 2012-10-24 12:29:23.173 RemotePresenter[257:707] player load state changed: 3
 2012-10-24 12:29:29.284 RemotePresenter[257:707] playback state changed: 1
 2012-10-24 12:29:31.265 RemotePresenter[257:707] playback state changed: 0
 2012-10-24 12:29:31.276 RemotePresenter[257:707] player load state changed: 0
 2012-10-24 12:29:31.294 RemotePresenter[257:707] playback finished
 2012-10-24 12:29:31.513 RemotePresenter[257:707] player load state changed: 3
 2012-10-24 12:29:49.791 RemotePresenter[257:707] playback state changed: 1
 2012-10-24 12:29:52.030 RemotePresenter[257:707] playback state changed: 0
 2012-10-24 12:29:52.038 RemotePresenter[257:707] player load state changed: 0
 2012-10-24 12:29:52.058 RemotePresenter[257:707] playback finished
 2012-10-24 12:29:52.280 RemotePresenter[257:707] player load state changed: 3
 */

 /*
 enum {
 MPMovieLoadStateUnknown        = 0,
 MPMovieLoadStatePlayable       = 1 << 0,
 MPMovieLoadStatePlaythroughOK  = 1 << 1,
 MPMovieLoadStateStalled        = 1 << 2,
 };
 */
- (void)loadStateChanged:(NSNotification *)notif
{
    NSLog(@"player load state changed: %d", self.player.loadState);
}

/*
 enum {
 MPMoviePlaybackStateStopped,
 MPMoviePlaybackStatePlaying,
 MPMoviePlaybackStatePaused,
 MPMoviePlaybackStateInterrupted,
 MPMoviePlaybackStateSeekingForward,
 MPMoviePlaybackStateSeekingBackward
 };
 */
- (void)playbackStateChanged:(NSNotification *)notif
{
    NSLog(@"playback state changed: %d time:%f",
          self.player.playbackState,
          self.player.currentPlaybackTime);
    
    int movieId = videoId;
    NSTimeInterval currentTime = self.player.currentPlaybackTime;
    int action = self.player.playbackState;
    
    [self.movieManager updatePlaybackInfo:movieId time:currentTime action:action];
}

/*
 enum {
 MPMovieFinishReasonPlaybackEnded,
 MPMovieFinishReasonPlaybackError,
 MPMovieFinishReasonUserExited
 };
 */
- (void)playbackDidFinish:(NSNotification *)notif
{
    NSLog(@"playback finished");
}

#pragma mark - main methods

- (void)playMovie:(NSString *)movieName movieId:(int)movieId
{
    // play the movie
    NSString *filePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"m4v"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    self.player.contentURL = fileURL;
    
    [self.player prepareToPlay];
    
    videoId = movieId;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupPlayer];
    [self setupNotification];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
