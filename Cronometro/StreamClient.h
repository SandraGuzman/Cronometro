//
//  StreamConnection.h
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 01/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import <ifaddrs.h>

@protocol StreamClientDelegate <NSObject>
@required
- (void)messageReceived:(NSString*)message;
@end

@interface StreamClient : NSObject <NSStreamDelegate>

@property (weak) id <StreamClientDelegate> delegate;

+ (StreamClient *)sharedInstance;
- (void)initNetworkCommunication:(NSString*)ipServer;

@end
