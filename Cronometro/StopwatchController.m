//
//  ViewController.m
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 01/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import "StopwatchController.h"
#import "FormmatterHelper.h"
#import "Constants.h"
#import "FeedUserDefaults.h"

@interface StopwatchController ()

@end

@implementation StopwatchController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fail" ofType:@"wav"];
    ending=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    ending.volume = 1.0f;
    ending.delegate = self;
    
    NSString *pathClock = [[NSBundle mainBundle] pathForResource:@"clock2" ofType:@"wav"];
    clock=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pathClock] error:NULL];
    clock.volume = 1.0f;
    clock.delegate = self;
    
    currentFormatDate = TYPEDEFS_FULLTIME;
    self.displayTimer.text = TYPEDEFS_DEFAULTTIME;
    self.displayTimer.layer.shadowColor = [[UIColor yellowColor] CGColor];
    [self.displayTimer setFont:[UIFont fontWithName:@"Digital-7" size:self.displayTimer.font.pointSize]];
    
    self.streamServer = [StreamServer sharedInstance];
    [self.streamServer setDelegate:self];
    
    self.streamClient = [StreamClient sharedInstance];
    [self.streamClient setDelegate:self];
}

- (void)showControls {
    if ([FeedUserDefaults isServer]) {
        NSLog(@"TRACE: Server");
        self.buttonStart.hidden = FALSE;
        self.buttonRestart.hidden = FALSE;
    } else {
        NSLog(@"TRACE: Client");
        self.buttonStart.hidden = TRUE;
        self.buttonRestart.hidden = TRUE;
    }
}

- (void)executeTimerController:(NSString *)time {
    [self.buttonStart setTitle:NSLocalizedString(@"Pause", @"") forState:UIControlStateNormal];
    currentDate = [FormmatterHelper convertStringToDate:time withFormat:currentFormatDate];
    [self getPercentajesWithTotal:[FormmatterHelper convertDateToSeconds:currentDate]];
    currentFormatDate = [FormmatterHelper getDateFormat:currentDate];
    self.displayTimer.text = [FormmatterHelper convertDateToString:currentDate withFormat:currentFormatDate];
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateTimer)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimer {
    NSDate *myDate = [FormmatterHelper convertStringToDate:self.displayTimer.text withFormat:currentFormatDate];
    NSDate *correctDate = [NSDate dateWithTimeInterval:-1.0 sinceDate:myDate];
    NSString *format =  [FormmatterHelper getDateFormat:correctDate];
    
    self.displayTimer.text = [FormmatterHelper convertDateToString:correctDate withFormat:format];
    currentFormatDate = format;
    
    if ([FeedUserDefaults audioIsOn]) {
        [clock play];
    }
    
    if ([FeedUserDefaults animationIsOn]) {
        [self runGlowEffect];
    }
    
    if ([FeedUserDefaults colorIsOn]) {
        [self runBackgroundEffectWithPercent:[currentDate timeIntervalSinceDate:correctDate]];
    }
    
    NSComparisonResult result = [correctDate compare: [FormmatterHelper convertStringToDate:TYPEDEFS_DEFAULTTIME withFormat:TYPEDEFS_TIMESS]];
    if(result == NSOrderedSame) {
        [self btnRestart:nil];
    }
}

- (void)stopTimerController {
    NSLog(@"TRACE: stop watch");
    [timer invalidate];
}

- (void)resetVariables {
    [self stopTimerController];
    self.displayTimer.text = TYPEDEFS_DEFAULTTIME;
    self.displayTimer.layer.shadowColor = [[UIColor yellowColor] CGColor];
    currentFormatDate = TYPEDEFS_FULLTIME;
    
    [FeedUserDefaults setTimer:[FeedUserDefaults timerTemporary]];
    self.mainView.backgroundColor = [UIColor blackColor];
    self.displayTimer.textColor = [UIColor redColor];
    
    [self.buttonStart setTitle:NSLocalizedString(@"Start", @"") forState:UIControlStateNormal];
    flagGreen = 0;
    flagRed = 0;
}


#pragma mark - Animation Methods

- (void)runGlowEffect {
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^ {
                         [self.displayTimer setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
                         self.displayTimer.layer.shadowRadius = 10.0f;
                     } completion:^(BOOL finished) {
                         [self.displayTimer setTransform:CGAffineTransformIdentity];
                         self.displayTimer.layer.shadowRadius = 0.0f;
                     }];
}

- (void)runBackgroundEffectWithPercent:(NSTimeInterval)percent {
    if ((int)percent == flagGreen) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^ {
                             self.mainView.backgroundColor = [UIColor colorWithRed:238 green:201 blue:0 alpha:1.0f];
                             self.displayTimer.textColor = [UIColor blackColor];
                             self.displayTimer.layer.shadowColor = [[UIColor whiteColor] CGColor];
                         } completion:nil];
    } else if ((int)percent == flagRed) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             self.mainView.backgroundColor = [UIColor redColor];
                         } completion:nil];
    }
}

- (void)getPercentajesWithTotal:(int)seconds {
    flagGreen = (seconds * 50) / 100;
    flagRed = (seconds * 80) / 100;
}


#pragma mark - IBAction Methods

- (IBAction)btnRestart:(id)sender {
    if (![[FeedUserDefaults timer] isEqualToString:FEEDUSERDEFAULTS_TIMER]) {
        [self.streamServer sendRestart];
        [self resetVariables];
        if ([FeedUserDefaults audioIsOn]) {
            [ending play];
        }
    }
}

- (IBAction)btnStart:(id)sender {
    if (![[FeedUserDefaults timer] isEqualToString:FEEDUSERDEFAULTS_TIMER]) {
        if ([self.buttonStart.titleLabel.text isEqualToString:NSLocalizedString(@"Pause", @"")]) {
            [self.buttonStart setTitle:NSLocalizedString(@"Start", @"") forState:UIControlStateNormal];
            [FeedUserDefaults setTimer:self.displayTimer.text];
            [self.streamServer sendPause];
            [self stopTimerController];
        } else {
            [self.streamServer sendStartMessage];
            [self executeTimerController:[FeedUserDefaults timer]];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"")
                                    message:NSLocalizedString(@"PleaseConfigure", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                          otherButtonTitles:nil] show];
    }
}


#pragma mark - Server Delegate Methods

- (void)messageResponse {
    NSLog(@"TRACE: Message response server");
}


#pragma mark - Client Delegate Methods

- (void)messageReceived:(NSString*)message {
    NSLog(@"TRACE: messageReceived client %@",message);
    
    if ([message rangeOfString:@"Server"].location == NSNotFound) {
        if ([message rangeOfString:@"stop"].location == NSNotFound &&
            [message rangeOfString:@"pause"].location == NSNotFound) {
            [self executeTimerController:message];
        } else if ([message rangeOfString:NSLocalizedString(@"pause", @"")].location == NSNotFound) {
            [self resetVariables];
        } else {
            [self stopTimerController];
        }
    }
}

@end
