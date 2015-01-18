//
//  ViewController.m
//  MovieMood
//
//  Created by Mark Linington on 1/16/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "ViewController.h"
#import "MMHueLight.h"
#import "MMWatchPixelController.h"
@import AppKit;

@interface ViewController ()
@property (weak) IBOutlet NSTextField *lightsLabel;

@property (strong, atomic) id hotspotSelectionMonitor;              // Used to remember the NSEvent global monitor
@property (strong, atomic) MMWatchPixelController *hotspotController;
@property (weak) IBOutlet NSTextField *hotspotsPerLight;
@property (weak) IBOutlet NSBox *lightWellHolder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hotspotController = [[MMWatchPixelController alloc] init];
    
    [MMHueLight getNumberOfLights:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *lights = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [lights enumerateKeysAndObjectsUsingBlock:^(NSString *lightID, NSDictionary *light, BOOL *stop) {
            if([light[@"state"][@"reachable"] boolValue])
            {
                NSNumber *idNumber = [NSNumber numberWithInteger:lightID.integerValue];
                MMHueLight *newLight = [[MMHueLight alloc] initWithID:idNumber];
                NSColorWell *lightWell;
                if (self.hotspotController.lightArray.count == 0) {
                    lightWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(self.lightWellHolder.frame.origin.x + 10, self.lightWellHolder.frame.origin.y+self.lightWellHolder.frame.size.height-20-23, 44, 23)];
                }
                else
                {
                    MMHueLight *lastLight = self.hotspotController.lightArray.lastObject;
                    lightWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(self.lightWellHolder.frame.origin.x + 10, lastLight.colorWell.frame.origin.y-23-15, 44, 23)];
                }
                lightWell.enabled = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view addSubview:lightWell];
                });
                NSLog(@"%@",lightWell);
                newLight.colorWell = lightWell;
                [self.hotspotController.lightArray addObject:newLight];
                self.lightsLabel.stringValue = [NSString stringWithFormat:@"%lu lights found", self.hotspotController.lightArray.count];
            }
        }];
    }];

    // Do any additional setup after loading the view.
}

- (IBAction)setHotspots:(id)sender {
    self.hotspotController.pixelsPerLight = (int)self.hotspotsPerLight.stringValue.integerValue;
    [self.hotspotController emptyPixelArray];
    // Hide window for hotspot selection
    [self.view.window orderOut:nil];
    
    self.hotspotSelectionMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent *event) {
        //NSLog(@"%f,%f",event.locationInWindow.x,event.locationInWindow.y);
        [self.hotspotController addPixelAtEvent:event];
        if([self.hotspotController pixelCount] == self.hotspotController.lightArray.count * self.hotspotController.pixelsPerLight)
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
- (IBAction)toggleCoyoteMode:(NSButton *)sender {
    if([sender.title isEqualToString:@"Coyote Mode: Off"])
    {
        sender.title = @"Coyote Mode: On";
        self.hotspotController.coyoteMode = YES;
    }
    else
    {
        sender.title = @"Coyote Mode: Off";
        self.hotspotController.coyoteMode = NO;
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

@end
