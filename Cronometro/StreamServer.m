//
//  StreamServer.m
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 01/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import "StreamServer.h"
#import "Constants.h"
#import "FeedUserDefaults.h"

@implementation StreamServer

static NSMutableArray *arrInputStream;
static NSMutableArray *arrOutputStream;

+ (StreamServer *)sharedInstance {
    static StreamServer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString*)startNetworkListening {
    NSString *ipAddress = [self getIPAddress];
    NSLog(@"TRACE: ip server %@", ipAddress);
    if (![ipAddress isEqualToString:@"error"]) {
        NSDictionary* dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"SuccessfulLog", @"") forKey:@"log"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TYPEDEFS_NOTIFICATIONNEWLOG object:nil userInfo:dict];
    }
    
    arrInputStream=[[NSMutableArray alloc] init];
    arrOutputStream=[[NSMutableArray alloc] init];
    [self createSocketObjects];
    [self bindSockets];
    [self createSocketRunLoop];
    
    return ipAddress;
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

#pragma mark -  Socket Methods

- (void)createSocketObjects {
    CFSocketContext ctx = {0,(__bridge void *)(self),NULL,NULL};
    
    myipv4cfsock = CFSocketCreate(
                                  kCFAllocatorDefault,
                                  PF_INET,
                                  SOCK_STREAM,
                                  IPPROTO_TCP,
                                  kCFSocketAcceptCallBack,
                                  (CFSocketCallBack)&serverAcceptCallBack,
                                  &ctx);
    myipv6cfsock = CFSocketCreate(
                                  kCFAllocatorDefault,
                                  PF_INET6,
                                  SOCK_STREAM,
                                  IPPROTO_TCP,
                                  kCFSocketAcceptCallBack,
                                  (CFSocketCallBack)&serverAcceptCallBack,
                                  &ctx);
}

- (void)bindSockets {
    struct sockaddr_in sin;
    
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(TYPEDEFS_PORT);
    sin.sin_addr.s_addr= INADDR_ANY;
    
    CFDataRef sincfd = CFDataCreate(
                                    kCFAllocatorDefault,
                                    (UInt8 *)&sin,
                                    sizeof(sin));
    
    CFSocketSetAddress(myipv4cfsock, sincfd);
    CFRelease(sincfd);
    
    struct sockaddr_in6 sin6;
    
    memset(&sin6, 0, sizeof(sin6));
    sin6.sin6_len = sizeof(sin6);
    sin6.sin6_family = AF_INET6;
    sin6.sin6_port = htons(TYPEDEFS_PORT);
    sin6.sin6_addr = in6addr_any;
    
    CFDataRef sin6cfd = CFDataCreate(
                                     kCFAllocatorDefault,
                                     (UInt8 *)&sin6,
                                     sizeof(sin6));
    
    CFSocketSetAddress(myipv6cfsock, sin6cfd);
    CFRelease(sin6cfd);
}

- (void)createSocketRunLoop {
    socketsource = CFSocketCreateRunLoopSource(
                                               kCFAllocatorDefault,
                                               myipv4cfsock,
                                               0);
    
    CFRunLoopAddSource(
                       CFRunLoopGetCurrent(),
                       socketsource,
                       kCFRunLoopDefaultMode);
    
    CFRunLoopSourceRef socketsource6 = CFSocketCreateRunLoopSource(
                                                                   kCFAllocatorDefault,
                                                                   myipv6cfsock,
                                                                   0);
    
    CFRunLoopAddSource(
                       CFRunLoopGetCurrent(),
                       socketsource6,
                       kCFRunLoopDefaultMode);
}

