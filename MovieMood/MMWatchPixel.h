//
//  MMWatchPixel.h
//  MovieMood
//
//  Created by Mark Linington on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;

@interface MMWatchPixel : NSObject

@property (readonly) CGPoint location;

- (instancetype) initAtPoint:(CGPoint)location;
- (NSColor *) getCurrentColor;

@end
