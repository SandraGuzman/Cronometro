//
//  PreferencesController.m
//  Cronometro
// 
//  Created by Sandra Guzmán Bautista on 01/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import "SettingsController.h"
#import "FeedUserDefaults.h"
#import "Constants.h"
#import "FormmatterHelper.h"

@interface SettingsController ()

@end

@implementation SettingsController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.qrCodeImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
    topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    logs = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeDataTableLog:)
                                                 name:TYPEDEFS_NOTIFICATIONNEWLOG object:nil];
    
    self.largeProgressView.roundedCorners = YES;
    self.largeProgressView.thicknessRatio = .1f;
    [self drawStatusConnectedClient:[FeedUserDefaults isConnected]];
    
    if (![[FeedUserDefaults urlServer] isEqualToString:FEEDUSERDEFAULTS_URLSERVER]) {
        [self drawQRCodeIpServer:[FeedUserDefaults urlServer]];
    }
    
    if ([FeedUserDefaults isServer]) {
        self.optionsSettings.selectedSegmentIndex = 0;
        
        for (NSString *log in  [FeedUserDefaults logData]) {
            [logs addObject:log];
        }
        
        [self.logServer reloadData];
    } else {
        self.optionsSettings.selectedSegmentIndex = 1;
    }
    
    [self segmentedControlChanged:self.optionsSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)startConnection:(id)sender {
    if (self.optionsSettings.selectedSegmentIndex == 0) {
        [FeedUserDefaults setIsServer:YES];
        [self startServer];
    } else {
        [FeedUserDefaults setIsServer:NO];
        [self startClient];
    }
}

- (IBAction)closePopup:(id)sender {
    [(StopwatchController *)topController showControls];
    [FeedUserDefaults setLogData:logs];
    [[NSNotificationCenter defaultCenter] removeObserver:TYPEDEFS_NOTIFICATIONSTATUS];
    [[NSNotificationCenter defaultCenter] removeObserver:TYPEDEFS_NOTIFICATIONNEWLOG];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentedControlChanged:(id)sender {
    UISegmentedControl *segmentedC = (UISegmentedControl *)sender;

    if (segmentedC.selectedSegmentIndex == 0) {
        self.serverView.hidden = FALSE;
        self.clientView.hidden = TRUE;
    } else {
        self.clientView.hidden = FALSE;
        self.serverView.hidden = TRUE;
    }
}

- (void)startServer {
    NSString *timer = [FormmatterHelper getDateStringWithHour:_hours.text andMinutes:_minutes.text andSeconds:_seconds.text];
    NSDate *myDate = [FormmatterHelper convertStringToDate:timer withFormat:TYPEDEFS_FULLTIME];
    
    if (myDate == nil) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert", @"")
                                    message:NSLocalizedString(@"PleaseFormat", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                          otherButtonTitles:nil] show];
    } else {
        [FeedUserDefaults setTimer:timer];
        [FeedUserDefaults setTimerTemporary:timer];
        
        NSString *ipAddress = [[StreamServer sharedInstance] startNetworkListening];
        [FeedUserDefaults setUrlServer:ipAddress];
        [self drawQRCodeIpServer:ipAddress];
    }
}

- (void)startClient {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    [self presentViewController:reader animated:YES completion:nil];
}

#pragma mark - Custom view Methods

- (void)progressChange {
    CGFloat progress = self.largeProgressView.progress + 0.01f;
    [self.largeProgressView setProgress:progress animated:YES];
    
    if (self.largeProgressView.progress >= 1.0f && [self.timer isValid]) {
        [self.largeProgressView setProgress:0.f animated:YES];
    }
}

- (void)showLabelStatusConnection:(NSNotification *)status {
    [[NSNotificationCenter defaultCenter] removeObserver:TYPEDEFS_NOTIFICATIONSTATUS];
    
    if ([[[status userInfo] valueForKey:@"success"] isEqualToString:@"ok"]) {
        [self drawStatusConnectedClient:YES];
    } else {
        [self drawStatusConnectedClient:NO];
    }
    
    [self.timer invalidate];
}

- (void)changeDataTableLog:(NSNotification *)log {
    NSString *newLog = [[log userInfo] valueForKey:@"log"];
    [logs addObject:newLog];
    [self.logServer reloadData];
}

- (void)drawStatusConnectedClient:(BOOL)status {
    if (status) {
        [self.largeProgressView setProgress:1 animated:NO];
        self.largeProgressView.progressTintColor = [UIColor greenColor];
        self.largeProgressView.trackTintColor = [UIColor lightGrayColor];
        self.displayStatusClient.text = NSLocalizedString(@"SuccessfulConnection", @"");
        self.displayStatusClient.textColor = [UIColor greenColor];
    } else {
        [self.largeProgressView setProgress:0 animated:NO];
        self.largeProgressView.progressTintColor = [UIColor darkGrayColor];
        self.largeProgressView.trackTintColor = [UIColor lightGrayColor];
        self.displayStatusClient.text = NSLocalizedString(@"ServerNotFound", @"");
        self.displayStatusClient.textColor = [UIColor lightGrayColor];
    }
}

- (void)drawQRCodeIpServer:(NSString *)ipServer {
    NSError *error = nil;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:ipServer
                                  format:kBarcodeFormatQRCode
                                   width:self.qrCodeImage.frame.size.width
                                  height:self.qrCodeImage.frame.size.height
                                   error:&error];
    if (result) {
        self.qrCodeImage.image = [UIImage imageWithCGImage:[[ZXImage imageWithMatrix:result] cgimage]];
    } else {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"ERROR: %@", errorMessage);
    }
}


#pragma mark - ZBar Delegate Methods

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    id <NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    NSLog(@"TRACE: url server %@", symbol.data);
    
    self.displayStatusClient.text = NSLocalizedString(@"Connecting", @"");
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                  target:self
                                                selector:@selector(progressChange)
                                                userInfo:nil
                                                 repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLabelStatusConnection:)
                                                 name:TYPEDEFS_NOTIFICATIONSTATUS object:nil];
    
    [[StreamClient sharedInstance] initNetworkCommunication:symbol.data];
    [reader dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:TYPEDEFS_NUMBERSONLY] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= TYPEDEFS_CHARACTERLIMIT));
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return NO;
}


#pragma mark UITableView Delegate - Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"logCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [logs objectAtIndex:indexPath.row];
    
    return cell;
}


@end
