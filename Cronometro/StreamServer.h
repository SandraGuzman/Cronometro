//
//  StreamServer.h
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 01/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>

@protocol StreamServerDelegate <NSObject>
@required
- (void) messageResponse;
@end

@interface StreamServer : NSObject <NSStreamDelegate> {
    CFSocketRef myipv4cfsock;
    CFSocketRef myipv6cfsock;
    CFRunLoopSourceRef socketsource;
}

@property (weak) id <StreamServerDelegate> delegate;

+ (StreamServer *)sharedInstance;
- (NSString*)startNetworkListening;
- (void)sendStartMessage;
- (void)sendRestart;
- (void)sendPause;
- (void)sendSettings;

@end
