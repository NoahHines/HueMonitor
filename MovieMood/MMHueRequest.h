//
//  MMHueRequest.h
//  MovieMood
//
//  Created by Noah Hines on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;

@interface MMHueRequest : NSObject

+ (void)sendColor:(NSColor *)colorToSend toLights:(NSArray *)lightsArray;

@end
