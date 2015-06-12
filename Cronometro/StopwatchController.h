//
//  ViewController.h
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 01/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "StreamClient.h"
#import "StreamServer.h"

@interface StopwatchController : UIViewController <StreamServerDelegate, StreamClientDelegate, AVAudioPlayerDelegate> {
    AVAudioPlayer* ending;
    AVAudioPlayer* clock;
    NSTimer *timer;
    NSString *currentFormatDate;
    NSDate *currentDate;
    int flagGreen;
    int flagRed;
}

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *buttonRestart;
@property (weak, nonatomic) IBOutlet UIButton *buttonStart;
@property (weak, nonatomic) IBOutlet UILabel* displayTimer;
@property (retain) StreamServer *streamServer;
@property (retain) StreamClient *streamClient;

- (IBAction)btnRestart:(id)sender;
- (IBAction)btnStart:(id)sender;
- (void)showControls;

@end

