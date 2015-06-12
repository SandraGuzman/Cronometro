//
//  PreferencesController.h
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 01/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingObjC/ZXingObjC.h>
#import "ZBarSDK.h"
#import "StreamServer.h"
#import "StreamClient.h"
#import "StopwatchController.h"
#import "DACircularProgressView.h"

@interface SettingsController : UIViewController <ZBarReaderDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    UIViewController *topController;
    NSMutableArray *logs;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *optionsSettings;

// Server

@property (weak, nonatomic) IBOutlet UIView *serverView;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImage;
@property (weak, nonatomic) IBOutlet UITextField *hours;
@property (weak, nonatomic) IBOutlet UITextField *minutes;
@property (weak, nonatomic) IBOutlet UITextField *seconds;
@property (weak, nonatomic) IBOutlet UITableView *logServer;

// Client

@property (weak, nonatomic) IBOutlet UIView *clientView;
@property (strong, nonatomic) IBOutlet DACircularProgressView *largeProgressView;
@property (weak, nonatomic) IBOutlet UILabel *displayStatusClient;
@property (strong, nonatomic) NSTimer *timer;

// General

@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (weak, nonatomic) IBOutlet UISwitch *colorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *animationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;


- (IBAction)closePopup:(id)sender;
- (IBAction)segmentedControlChanged:(id)sender;
- (IBAction)saveSettings:(id)sender;
- (IBAction)connectToServer:(id)sender;
- (IBAction)startServer:(id)sender;

@end
