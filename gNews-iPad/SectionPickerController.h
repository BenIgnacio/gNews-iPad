//
//  SectionPickerController.h
//  gNews-iPad
//
//  Created by Ben on 2/19/13.
//  Copyright (c) 2013 com.Beni. All rights reserved.
//

#import <UIKit/UIKit.h>

#define sectionHeadlines @"Headlines"
#define sectionWorld @"World"
#define sectionBusiness @"Business"
#define sectionNation @"Nation"
#define sectionTech @"Tech & Science"
#define sectionPolitics @"Politics"
#define sectionEntertainment @"Entertainment"
#define sectionSports @"Sports"
#define sectionHealth @"Health"


@protocol SectionPickerDelegate <NSObject>
- (void)sectionSelected:(NSString *)section;
@end

@interface SectionPickerController : UITableViewController {
    NSMutableArray *_sections;
    id<SectionPickerDelegate> _delegate;
}

@property (nonatomic, retain) NSMutableArray *sections;
@property (retain, nonatomic) id<SectionPickerDelegate> delegate;


@end
