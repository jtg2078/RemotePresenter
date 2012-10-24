//
//  RemoteManager.h
//  RemotePresenter
//
//  Created by jason on 10/17/12.
//  Copyright (c) 2012 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"


@interface RemoteManager : NSObject <SRWebSocketDelegate>
{
    SRWebSocket *webSocket;
}

+ (RemoteManager *)sharedInstance;

- (void)openConnection;

@property (assign, nonatomic) int currentPage;

@end
