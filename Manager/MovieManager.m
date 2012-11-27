//
//  MovieManager.m
//  RemotePresenter
//
//  Created by jason on 10/23/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import "MovieManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation MovieManager

#pragma mark - synthesize

@synthesize currentMovieId = _currentMovieId;
@synthesize currentMovieTimestamp = _currentMovieTimestamp;
@synthesize currentPlayMode = _currentPlayMode;
@synthesize moviesArray = _moviesArray;
@synthesize namesArray = _namesArray;
@synthesize pingSentTime = _pingSentTime;
@synthesize pingReceivedTime = _pingReceivedTime;
@synthesize timer1 = _timer1;
@synthesize timer2 = _timer2;

#pragma mark - dealloc

- (void)dealloc
{
    [webSocket release];
    [decoder release];
    [_moviesArray release];
    [_pingSentTime release];
    [_pingReceivedTime release];
    [_namesArray release];
    [super dealloc];
}

#pragma mark - init and setup

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setupPlayer
{
    NSString *urlString = nil;
    if(IS_USING_WILL)
    {
        NSString *uuid = [[UIDevice currentDevice] uniqueIdentifier];
        
        if(IS_USING_LOCAL)
            urlString = [NSString stringWithFormat:@"ws://192.168.77.77/sync.ashx?username=%@", uuid];
        else
            urlString = [NSString stringWithFormat:@"ws://61.62.220.19:60080/WebSockets/chat.ashx?username=%@", uuid];
    }
    else
    {
        urlString = @"ws://ec2-54-242-8-110.compute-1.amazonaws.com:8080/ws/connect";
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    webSocket.delegate = self;
}

- (void)setup
{
    [self setupPlayer];
    
    // register for application start up
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(appBecameActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(appWillResignActive:)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    
    
    // playback stuff
    
    self.moviesArray = [NSArray arrayWithObjects:
                        @"1",
                        @"2",
                        @"3",
                        @"4",
                        @"5",
                        @"6",
                        @"7",
                        nil];
    self.namesArray = [NSArray arrayWithObjects:
                       @"調酒工藝背景",
                       @"厚實果香風味",
                       @"強烈的煙燻香氣",
                       @"Odyssey影片介紹",
                       @"香草、巧克力、太妃糖",
                       @"葡萄乾果與葡萄酒",
                       @"海島特色煙燻，鮮明的泥煤與海潮風",
                       nil];
    
    // misc
    decoder = [[JSONDecoder decoder] retain];
    notFound = NSMakeRange(NSNotFound, 0);
    self.pingReceivedTime = [NSDate date];
    
    //add photo to photo library
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    BOOL photoInstalled = [df boolForKey:@"photoInstalled"];
    if(photoInstalled == NO)
    {
        ALAssetsLibrary* library = [[[ALAssetsLibrary alloc] init] autorelease];
        
        UIImage *photo = [UIImage imageNamed:@"cover.png"];
        [library writeImageToSavedPhotosAlbum:photo.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
            if(error)
                NSLog(@"failed to save the image");
            else
            {
                NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
                [df setBool:YES forKey:@"photoInstalled"];
                [df synchronize];
            }
        }];
        
    }
}

#pragma mark - main methods

- (void)openConnection
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [webSocket open];
}

- (void)updatePlaybackInfo:(int)videoId
                      time:(NSTimeInterval)playbackTime
                    action:(int)action
{
    self.currentMovieId = videoId;
    self.currentMovieTimestamp = playbackTime;
    self.currentPlayMode = action;
    
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setObject:@"change" forKey:@"type"];
    
    NSMutableDictionary *detail = [NSMutableDictionary dictionary];
    [detail setObject:[NSNumber numberWithInt:videoId]      forKey:@"videoId"];
    [detail setObject:[NSNumber numberWithDouble:playbackTime] forKey:@"timestamp"];
    [detail setObject:[NSNumber numberWithInt:action]       forKey:@"action"];
    
    [p setObject:detail forKey:@"detail"];
    
    if(IS_USING_WILL)
    {
        NSString *jsonString = [p JSONString];
        [webSocket send:jsonString];
    }
    else
    {
        NSData *jsonData =[p JSONData];
        [webSocket send:jsonData];
    }
}

- (void)login
{
    NSString *uuid = [[UIDevice currentDevice] uniqueIdentifier];
    
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setObject:@"login" forKey:@"type"];
    
    NSMutableDictionary *detail = [NSMutableDictionary dictionary];
    [detail setObject:uuid forKey:@"id"];
    
    if(IS_TEACHER_MODE)
        [detail setObject:@"teacher" forKey:@"type"];
    else
        [detail setObject:@"student" forKey:@"type"];
    
    [p setObject:detail forKey:@"detail"];
    
    
    if(IS_USING_WILL)
    {
        NSString *jsonString = [p JSONString];
        [webSocket send:jsonString];
    }
    else
    {
        NSData *jsonData =[p JSONData];
        [webSocket send:jsonData];
    }
}

- (void)queryPlayback
{
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setObject:@"inqury" forKey:@"type"];
    [p setObject:[NSDictionary dictionary] forKey:@"detail"];
    
    if(IS_USING_WILL)
    {
        NSString *jsonString = [p JSONString];
        [webSocket send:jsonString];
    }
    else
    {
        NSData *jsonData =[p JSONData];
        [webSocket send:jsonData];
    }
    
    self.pingSentTime = [NSDate date];
}

- (void)isAlive
{
    NSTimeInterval time = [self.pingReceivedTime timeIntervalSinceDate:[NSDate date]];
    int diff = abs(time);
    if( diff > 3)
    {
        webSocket.delegate = nil;
        [webSocket close];
        [webSocket release];
        
        [self setupPlayer];
        [webSocket open];
        
        self.pingReceivedTime = [NSDate date];
    }
    NSLog(@"ping diff time: %d", abs(time));
}

