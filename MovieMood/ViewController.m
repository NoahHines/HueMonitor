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
    NSPoint origin = NSMakePoint(100, 100);
    //[self.focusView lockFocus];
    //NSColor *topColor = NSReadPixel(origin);
    //[self.view unlockFocus];
    
    CGDirectDisplayID ids[10];
    CGGetDisplaysWithPoint(origin, 10, ids, nil);
    CGImageRef image = CGDisplayCreateImageForRect(ids[0], CGRectMake(0, 0, 1, 1));
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
    NSColor *color = [bitmap colorAtX:0 y:0];
    
    NSLog(@"%f, %f, %f",color.redComponent,color.greenComponent,color.blueComponent);

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
