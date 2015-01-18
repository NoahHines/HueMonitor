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
        _pixelPerWidth = 1;
        
        CGDirectDisplayID id;
        CGGetDisplaysWithPoint(location, 1, &id, nil);
        _displayID = id;
        
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
    NSMutableArray *colors = [NSMutableArray array];
    
    CGImageRef image = CGDisplayCreateImageForRect(self.displayID, CGRectMake(self.location.x - self.squareLength/2, self.location.y - self.squareLength/2, self.squareLength, self.squareLength));
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
