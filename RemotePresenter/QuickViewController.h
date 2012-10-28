//
//  QuickViewController.h
//  RemotePresenter
//
//  Created by jason on 10/23/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BaseViewController.h"

@interface QuickViewController : BaseViewController <UISplitViewControllerDelegate>
{
    int videoId;
}

@property (nonatomic, retain) MPMoviePlayerController *player;
@property (retain, nonatomic) NSTimer *timer1;

- (void)playMovie:(NSString *)movieName movieId:(int)movieId;

@end
