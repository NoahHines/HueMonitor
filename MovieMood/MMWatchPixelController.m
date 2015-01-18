//
//  MMWatchPixelController.m
//  MovieMood
//
//  Created by Mark Linington on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "MMWatchPixelController.h"
#import "MMWatchPixel.h"
#import "MMHueRequest.h"

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
        self.pixelArray = [[NSMutableArray alloc] init];
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
    for(int i = 0; i < self.pixelArray.count; i++)
    {
        [self.pixelArray[i] updateCurrentColor];
        if([self.pixelArray[i] shouldSendUpdate])
            [MMHueRequest sendColor:[self.pixelArray[i] currentColor] toLights:@[[NSNumber numberWithInt:i+1]]];
    }
}

- (void) startMonitoring
{
    self.monitorTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeatPixels:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.monitorTimer forMode:NSDefaultRunLoopMode];
}

- (void) stopMonitoring
{
    [self.monitorTimer invalidate];
}


@end
