//
//  ViewController.m
//  MovieMood
//
//  Created by Mark Linington on 1/16/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "ViewController.h"
@import AppKit;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSColor *color = [self getColorFromMouseCursor];
    NSLog(@"%f, %f, %f",color.redComponent,color.greenComponent,color.blueComponent);
    
    dispatch_queue_t colorQueue = dispatch_queue_create("colorQueue", DISPATCH_QUEUE_SERIAL);

    dispatch_async(colorQueue, ^{
        [self constantlyGetColor];
    });

    // Do any additional setup after loading the view.
}

- (void) constantlyGetColor
{
    while (1) {
        NSColor *color = [self getColorFromMouseCursor];
        NSLog(@"%f, %f, %f",color.redComponent,color.greenComponent,color.blueComponent);
    }
}

- (NSColor *) getColorFromMouseCursor {
    CGPoint mousePoint = NSPointToCGPoint([NSEvent mouseLocation]);
    mousePoint.y = [NSScreen mainScreen].frame.size.height - mousePoint.y;
    
    CGDirectDisplayID ids;
    CGGetDisplaysWithPoint(mousePoint, 1, &ids, nil);
    CGImageRef image = CGDisplayCreateImageForRect(ids, CGRectMake(mousePoint.x, mousePoint.y, 1, 1));
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
    CGImageRelease(image);
    NSColor *color = [bitmap colorAtX:0 y:0];
    return color;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
