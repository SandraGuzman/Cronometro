//
//  StreamConnection.m
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 01/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import "StreamClient.h"
#import "Constants.h"
#import "FeedUserDefaults.h"


@implementation StreamClient

CFSocketRef myipv4cfsock;
NSInputStream *inputStream;
NSOutputStream *outputStream;
NSTimer *reconnectTimer;
NSString *ipAddressServer;
CFRunLoopSourceRef socketsource;
CFSocketNativeHandle sock;
CFReadStreamRef readStream = NULL;
CFWriteStreamRef writeStream = NULL;

+ (StreamClient *)sharedInstance {
    static StreamClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)initNetworkCommunication:(NSString*)ipServer {
    ipAddressServer = ipServer;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipServer, TYPEDEFS_PORT, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream setDelegate:self];
    [inputStream open];
    [outputStream setDelegate:self];
    [outputStream open];
}

- (void)closeConnection{
    [inputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream close];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream setDelegate:nil];
    inputStream = nil;
    [outputStream setDelegate:nil];
    outputStream = nil;
}


- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    NSLog(@"TRACE: Event handler");
    BOOL shouldClose = NO;
    
    switch(event) {
        case NSStreamEventOpenCompleted: {
            NSLog(@"TRACE: Open Complete ");
        }
        case  NSStreamEventEndEncountered:
            NSLog(@"TRACE: Event end ocurred");
            if (stream.streamStatus == NSStreamStatusAtEnd) shouldClose = YES;
            break;
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"TRACE: Stream Has Bytes Available!");
            uint8_t buf[1024];
            unsigned int len = 0;
            len = (int)[(NSInputStream *)stream read:buf maxLength:1024];
            if (len) {
                NSString *stringFromData = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
                NSLog(@"TRACE: Data - %@",stringFromData);
                NSDictionary* dict = [NSDictionary dictionaryWithObject:@"ok" forKey:@"success"];
                [[NSNotificationCenter defaultCenter] postNotificationName:TYPEDEFS_NOTIFICATIONSTATUS object:nil userInfo:dict];
                [FeedUserDefaults setIsConnected:YES];
                if(self.delegate !=NULL )[self.delegate messageReceived: stringFromData];
            } else {
                NSLog(@"TRACE: No buffer!");
            }
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSError *error = [stream streamError];
            NSLog(@"ERROR: %ld  %@", (long)error.code, error.localizedDescription);
            shouldClose = YES;
            
            break;}
        case NSStreamEventHasSpaceAvailable:break;
        case NSStreamEventNone:break;
    }
    
    if(shouldClose){
        if (stream == outputStream || stream==inputStream) {
            [FeedUserDefaults setIsConnected:NO];
            [self closeConnection];
            reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
            NSLog(@"TRACE: !!!Stream closed will retrying connection.");
        }
    }
}

- (void)onTimer:(NSTimer*)timer {
    [reconnectTimer invalidate];
    [self initNetworkCommunication:ipAddressServer];
}

@end
