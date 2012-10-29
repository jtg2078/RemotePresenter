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
@synthesize imageView = _imageView;

#pragma mark - dealloc

- (void)dealloc
{
    [_player release];
    [_myView release];
    [_pvc release];
    [_imageView release];
    
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
    
    _pvc = [[PlaceholderViewController alloc] init];
    
    //self.pvc.view.alpha = 1.0f;
    //[self.view addSubview:self.pvc.view];
    
    _player = [[MPMoviePlayerController alloc] init];
    _player.shouldAutoplay = NO;
    _player.controlStyle = MPMovieControlStyleNone;
    _player.fullscreen = NO;
    _player.view.frame = self.myView.bounds;
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intermission.jpg"]];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.frame = _player.view.bounds;
    
    [_player.view addSubview:_imageView];
    
    [self.myView addSubview:self.player.view];
}

- (void)viewDidUnload
{
    [self setMyView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - main methods

- (void)playerStopOrPlay:(PlayerControl)control animated:(BOOL)animated
{
    NSLog(@"playerStopOrPlay called with mode %d", control);
    
    float alpha = 0.0f;
    if(control == PlayerControlPlay)
    {
        alpha = 0.0f;
        [self.player play];
    }
    else if(control == PlayerControlStop)
    {
        alpha = 1.0f;
        [self.player stop];
    }
    
    if(animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut;
        
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:options
                         animations:^{
                             self.imageView.alpha = alpha;
                         }
                         completion:^(BOOL finished) {
                             self.imageView.alpha = alpha;
                         }];
    }
    else
    {
        self.imageView.alpha = alpha;
    }
}

- (void)playPlayerAnimated_old:(BOOL)animated
{
    [self.player play];
    
    if(animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut;
        
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:options
                         animations:^{
                             self.imageView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             self.imageView.alpha = 0.0f;
                         }];
    }
    else
    {
        self.imageView.alpha = 0.0f;
    }
}

- (void)stopPlayerAnimated_old:(BOOL)animated
{
    [self.player stop];
    
    if(animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut;
        
        [UIView animateWithDuration:1.0f
                              delay:0.0f
                            options:options
                         animations:^{
                             self.imageView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             self.imageView.alpha = 1.0f;
                         }];
    }
    else
    {
        self.imageView.alpha = 1.0f;
    }
}

- (void)updatePlayer
{
    if(self.movieManager.currentPlayMode == MPMoviePlaybackStateStopped)
    {
        [self playerStopOrPlay:PlayerControlStop animated:YES];
        return;
    }
    
    // load the movie into memory
    if (currentVideoId != self.movieManager.currentMovieId)
    {        
        NSString *movieName = [self.movieManager.moviesArray objectAtIndex:self.movieManager.currentMovieId];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"m4v"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        self.player.contentURL = fileURL;
        
        [self.player prepareToPlay];
        
        currentVideoId = self.movieManager.currentMovieId;
    }
    
    NSLog(@"duration time is: %f, time from manager is: %f mode is:%d", self.player.playableDuration, self.movieManager.currentMovieTimestamp, self.movieManager.currentPlayMode);
    
    if(self.player.playableDuration > self.movieManager.currentMovieTimestamp)
        self.player.currentPlaybackTime = self.movieManager.currentMovieTimestamp;
    
    if(self.movieManager.currentPlayMode == MPMoviePlaybackStatePlaying)
    {
        //[self.player play];
        [self playerStopOrPlay:PlayerControlPlay animated:YES];
    }
    else if(self.movieManager.currentPlayMode == MPMoviePlaybackStatePaused)
    {
        [self.player pause];
    }
}

- (void)handlePlaybackInfo:(NSNotification *)notif
{
    [self updatePlayer];
}

- (void)handleMovieFinished:(NSNotification *)notif
{
    //[self.player stop];
    //NSNumber *reason = [notif.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    //BOOL finishedNaturally = (reason.intValue == MPMovieFinishReasonPlaybackEnded);
    [self playerStopOrPlay:PlayerControlStop animated:YES];
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
