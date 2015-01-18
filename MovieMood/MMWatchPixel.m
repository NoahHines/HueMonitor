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
        _pixelPerWidth = 10;
        
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
    CGImageRef image = CGDisplayCreateImageForRect(self.displayID, CGRectMake(self.location.x - self.squareLength/2, self.location.y - self.squareLength/2, self.squareLength/2, self.squareLength/2));
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    int currHue = 0;
    int currSat = 0;
    int currBri = 0;
    for (int i = -1*self.squareLength/2; i <= self.squareLength/2; i+=self.pixelPerWidth) {
        for (int j = self.squareLength/2; j >= -1*self.squareLength/2; j-=self.pixelPerWidth) {
            currHue += [[bitmap colorAtX:i y:j] hueComponent]*65280.0;
            currSat += [[bitmap colorAtX:i y:j] saturationComponent]*255.0;
            currBri += [[bitmap colorAtX:i y:j] brightnessComponent]*255.0;
            
            NSLog(@"Here is the currBri: %i", currBri);
        }
    }
    int dividend = self.squareLength/(self.pixelPerWidth) + 1;
    currHue /= pow(dividend, 2);
    currSat /= pow(dividend, 2);
    currBri /= pow(dividend, 2);
    
    NSColor *color = [NSColor colorWithCalibratedHue:currHue saturation:currSat brightness:currBri alpha:1.0];
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
