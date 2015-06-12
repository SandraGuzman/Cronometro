//
//  FeedUserDefaults.m
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 02/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import "FeedUserDefaults.h"

@implementation FeedUserDefaults

+ (NSString *)timer {
    NSString *stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:FEEDUSERDEFAULTS_TIMER];
    NSString *returnValue = FEEDUSERDEFAULTS_TIMER;
    
    if (!stringValue) {
        [[NSUserDefaults standardUserDefaults] setObject:returnValue forKey:FEEDUSERDEFAULTS_TIMER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        returnValue = stringValue;
    }
    
    return returnValue;
}


+ (void)setTimer:(NSString*)timer {
    [[NSUserDefaults standardUserDefaults] setObject:timer forKey:FEEDUSERDEFAULTS_TIMER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSString *)timerTemporary {
    NSString *stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:FEEDUSERDEFAULTS_TIMERTEMPORARY];
    NSString *returnValue = FEEDUSERDEFAULTS_TIMERTEMPORARY;
    
    if (!stringValue) {
        [[NSUserDefaults standardUserDefaults] setObject:returnValue forKey:FEEDUSERDEFAULTS_TIMERTEMPORARY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        returnValue = stringValue;
    }
    
    return returnValue;
}


+ (void)setTimerTemporary:(NSString *)timer {
    [[NSUserDefaults standardUserDefaults] setObject:timer forKey:FEEDUSERDEFAULTS_TIMERTEMPORARY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)isServer {
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:FEEDUSERDEFAULTS_ISSERVER];
    
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:FEEDUSERDEFAULTS_ISSERVER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return  value;
}


+ (void)setIsServer:(BOOL)isServer {
    [[NSUserDefaults standardUserDefaults] setBool:isServer forKey:FEEDUSERDEFAULTS_ISSERVER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSString *)urlServer {
    NSString *stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:FEEDUSERDEFAULTS_URLSERVER];
    NSString *returnValue = FEEDUSERDEFAULTS_URLSERVER;
    
    if (!stringValue) {
        [[NSUserDefaults standardUserDefaults] setObject:returnValue forKey:FEEDUSERDEFAULTS_URLSERVER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        returnValue = stringValue;
    }
    
    return returnValue;
}


+ (void)setUrlServer:(NSString *)urlServer {
    [[NSUserDefaults standardUserDefaults] setObject:urlServer forKey:FEEDUSERDEFAULTS_URLSERVER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)isConnected {
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:FEEDUSERDEFAULTS_ISCONNECTED];
    
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:FEEDUSERDEFAULTS_ISCONNECTED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return  value;
}


+ (void)setIsConnected:(BOOL)isConnected {
    [[NSUserDefaults standardUserDefaults] setBool:isConnected forKey:FEEDUSERDEFAULTS_ISCONNECTED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSArray *)logData {
    NSArray *data = [[NSUserDefaults standardUserDefaults] objectForKey:FEEDUSERDEFAULTS_LOG];
    NSArray *returnValue = [[NSArray alloc]init];
    
    if (data == nil) {
        [[NSUserDefaults standardUserDefaults]  setObject:returnValue forKey:FEEDUSERDEFAULTS_LOG];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        returnValue = data;
    }
    
    return  returnValue;
}


+ (void)setLogData:(NSArray *)logData {
    [[NSUserDefaults standardUserDefaults] setObject:logData forKey:FEEDUSERDEFAULTS_LOG];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)colorIsOn {
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:FEEDUSERDEFAULTS_COLORISON];
    
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:FEEDUSERDEFAULTS_COLORISON];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return  value;
}


+ (void)setColorIsOn:(BOOL)colorIsOn {
    [[NSUserDefaults standardUserDefaults] setBool:colorIsOn forKey:FEEDUSERDEFAULTS_COLORISON];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)animationIsOn {
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:FEEDUSERDEFAULTS_ANIMATIONISON];
    
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:FEEDUSERDEFAULTS_ANIMATIONISON];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return  value;
}


+ (void)setAnimationIsOn:(BOOL)animationIsOn {
    [[NSUserDefaults standardUserDefaults] setBool:animationIsOn forKey:FEEDUSERDEFAULTS_ANIMATIONISON];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (BOOL)audioIsOn {
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:FEEDUSERDEFAULTS_AUDIOISON];
    
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:FEEDUSERDEFAULTS_AUDIOISON];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return  value;
}


+ (void)setAudioIsOn:(BOOL)audioIsOn {
    [[NSUserDefaults standardUserDefaults] setBool:audioIsOn forKey:FEEDUSERDEFAULTS_AUDIOISON];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
