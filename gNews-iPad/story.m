//
//  story.m
//  gNews-iPad
//
//  Created by Ben on 2/13/13.
//  Copyright (c) 2013 com.Beni. All rights reserved.
//

#import "story.h"

@implementation story

@synthesize title = _title, imageURL = _imageURL, storyURL = _storyURL;

- (id)initWithData:(NSString *)title imageURL:(NSURL *)imageURL storyURL:(NSURL *) storyURL
{
    self = [super init];
    if (self) {
        _title = title;
        _imageURL = imageURL;
        _storyURL = storyURL;
        return self;
    }
    return nil;
    
}

@end
