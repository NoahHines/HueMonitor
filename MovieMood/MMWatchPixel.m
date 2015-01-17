//
//  MMWatchPixel.m
//  MovieMood
//
//  Created by Mark Linington on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "MMWatchPixel.h"

@interface MMWatchPixel ()

@property CGDirectDisplayID displayID;
@property (strong, atomic) NSColor *previousSetColor;
@property double threshold;

@end

@implementation MMWatchPixel

- (instancetype) initAtPoint:(CGPoint)location
{
    self = [super init];
    if(self)
    {
        location.y = [NSScreen mainScreen].frame.size.height - location.y;
        _location = location;
        
        CGDirectDisplayID id;
        CGGetDisplaysWithPoint(location, 1, &id, nil);
        _displayID = id;
        
        _threshold = 0.01;
    }
    return self;
}

- (NSColor *) getCurrentColor:(NSTimer *)timer
{
    return [self getCurrentColor];
}

- (NSColor *) getCurrentColor
{
    CGImageRef image = CGDisplayCreateImageForRect(self.displayID, CGRectMake(self.location.x, self.location.y, 1, 1));
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
    CGImageRelease(image);
    NSColor *color = [bitmap colorAtX:0 y:0];
    if(!self.previousSetColor) self.previousSetColor = color;
    return color;
}

- (void) updateColor
{
    self.previousSetColor = [self getCurrentColor];
}

- (BOOL) shouldSendUpdate
{
    if((fabs(self.previousSetColor.redComponent - self.getCurrentColor.redComponent)) > self.threshold)
        return true;
    if((fabs(self.previousSetColor.greenComponent - self.getCurrentColor.greenComponent)) > self.threshold)
        return true;
    if((fabs(self.previousSetColor.blueComponent - self.getCurrentColor.blueComponent)) > self.threshold)
        return true;
    return false;
}

@end