- (void)printStatus:(NSStreamStatus)status {
    switch(status){
        case NSStreamStatusNotOpen : NSLog(@"Not open"); break;
        case NSStreamStatusOpening: NSLog(@"Opening"); break;
        case  NSStreamStatusOpen : NSLog(@"Open");break;
        case NSStreamStatusReading: NSLog(@"Reading");break;
        case NSStreamStatusWriting: NSLog(@"Writing");break;
        case NSStreamStatusAtEnd: NSLog(@"End");break;
        case NSStreamStatusClosed: NSLog(@" Closed");break;
        case NSStreamStatusError:NSLog(@"Error");break;
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    BOOL shouldClose = NO;
    NSLog(@"Event handler");
    [self printStatus: stream.streamStatus];
    
    switch(event) {
        case NSStreamEventOpenCompleted: {
            NSLog(@"En Open Complete ");
            
            if([stream isKindOfClass:[NSOutputStream class]]){
                NSLog(@"OutputStream");
            }
        }
        case  NSStreamEventEndEncountered: {
            NSLog(@"Event end ocurred");
            if (stream.streamStatus == NSStreamStatusAtEnd) shouldClose = YES;
            break;}
        case NSStreamEventHasBytesAvailable: {
            NSLog(@"Stream Has Bytes Available!");
            uint8_t buf[1024];
            unsigned int len = 0;
            len = (int)[(NSInputStream *)stream read:buf maxLength:1024];
            
            if (len) {
                NSString *stringFromData = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
                NSLog(@"Data: %@",stringFromData);
                if(self.delegate!=NULL)[self.delegate messageResponse];
            } else {
                NSLog(@"no buffer!");
            }
            break;
        }
        case NSStreamEventErrorOccurred:{
            NSLog(@"Stream Event Error");
            shouldClose = YES;
            break;
        }
        case NSStreamEventHasSpaceAvailable:{break;}
        case NSStreamEventNone:{break;}
    }
    
    if (shouldClose) {
        [arrInputStream removeObject:stream];
        [arrOutputStream removeObject:stream];
        [stream close];
        NSLog(@"Stream closed");
    }
}


#pragma mark -  The Methods of Communication Server - Client

- (void)sendMessageToDevice:(NSOutputStream *)outputStream mensaje:(NSString *)msg{
    NSData *data1 = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data1 bytes] maxLength:[data1 length]];
}

- (void)sendSettings {
    NSLog(@"TRACE: send settings");
    NSData *data = [[NSData alloc] initWithData:[[@"settings" stringByAppendingFormat:@"|%d|%d|%d", [FeedUserDefaults colorIsOn], [FeedUserDefaults animationIsOn], [FeedUserDefaults audioIsOn]] dataUsingEncoding:NSASCIIStringEncoding]];
    
    for (id outputStream in arrOutputStream) {
        [(NSOutputStream *)outputStream write:[data bytes] maxLength:[data length]];
    }
}

- (void)sendStartMessage {
    NSLog(@"TRACE: send data time - %@", [FeedUserDefaults timer]);
    NSData *data = [[NSData alloc] initWithData:[[FeedUserDefaults timer] dataUsingEncoding:NSASCIIStringEncoding]];
    
    for(id outputStream in arrOutputStream) {
        [(NSOutputStream *)outputStream write:[data bytes] maxLength:[data length]];
    }
}

- (void)sendRestart {
    NSLog(@"TRACE: stop watch");
    NSData *data = [[NSData alloc] initWithData:[@"stop" dataUsingEncoding:NSASCIIStringEncoding]];
    
    for(id outputStream in arrOutputStream) {
        [(NSOutputStream *)outputStream write:[data bytes] maxLength:[data length]];
    }
}

- (void)sendPause {
    NSLog(@"TRACE: pause watch");
    NSData *data = [[NSData alloc] initWithData:[@"pause" dataUsingEncoding:NSASCIIStringEncoding]];
    
    for(id outputStream in arrOutputStream) {
        [(NSOutputStream *)outputStream write:[data bytes] maxLength:[data length]];
    }
}

#pragma mark - Static Methods

static void serverAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFSocketNativeHandle sock = *(CFSocketNativeHandle *) data;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, sock, &readStream, &writeStream);
    
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    
    NSOutputStream *theOutputStream;
    NSInputStream *theInputStream;
    
    
    theInputStream = (__bridge NSInputStream *)readStream;
    theOutputStream = (__bridge NSOutputStream *)writeStream;
    [theInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [theOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    StreamServer *server = (__bridge StreamServer*)info;
    [theInputStream setDelegate:server];
    [theInputStream open];
    [theOutputStream setDelegate:server];
    [theOutputStream open];
    
    [arrInputStream addObject:theInputStream];
    [arrOutputStream addObject:theOutputStream];
    NSLog(@"TRACE: Connection accepted - add element in inputStream %lu", (unsigned long)arrInputStream.count);
    NSDictionary* dict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"NewDevice", @"") forKey:@"log"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TYPEDEFS_NOTIFICATIONNEWLOG object:nil userInfo:dict];
    [server sendMessageToDevice:[arrOutputStream lastObject] mensaje:[NSString stringWithFormat:@"Send Message to Server from Client %lu",(unsigned long)arrOutputStream.count]];
    
    return;
}

@end
