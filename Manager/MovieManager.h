//
//  MovieManager.h
//  RemotePresenter
//
//  Created by jason on 10/23/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "JSONKit.h"
#import "Constants.h"

typedef enum{
    PlaybackModePauseAtBegin = 0,
    PlaybackModePlay,
    PlaybackModePause,
}PlaybackMode;


@interface MovieManager : NSObject  <SRWebSocketDelegate>
{
    SRWebSocket *webSocket;
    JSONDecoder *decoder;
    NSRange notFound;
}

@property (assign, nonatomic) int currentMovieId;
@property (assign, nonatomic) NSTimeInterval currentMovieTimestamp;
@property (assign, nonatomic) PlaybackMode currentPlayMode;
@property (retain, nonatomic) NSArray *moviesArray;
@property (retain, nonatomic) NSDate *pingSentTime;
@property (retain, nonatomic) NSDate *pingReceivedTime;

+ (MovieManager *)sharedInstance;

- (void)openConnection;

- (void)updatePlaybackInfo:(int)videoId
                      time:(NSTimeInterval)playbackTime
                    action:(int)action;



@end
