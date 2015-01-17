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
    NSPoint origin = NSMakePoint(0, 0);
    NSColor *topColor = NSReadPixel(origin);
    NSLog(@"%@",topColor);

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
