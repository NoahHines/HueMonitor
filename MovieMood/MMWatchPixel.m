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
@property int squareLength;
@property int pixelPerWidth;
@property (strong, atomic) NSColor *previousSetColor;
@property double threshold;
@property (strong, atomic) NSMutableArray *lastUpdates;

@end

@implementation MMWatchPixel

- (instancetype) initAtPoint:(CGPoint)location
{
    self = [super init];
    if(self)
    {
        location.y = [NSScreen mainScreen].frame.size.height - location.y;
        _location = location;
        _squareLength = 20;
        _pixelPerWidth = 5;
        
        CGDirectDisplayID id;
        CGGetDisplaysWithPoint(location, 1, &id, nil);
        _displayID = id;
        
        _lastUpdates = [[NSMutableArray alloc] init];
        _threshold = 0.05;
    }
    return self;
}

- (NSColor *) getCurrentColor:(NSTimer *)timer
{
    return [self getCurrentColor];
}

- (NSColor *) getCurrentColor
{
    CGImageRef image = CGDisplayCreateImageForRect(self.displayID, CGRectMake(self.location.x - self.squareLength/2, self.location.y - self.squareLength/2, self.squareLength/2, self.squareLength/2));
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    double currRed = 0;
    double currGreen = 0;
    double currBlue = 0;
    for (int i = -1*self.squareLength/2; i <= self.squareLength/2; i+=self.pixelPerWidth) {
        for (int j = self.squareLength/2; j >= -1*self.squareLength/2; j-=self.pixelPerWidth) {
            currRed += [[bitmap colorAtX:i y:j] redComponent];
            currGreen += [[bitmap colorAtX:i y:j] greenComponent];
            currBlue += [[bitmap colorAtX:i y:j] blueComponent];
        }
    }
    int dividend = self.squareLength/(self.pixelPerWidth) + 1;
    currRed /= pow(dividend, 2);
    currGreen /= pow(dividend, 2);
    currBlue /= pow(dividend, 2);
    
    
    NSColor *color = [NSColor colorWithCalibratedRed:currRed green:currGreen blue:currBlue alpha:1.0];
    
    if (color.saturationComponent < 0.2) {
        color = [NSColor colorWithCalibratedHue:color.hueComponent saturation:color.saturationComponent brightness:color.brightnessComponent alpha:1];
        
    } else {
        color = [NSColor colorWithCalibratedHue:color.hueComponent saturation:color.saturationComponent*2 brightness:color.brightnessComponent alpha:1];
    }
    if(!self.previousSetColor) self.previousSetColor = color;
    return color;
}

- (void) updateColor
{
    self.previousSetColor = [self getCurrentColor];
    [self.lastUpdates addObject:[[NSDate alloc] init]];
    if(self.lastUpdates.count > 20) [self.lastUpdates removeObjectAtIndex:0];
}

- (BOOL) shouldSendUpdate
{
    if(self.lastUpdates.count > 0)
    {
        NSTimeInterval totalTimeInterval = 0;
        for(int i = 1; i < self.lastUpdates.count; i++)
        {
            totalTimeInterval += [self.lastUpdates[i-1] timeIntervalSinceDate:self.lastUpdates[i]];
        }
        totalTimeInterval += [self.lastUpdates.lastObject timeIntervalSinceNow];
        totalTimeInterval /= self.lastUpdates.count;
        NSLog(@"%f", totalTimeInterval);
        if(totalTimeInterval > -0.75) return false;
    }
    
    if((fabs(self.previousSetColor.redComponent - self.getCurrentColor.redComponent)) > self.threshold)
        return true;
    if((fabs(self.previousSetColor.greenComponent - self.getCurrentColor.greenComponent)) > self.threshold)
        return true;
    if((fabs(self.previousSetColor.blueComponent - self.getCurrentColor.blueComponent)) > self.threshold)
        return true;
    return false;
}

@end
