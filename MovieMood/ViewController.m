//
//  ViewController.m
//  MovieMood
//
//  Created by Mark Linington on 1/16/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "ViewController.h"
@import AppKit;

@interface ViewController ()
@property (weak) IBOutlet NSTextField *numberOfHotspots;
@property (strong, atomic) NSMutableArray *hotspotArray;
@property (strong, atomic) id hotspotSelectionMonitor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberOfHotspots.stringValue = @"3";
    self.hotspotArray = [[NSMutableArray alloc] init];

    // Do any additional setup after loading the view.
}
- (IBAction)setHotspots:(id)sender {
    if(self.numberOfHotspots.stringValue.integerValue == 0)
    {
        // Not a valid number of hotspots maybe?
        return;
    }
    self.numberOfHotspots.editable = NO;
    self.hotspotArray = [[NSMutableArray alloc] init];
    // Hide window for hotspot selection
    [self.view.window orderOut:nil];
    
    self.hotspotSelectionMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent *event) {
        NSLog(@"%f,%f",event.locationInWindow.x,event.locationInWindow.y);
        [self.hotspotArray addObject:event];
        if(self.hotspotArray.count == self.numberOfHotspots.stringValue.integerValue)
        {
            [NSEvent removeMonitor:self.hotspotSelectionMonitor];
            [self.view.window orderFrontRegardless];
            self.numberOfHotspots.editable = YES;
        }
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
