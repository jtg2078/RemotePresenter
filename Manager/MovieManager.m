//
//  MovieManager.m
//  RemotePresenter
//
//  Created by jason on 10/23/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import "MovieManager.h"

@implementation MovieManager

#pragma mark - dealloc

- (void)dealloc
{
    [webSocket release];
    [decoder release];
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

- (void)setup
{
    NSString *urlString = @"ws://ec2-54-242-8-110.compute-1.amazonaws.com:8080/ws/connect";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webSocket = [[SRWebSocket alloc] initWithURLRequest:request];
    webSocket.delegate = self;
    
    // register for application start up
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(appBecameActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    
    // playback stuff
    self.moviesArray = [NSArray arrayWithObjects:
                        @"b_001",
                        @"b_002",
                        @"b_003",
                        nil];
    
    // misc
    decoder = [[JSONDecoder decoder] retain];
}

#pragma mark - main methods

- (void)openConnection
{
    SRReadyState state = webSocket.readyState;
    
    if(webSocket && state == SR_CONNECTING)
    {
        [webSocket open];
    }
}

- (void)updatePlaybackInfo:(int)videoId
                      time:(NSTimeInterval)playbackTime
                    action:(int)action
{
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setObject:@"change" forKey:@"type"];
    
    NSMutableDictionary *detail = [NSMutableDictionary dictionary];
    [detail setObject:[NSNumber numberWithInt:videoId]      forKey:@"videoId"];
    [detail setObject:[NSNumber numberWithInt:playbackTime] forKey:@"timestamp"];
    [detail setObject:[NSNumber numberWithInt:action]       forKey:@"action"];
    
    [p setObject:detail forKey:@"detail"];
    
    NSData *jsonData =[p JSONData];
    [webSocket send:jsonData];
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
    
    NSData *jsonData =[p JSONData];
    [webSocket send:jsonData];
}

- (void)queryPlayback
{
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    [p setObject:@"inqury" forKey:@"type"];
    [p setObject:[NSDictionary dictionary] forKey:@"detail"];
    
    NSData *jsonData =[p JSONData];
    [webSocket send:jsonData];
}

#pragma mark - App State

- (void)appBecameActive:(NSNotification *)notif
{
    [self openConnection];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSNotificationCenter *df = [NSNotificationCenter defaultCenter];
    
    NSString *jsonString = (NSString *)message;
    NSDictionary *payload = [jsonString objectFromJSONString];
    
    NSString *payloadType = [payload objectForKey:@"type"];
    
    if([payloadType isEqualToString:@"playbackInfo"] == YES)
    {
        NSDictionary *playInfo = [payload objectForKey:@"detail"];
        
        self.currentMovieId = [[playInfo objectForKey:@"videoId"] intValue];
        self.currentMovieTimestamp = [[playInfo objectForKey:@"timestamp"] doubleValue];
        self.currentPlayMode = [[playInfo objectForKey:@"action"] intValue];
        
        [df postNotificationName:@"PlaybackInfoNotification" object:self userInfo:nil];
    }
    else if([payloadType isEqualToString:@"loginInfo"] == YES)
    {
        NSDictionary *loginInfo = [payload objectForKey:@"detail"];
        [df postNotificationName:@"LoginInfoNotification" object:self userInfo:loginInfo];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)_webSocket
{
    [self login];
    
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
    NSLog(@"did closed");
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
