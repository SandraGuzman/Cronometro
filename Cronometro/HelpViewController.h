//
//  HelpViewController.h
//  Cronometro
//
//  Created by Sandra Guzmán Bautista on 05/06/15.
//  Copyright (c) 2015 onikom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController <UIScrollViewDelegate> {
    NSArray *imagesSettings;
    NSArray *labelSettings;
}

@property (weak, nonatomic) IBOutlet UIScrollView *slider;
@property (weak, nonatomic) IBOutlet UILabel *display;


- (IBAction)closePopup:(id)sender;

@end
