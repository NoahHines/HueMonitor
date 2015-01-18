//
//  ViewController.m
//  MovieMood
//
//  Created by Mark Linington on 1/16/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "ViewController.h"
#import "MMHueRequest.h"
#import "MMWatchPixelController.h"
@import AppKit;

@interface ViewController ()
@property (weak) IBOutlet NSTextField *lightsLabel;

@property (strong, atomic) id hotspotSelectionMonitor;              // Used to remember the NSEvent global monitor
@property (strong, atomic) MMWatchPixelController *hotspotController;
@property (strong, atomic) NSMutableArray *validLights;             // Keeps track of a list of valid lights

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hotspotController = [[MMWatchPixelController alloc] init];
    
    self.validLights = [[NSMutableArray alloc] init];
    [MMHueRequest getNumberOfLights:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *lights = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [lights enumerateKeysAndObjectsUsingBlock:^(NSString *lightID, NSDictionary *light, BOOL *stop) {
            if([light[@"state"][@"reachable"] boolValue])
            {
                [self.validLights addObject:[NSNumber numberWithInteger:lightID.integerValue ]];
                self.lightsLabel.stringValue = [NSString stringWithFormat:@"%lu lights found", self.validLights.count];
            }
        }];
    }];

    // Do any additional setup after loading the view.
}
- (IBAction)setHotspots:(id)sender {
    [self.hotspotController emptyPixelArray];
    // Hide window for hotspot selection
    [self.view.window orderOut:nil];
    
    self.hotspotSelectionMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent *event) {
        //NSLog(@"%f,%f",event.locationInWindow.x,event.locationInWindow.y);
        [self.hotspotController addPixelAtEvent:event];
        if([self.hotspotController pixelCount] == self.validLights.count)
        {
            [NSEvent removeMonitor:self.hotspotSelectionMonitor];
            [self.view.window orderFrontRegardless];
        }
    }];
}
- (IBAction)toggleMonitoring:(NSButton *)sender {
    if([sender.title isEqualToString:@"Start Monitoring"])
    {
        sender.title = @"Stop Monitoring";
        [self.hotspotController startMonitoring];
    }
    else
    {
        sender.title = @"Start Monitoring";
        [self.hotspotController stopMonitoring];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
