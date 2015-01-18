//
//  MMHueRequest.h
//  MovieMood
//
//  Created by Noah Hines on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;

@interface MMHueLight : NSObject

- (instancetype) initWithID:(NSNumber *)id;
- (BOOL) sendColor:(NSColor *)colorToSend;
+ (void) getNumberOfLights:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))completionHandler;

@end
