//
//  ViewController.m
//  MovieMood
//
//  Created by Mark Linington on 1/16/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "ViewController.h"
#import "MMHueRequest.h"
@import AppKit;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //216	57	52
    
    NSColor *myColor = [NSColor colorWithCalibratedRed:(216/255.0) green:(57/255.0) blue:(52/255.0) alpha:1.0f];

    [MMHueRequest sendColor:myColor];
    

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
