//
//  MasterViewController.h
//  gNews-iPad
//
//  Created by Ben on 2/13/13.
//  Copyright (c) 2013 com.Beni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionPickerController.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <SectionPickerDelegate>
{
    SectionPickerController *_sectionPicker;
    UIPopoverController *_sectionPickerPopover;
}
- (IBAction)setSectionButtonTapped:(id)sender;


@property (strong, nonatomic) DetailViewController *detailViewController;
@property (retain, nonatomic) SectionPickerController *sectionPicker;
@property (retain, nonatomic) UIPopoverController *sectionPickerPopover;
@property (retain, nonatomic) NSString *sectionChar;

@end
