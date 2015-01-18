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
@property double threshold;
@property (strong, atomic) NSColor *previousSetColor;
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
        _pixelPerWidth = 1;
        
        CGDirectDisplayID id;
        CGGetDisplaysWithPoint(location, 1, &id, nil);
        _displayID = id;
        
        _lastUpdates = [[NSMutableArray alloc] init];
        _threshold = 0.05;
    }
    return self;
}

- (void) updateCurrentColor
{
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    CGRect captureLocation = CGRectMake(self.location.x - self.squareLength/2,
                                        self.location.y - self.squareLength/2,
                                        self.squareLength, self.squareLength);
    
    CGImageRef image = CGDisplayCreateImageForRect(self.displayID, captureLocation);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
    CGImageRelease(image);

    for (int i = 0; i <= self.squareLength; i+=self.pixelPerWidth) {
        for (int j = 0; j <= self.squareLength; j+=self.pixelPerWidth) {
            [colors addObject:[bitmap colorAtX:i y:j]];
        }
    }

    [colors sortUsingComparator:^NSComparisonResult(NSColor *obj1, NSColor *obj2) {
        if (obj1.hueComponent > obj2.hueComponent) {
            return true;
        }
        return false;
    }];
    
    NSColor *color = colors[colors.count/2];
    
    if (color.saturationComponent < 0.2) {
        color = [NSColor colorWithCalibratedHue:color.hueComponent saturation:color.saturationComponent brightness:color.brightnessComponent alpha:1];
        
    } else {
        color = [NSColor colorWithCalibratedHue:color.hueComponent saturation:color.saturationComponent*2 brightness:color.brightnessComponent alpha:1];
    }
    if(!self.previousSetColor) self.previousSetColor = color;
    self.currentColor = color;
}

- (void) hasSentColor
{
    self.previousSetColor = self.currentColor;
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
    
    if((fabs(self.previousSetColor.redComponent - self.currentColor.redComponent)) > self.threshold)
        return true;
    if((fabs(self.previousSetColor.greenComponent - self.currentColor.greenComponent)) > self.threshold)
        return true;
    if((fabs(self.previousSetColor.blueComponent - self.currentColor.blueComponent)) > self.threshold)
        return true;
    return false;
}

@end
