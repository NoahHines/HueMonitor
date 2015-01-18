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

@end

@implementation MMWatchPixel

- (instancetype) initAtPoint:(CGPoint)location
{
    self = [super init];
    if(self)
    {
        location.y = [NSScreen mainScreen].frame.size.height - location.y;
        _location = location;
        _squareLength = 10;
        _pixelPerWidth = 2;
        
        CGDirectDisplayID id;
        CGGetDisplaysWithPoint(location, 1, &id, nil);
        _displayID = id;
    }
    return self;
}

- (NSArray *) getPixelArray
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
    
    return colors;
}

@end
