//
//  story.h
//  gNews-iPad
//
//  Created by Ben on 2/13/13.
//  Copyright (c) 2013 com.Beni. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface story : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, copy) NSURL *storyURL;

- (id)initWithData:(NSString *)title imageURL:(NSURL *)imageURL storyURL:(NSURL *) storyURL;

@end
