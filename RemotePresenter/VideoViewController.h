//
//  VideoViewController.h
//  RemotePresenter
//
//  Created by jason on 10/22/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BaseViewController.h"
#import "PlaceholderViewController.h"

@interface VideoViewController : BaseViewController
{
    int currentVideoId;
}

@property (nonatomic, retain) MPMoviePlayerController *player;
@property (nonatomic, retain) PlaceholderViewController *pvc;
@property (retain, nonatomic) IBOutlet UIView *myView;

@end
