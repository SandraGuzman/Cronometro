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

@property (strong, nonatomic) IBOutlet DACircularProgressView *largeProgressView;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *optionsSettings;
@property (weak, nonatomic) IBOutlet UITextField *hours;
@property (weak, nonatomic) IBOutlet UITextField *minutes;
@property (weak, nonatomic) IBOutlet UITextField *seconds;
@property (weak, nonatomic) IBOutlet UIView *serverView;
@property (weak, nonatomic) IBOutlet UIView *clientView;
@property (weak, nonatomic) IBOutlet UILabel *displayStatusClient;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UITableView *logServer;

- (IBAction)startConnection:(id)sender;
- (IBAction)closePopup:(id)sender;
- (IBAction)segmentedControlChanged:(id)sender;

@end
