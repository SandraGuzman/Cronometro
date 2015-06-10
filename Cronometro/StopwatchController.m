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
    currentFormatDate = TYPEDEFS_FULLTIME;
    self.displayTimer.text = TYPEDEFS_DEFAULTTIME;
    self.displayTimer.layer.shadowColor = [[UIColor yellowColor] CGColor];
    self.displayTimer.layer.shadowRadius = 0.0f;
    self.displayTimer.layer.shadowOpacity = 10.0f;
    [self.displayTimer setFont:[UIFont fontWithName:@"Digital-7" size:250.0f]];
    [self showControls];
    
    self.streamServer = [StreamServer sharedInstance];
    [self.streamServer setDelegate:self];
    
    self.streamClient = [StreamClient sharedInstance];
    [self.streamClient setDelegate:self];
}

- (void)showControls {
    if ([FeedUserDefaults isServer]) {
        NSLog(@"TRACE: SERVER");
        self.buttonStart.hidden = FALSE;
        self.buttonRestart.hidden = FALSE;
    } else {
        NSLog(@"TRACE: CLIENT");
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
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateTimer)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)updateTimer {
    [self runGlowEffect];
    NSDate *myDate = [FormmatterHelper convertStringToDate:self.displayTimer.text withFormat:currentFormatDate];
    NSDate *correctDate = [NSDate dateWithTimeInterval:-1.0 sinceDate:myDate];
    self.displayTimer.text = [FormmatterHelper convertDateToString:correctDate withFormat:currentFormatDate];
    [self runBackgroundEffectWithPercent:[currentDate timeIntervalSinceDate:correctDate]];
    
    NSComparisonResult result = [correctDate compare: [FormmatterHelper convertStringToDate:TYPEDEFS_DEFAULTTIME withFormat:TYPEDEFS_FULLTIME]];
    
    if(result == NSOrderedSame) {
        [self btnRestart:nil];
    }
}

- (void)stopTimerController {
    NSLog(@"TRACE: stop watch");
    [timer invalidate];
}

- (void)resetVariables {
    self.displayTimer.text = [[FormmatterHelper initializeNSDateFormat:currentFormatDate] stringFromDate:
                              [FormmatterHelper convertStringToDate:TYPEDEFS_DEFAULTTIME withFormat:TYPEDEFS_FULLTIME]];
    [FeedUserDefaults setTimer:[FeedUserDefaults timerTemporary]];
    currentDate = [NSDate alloc];
    flagGreen = 0;
    flagRed = 0;
    self.displayTimer.layer.shadowColor = [[UIColor yellowColor] CGColor];
    self.mainView.backgroundColor = [UIColor blackColor];
    self.displayTimer.textColor = [UIColor redColor];
    
    [self stopTimerController];
    [self.buttonStart setTitle:NSLocalizedString(@"Start", @"") forState:UIControlStateNormal];
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
                             self.mainView.backgroundColor = [UIColor greenColor];
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
