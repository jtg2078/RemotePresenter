//
//  RemoteManager.m
//  RemotePresenter
//
//  Created by jason on 10/17/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import "RemoteManager.h"


@implementation RemoteManager

#pragma mark - dealloc

- (void)dealloc
{
    [webSocket release];
    [super dealloc];
}

#pragma mark - init and setup

- (id)init
{
    self = [super init];
    if (self) {
        //[self setup];
    }
    return self;
}

- (void)setup
{
    NSString *urlString = @"ws://ec2-54-242-8-110.compute-1.amazonaws.com:8080/websocket/connect";
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

#pragma mark - App State

- (void)appBecameActive:(NSNotification *)notif
{
    //[self openConnection];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    self.currentPage = [message intValue];
    NSLog(@"%d", self.currentPage);
    
    NSNotificationCenter *df = [NSNotificationCenter defaultCenter];
    [df postNotificationName:@"ChangePageNotification" object:self userInfo:nil];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"did opened");
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

static RemoteManager *singletonManager = nil;
+ (RemoteManager *)sharedInstance {
    
    static dispatch_once_t pred;
    static RemoteManager *manager;
    
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
