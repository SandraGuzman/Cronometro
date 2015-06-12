//
//  HelpViewController.m
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 05/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    imagesSettings = [[NSArray alloc] initWithObjects:
                      @"1Main",
                      @"2Settings",
                      @"3Server",
                      @"4Client",
                      @"5ClientSuccess",
                      @"6ServerNewDevice",
                      @"7General",
                      @"8ServerMain",
                      @"9ServerControls",
                      @"10ClientMain", nil];
    
    labelSettings = [[NSArray alloc] initWithObjects:
                     NSLocalizedString(@"Label1", @""),
                     NSLocalizedString(@"Label2", @""),
                     NSLocalizedString(@"Label3", @""),
                     NSLocalizedString(@"Label4", @""),
                     NSLocalizedString(@"Label5", @""),
                     NSLocalizedString(@"Label6", @""),
                     NSLocalizedString(@"Label7", @""),
                     NSLocalizedString(@"Label8", @""),
                     NSLocalizedString(@"Label9", @""),
                     NSLocalizedString(@"Label10", @""),nil];
    
    self.display.text = labelSettings[0];
    int x = 0;
    
    for (int i=0; i < imagesSettings.count; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, 0, self.slider.frame.size.width, self.slider.frame.size.height)];
        view.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(40, 5, self.slider.frame.size.width - 80, self.slider.frame.size.height - 10)];
        [imageView setImage: [UIImage imageNamed:imagesSettings[i]]];
        [view addSubview: imageView];
        
        [self.slider addSubview: view];
        x = x + view.frame.size.width;
        self.slider.contentSize = CGSizeMake(x, 0);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)closePopup:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
    int page = (self.slider.contentOffset.x / self.slider.frame.size.width);
    self.display.text = labelSettings[page];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];}

@end
