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
@property (strong, atomic) dispatch_source_t monitorTimer;

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
        _coyoteMode = NO;
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
//    NSLog(@"Hit");
//    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
//    CGPoint newLocation = CGPointMake([NSEvent mouseLocation].x, [NSScreen mainScreen].frame.size.height - [NSEvent mouseLocation].y+1);
//    CGEventRef mouseMove = CGEventCreateMouseEvent(source, kCGEventMouseMoved, newLocation, 0);
//    CGEventPost(kCGHIDEventTap, mouseMove);
//    CFRelease(mouseMove);
//    CFRelease(source);

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
        CGFloat hue = self.coyoteMode ? (112.0/360.0) : [pixelArray[pixelArray.count/2] hueComponent];
        [pixelArray sortUsingComparator:^NSComparisonResult(NSColor *obj1, NSColor *obj2) {
            if (obj1.saturationComponent > obj2.saturationComponent) {
                return true;
            }
            return false;
        }];
        CGFloat saturation = self.coyoteMode ? 0.86 : [pixelArray[pixelArray.count/2] saturationComponent];
        [pixelArray sortUsingComparator:^NSComparisonResult(NSColor *obj1, NSColor *obj2) {
            if (obj1.brightnessComponent > obj2.brightnessComponent) {
                return true;
            }
            return false;
        }];
        CGFloat brightness = [pixelArray[pixelArray.count/2] brightnessComponent];
        
        NSColor *color = [NSColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        [self.lightArray[i] sendColor:color];
        
    }
}

- (void) startMonitoring
{
    if(!self.monitorTimer)
    {
        self.monitorTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, DISPATCH_TIMER_STRICT, dispatch_get_main_queue());
        dispatch_source_set_event_handler(self.monitorTimer, ^{
            [self repeatPixels:nil];
        });
        dispatch_source_set_timer(self.monitorTimer, dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), 0.25 * NSEC_PER_SEC, 0.125 * NSEC_PER_SEC);
    }
    dispatch_resume(self.monitorTimer);
    
    
//    self.monitorTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(repeatPixels:) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.monitorTimer forMode:NSDefaultRunLoopMode];
}

- (void) stopMonitoring
{
    dispatch_suspend(self.monitorTimer);
}


@end
