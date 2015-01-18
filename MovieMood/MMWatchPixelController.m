//
//  MMWatchPixelController.m
//  MovieMood
//
//  Created by Mark Linington on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "MMWatchPixelController.h"
#import "MMWatchPixel.h"
#import "MMHueLight.h"

@interface MMWatchPixelController ()

@property (strong, atomic) NSMutableArray *pixelArray;
@property (strong, atomic) NSTimer *monitorTimer;

@end

@implementation MMWatchPixelController

- (instancetype) init
{
    self = [super init];
    if(self)
    {
        _pixelArray = [[NSMutableArray alloc] init];
        _lightArray = [[NSMutableArray alloc] init];
        _pixelsPerLight = 3;
    }
    return self;
}

- (NSUInteger) pixelCount
{
    return self.pixelArray.count;
}

- (void) emptyPixelArray
{
    self.pixelArray = [[NSMutableArray alloc] init];
}

- (void) addPixelAtEvent:(NSEvent *)event
{
    CGPoint eventPoint = CGPointMake(event.locationInWindow.x, event.locationInWindow.y);
    MMWatchPixel *newPixel = [[MMWatchPixel alloc] initAtPoint:eventPoint];
    [self.pixelArray addObject:newPixel];
}

// This gets called repeatedly by an NSTimer when monitoring
- (void) repeatPixels:(NSTimer *) timer
{
    for(int i = 0; i < self.lightArray.count; i++)
    {
        NSArray *lightHotspots = [self.pixelArray subarrayWithRange:NSMakeRange(i*self.pixelsPerLight, self.pixelsPerLight)];
        NSMutableArray *pixelArray = [[NSMutableArray alloc] init];
        for (MMWatchPixel *pixel in lightHotspots) {
            [pixelArray addObjectsFromArray:[pixel getPixelArray]];
        }
        
        [pixelArray sortUsingComparator:^NSComparisonResult(NSColor *obj1, NSColor *obj2) {
            if (obj1.hueComponent > obj2.hueComponent) {
                return true;
            }
            return false;
        }];
        
        NSColor *color = pixelArray[pixelArray.count/2];
        
        [self.lightArray[i] sendColor:color];
        
    }
}

- (void) startMonitoring
{
    self.monitorTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(repeatPixels:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.monitorTimer forMode:NSDefaultRunLoopMode];
}

- (void) stopMonitoring
{
    [self.monitorTimer invalidate];
}


@end