- (void)sendPing
{
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setObject:@"ping" forKey:@"type"];
    [p setObject:[NSDictionary dictionary] forKey:@"detail"];
    
    if(IS_USING_WILL)
    {
        NSString *jsonString = [p JSONString];
        [webSocket send:jsonString];
    }
    else
    {
        NSData *jsonData =[p JSONData];
        [webSocket send:jsonData];
    }
}

#pragma mark - App State

- (void)appBecameActive:(NSNotification *)notif
{
    [self openConnection];
    
    self.timer1 = [NSTimer timerWithTimeInterval:10.0
                                          target:self
                                        selector:@selector(isAlive)
                                        userInfo:nil
                                         repeats:YES];
    
    self.timer2 = [NSTimer timerWithTimeInterval:1.0
                                          target:self
                                        selector:@selector(sendPing)
                                        userInfo:nil
                                         repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer1 forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:self.timer2 forMode:NSDefaultRunLoopMode];
}

- (void)appWillResignActive:(NSNotification *)notif
{
    [self.timer1 invalidate];
    self.timer1 = nil;
    [self.timer2 invalidate];
    self.timer2 = nil;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)_webSocket didReceiveMessage:(id)message
{
    NSNotificationCenter *df = [NSNotificationCenter defaultCenter];
    
    NSString *jsonString = (NSString *)message;
    
    NSLog(@"%@", jsonString);
    
    NSString *from = nil;
    
    NSDictionary *payload = nil;
    if(IS_USING_WILL)
    {
        NSRange rangeOfFirstColon = [jsonString rangeOfString:@":"];
        
        if(NSEqualRanges(rangeOfFirstColon, notFound) == NO)
        {
            NSString *cleaned = [jsonString substringFromIndex:rangeOfFirstColon.location + 2];
            from = [jsonString substringToIndex:rangeOfFirstColon.location];
            
            NSError *error = nil;
            payload = [cleaned objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
        }
    }
    else
    {
        payload = [jsonString objectFromJSONString];
    }
    
    NSString *payloadType = [payload objectForKey:@"type"];
    
    if([payloadType isEqualToString:@"playbackInfo"] == YES || [payloadType isEqualToString:@"change"] == YES)
    {
        if(IS_TEACHER_MODE == NO)
        {
            NSDictionary *playInfo = [payload objectForKey:@"detail"];
            
            self.currentMovieId = [[playInfo objectForKey:@"videoId"] intValue];
            self.currentMovieTimestamp = [[playInfo objectForKey:@"timestamp"] doubleValue];
            self.currentPlayMode = [[playInfo objectForKey:@"action"] intValue];
            
            [df postNotificationName:@"PlaybackInfoNotification" object:self userInfo:nil];
        }
    }
    else if([payloadType isEqualToString:@"loginInfo"] == YES)
    {
        NSDictionary *loginInfo = [payload objectForKey:@"detail"];
        [df postNotificationName:@"LoginInfoNotification" object:self userInfo:loginInfo];
    }
    else if([payloadType isEqualToString:@"ping"] == YES)
    {
        if(from && [from isEqualToString:[[UIDevice currentDevice] uniqueIdentifier]] == YES)
        {
            self.pingReceivedTime = [NSDate date];
        }
    }
    else if([payloadType isEqualToString:@"inqury"] == YES)
    {
        if(IS_USING_WILL && IS_TEACHER_MODE)
        {
            NSMutableDictionary *p = [NSMutableDictionary dictionary];
            [p setObject:@"RespondInqury" forKey:@"type"];
            
            NSMutableDictionary *detail = [NSMutableDictionary dictionary];
            [detail setObject:from      forKey:@"to"];
            [detail setObject:[NSNumber numberWithInt:self.currentMovieId]      forKey:@"videoId"];
            [detail setObject:[NSNumber numberWithInt:self.currentMovieTimestamp] forKey:@"timestamp"];
            [detail setObject:[NSNumber numberWithInt:self.currentPlayMode]       forKey:@"action"];
            
            [p setObject:detail forKey:@"detail"];
            
            NSString *jsonString = [p JSONString];
            [webSocket send:jsonString];
        }
    }
    else if([payloadType isEqualToString:@"RespondInqury"] == YES)
    {
        if(IS_USING_WILL && IS_TEACHER_MODE == NO)
        {
            NSDictionary *playInfo = [payload objectForKey:@"detail"];
            NSString *to = [playInfo objectForKey:@"to"];
            if([to isEqualToString:[[UIDevice currentDevice] uniqueIdentifier]] == YES)
            {
                self.currentMovieId = [[playInfo objectForKey:@"videoId"] intValue];
                self.currentMovieTimestamp = [[playInfo objectForKey:@"timestamp"] doubleValue];
                self.currentPlayMode = [[playInfo objectForKey:@"action"] intValue];
                
                [df postNotificationName:@"PlaybackInfoNotification" object:self userInfo:nil];
            }
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)_webSocket
{
    [self login];
    
    if(IS_TEACHER_MODE == NO)
        [self queryPlayback];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"did failed");
}

- (void)webSocket:(SRWebSocket *)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean
{
    NSLog(@"webSocket did closed");
}

#pragma mark - singleton implementation code

static MovieManager *singletonManager = nil;
+ (MovieManager *)sharedInstance {
    
    static dispatch_once_t pred;
    static MovieManager *manager;
    
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (singletonManager == nil) {
            singletonManager = [super allocWithZone:zone];
            return singletonManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}
- (oneway void)release {
    //do nothing
}
- (id)autorelease {
    return self;
}
@end
