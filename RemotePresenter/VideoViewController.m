//
//  VideoViewController.m
//  RemotePresenter
//
//  Created by jason on 10/22/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import "VideoViewController.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

#pragma mark - synthesize

@synthesize player = _player;
@synthesize myView = _myView;
@synthesize pvc = _pvc;

#pragma mark - dealloc

- (void)dealloc
{
    [_player release];
    [_myView release];
    [_pvc release];
    
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
        currentVideoId = -1;
    }
    return self;
}

- (void)setupPlayer
{
    /*
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent:@"/b_002.m4v"];
     */
    
    _pvc = [[PlaceholderViewController alloc] init];
    
    self.pvc.view.alpha = 1.0f;
    [self.view addSubview:self.pvc.view];
    
    _player = [[MPMoviePlayerController alloc] init];
    _player.shouldAutoplay = NO;
    _player.controlStyle = MPMovieControlStyleNone;
    [self.player.view setFrame: self.myView.bounds];  // player's frame must match parent's
    [self.myView addSubview: self.player.view];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation

{
    return YES;
    /*
    BOOL isLandscapeRight = (UIInterfaceOrientationLandscapeRight == interfaceOrientation);
    return isLandscapeRight;
     */
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSNotificationCenter *df = [NSNotificationCenter defaultCenter];
    [df addObserver:self
           selector:@selector(handlePlaybackInfo:)
               name:@"PlaybackInfoNotification"
             object:nil];
    
    [df addObserver:self
           selector:@selector(handleMovieFinished:) name:@"MPMoviePlayerPlaybackDidFinishNotification"
             object:nil];
    
    [self setupPlayer];
}

- (void)viewDidUnload
{
    [self setMyView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

#pragma mark - main methods

- (void)playMovie
{
    if(self.movieManager.currentPlayMode == MPMoviePlaybackStateStopped)
    {
        [self.player stop];
        return;
    }
    
    // play the movie
    if (currentVideoId != self.movieManager.currentMovieId)
    {        
        NSString *movieName = [self.movieManager.moviesArray objectAtIndex:self.movieManager.currentMovieId];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"m4v"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        self.player.contentURL = fileURL;
        
        [self.player prepareToPlay];
        
        currentVideoId = self.movieManager.currentMovieId;
    }
    
    self.player.currentPlaybackTime = self.movieManager.currentMovieTimestamp;
    
    if(self.movieManager.currentPlayMode == MPMoviePlaybackStatePlaying)
    {
        [self.player play];
    }
    else if(self.movieManager.currentPlayMode == MPMoviePlaybackStatePaused)
    {
        [self.player pause];
    }
}

- (void)handlePlaybackInfo:(NSNotification *)notif
{
    [self playMovie];
}

- (void)handleMovieFinished:(NSNotification *)notif
{
    [self.player stop];
}

- (void)showPlaceHolderFor:(NSTimeInterval)duration
{
    /*
    self.pvc.view.alpha = 0.8f;
    [UIView transitionWithView:self.pvc.view
                      duration:0.1
                       options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
        
    } completion:^(BOOL finished) {
        
        [UIView transitionWithView:self.pvc.view
                          duration:0.6
                           options:UIViewAnimationOptionBeginFromCurrentState
                        animations:^{
                            self.pvc.view.alpha = 0.0f;
                        } completion:nil];
    }];
  */
}

@end
