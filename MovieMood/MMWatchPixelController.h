//
//  MMWatchPixelController.h
//  MovieMood
//
//  Created by Mark Linington on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;

@interface MMWatchPixelController : NSObject

- (instancetype) init;
- (NSUInteger) pixelCount;
- (void) addPixelAtEvent:(NSEvent *)event;
- (void) emptyPixelArray;
- (void) startMonitoring;
- (void) stopMonitoring;

@end
