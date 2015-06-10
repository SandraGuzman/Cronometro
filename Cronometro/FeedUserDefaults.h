//
//  FeedUserDefaults.h
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 02/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FEEDUSERDEFAULTS_TIMER @"timer"
#define FEEDUSERDEFAULTS_TIMERTEMPORARY @"temporary"
#define FEEDUSERDEFAULTS_ISSERVER @"isServer"
#define FEEDUSERDEFAULTS_URLSERVER @"urlServer"
#define FEEDUSERDEFAULTS_ISCONNECTED @"isConnected"
#define FEEDUSERDEFAULTS_LOG @"logData"

@interface FeedUserDefaults : NSObject

+ (NSString *)timer;
+ (void)setTimer:(NSString *)timer;

+ (NSString *)timerTemporary;
+ (void)setTimerTemporary:(NSString *)timer;

+ (BOOL)isServer;
+ (void)setIsServer:(BOOL)isServer;

+ (NSString *)urlServer;
+ (void)setUrlServer:(NSString *)urlServer;

+ (BOOL)isConnected;
+ (void)setIsConnected:(BOOL)isConnected;

+ (NSArray *)logData;
+ (void)setLogData:(NSArray *)logData;

@end
