//
//  MMHueRequest.m
//  MovieMood
//
//  Created by Noah Hines on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "MMHueLight.h"

@interface MMHueLight ()

@property (strong, readonly) NSNumber *lightID;

@property (strong, atomic) NSColor *previousSetColor;
@property (strong, atomic) NSMutableArray *lastUpdates;
@property double threshold;

@end

@implementation MMHueLight

- (instancetype) initWithID:(NSNumber *)id
{
    self = [super init];
    if(self)
    {
        _lightID = id;
        _lastUpdates = [[NSMutableArray alloc] init];
        _threshold = 0.03;
    }
    return self;
}

// Send asynchronous request to hue bulbs
+ (void) getNumberOfLights:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))completionHandler
{
    // Hardcoded bridge IP and username.
    // Follow instructions at http://www.developers.meethue.com/documentation/getting-started to create your username
    NSURL *url = [NSURL URLWithString:@"http://10.0.1.2/api/newdeveloper/lights"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:completionHandler];
}

- (BOOL) sendColor:(NSColor *)colorToSend {
    if(self.previousSetColor != nil)
    {
        if( (fabs(self.previousSetColor.redComponent - colorToSend.redComponent)) < self.threshold &&
            (fabs(self.previousSetColor.greenComponent - colorToSend.greenComponent)) < self.threshold &&
            (fabs(self.previousSetColor.blueComponent - colorToSend.blueComponent)) < self.threshold)
            return NO;
    }
    if(self.lastUpdates.count > 0)
    {
        NSTimeInterval totalTimeInterval = 0;
        for(int i = 1; i < self.lastUpdates.count; i++)
        {
            totalTimeInterval += [self.lastUpdates[i-1] timeIntervalSinceDate:self.lastUpdates[i]];
        }
        totalTimeInterval += [self.lastUpdates.lastObject timeIntervalSinceNow];
        totalTimeInterval /= self.lastUpdates.count;
        NSLog(@"%f", totalTimeInterval);
        if(totalTimeInterval > -0.75) return NO;
    }
    [self.lastUpdates addObject:[[NSDate alloc] init]];
    if(self.lastUpdates.count > 20) [self.lastUpdates removeObjectAtIndex:0];
    
    self.previousSetColor = colorToSend;
    
    // Philips API's hue is from 0 to 65535.
    CGFloat inputHue = 65535.0*[colorToSend hueComponent];
    // Philips API's saturation is from 0 to 255
    CGFloat inputSat = 255.0*[colorToSend saturationComponent];
    // Philips API's brightness is from 0 to 255
    CGFloat inputBri = 255.0*[colorToSend brightnessComponent];
        
    // URL is hardcoded to default Philips Hue url
    NSString * urlStr = [NSString stringWithFormat:@"http://10.0.1.2/api/newdeveloper/lights/%@/state/", self.lightID];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    // Send HTTP Put request to Philips hue restful api
    [request setHTTPMethod:@"PUT"];
    
    // Set the content type for the HTTP PUT request
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *httpBody = [[NSMutableDictionary alloc]init];
    httpBody[@"hue"] = [NSNumber numberWithInt:(int)inputHue];
    httpBody[@"sat"] = [NSNumber numberWithInt:(int)inputSat];
    httpBody[@"bri"] = [NSNumber numberWithInt:(int)inputBri];
    // Default transition time is 4. Speeding it up a bit makes it more responsive.
    httpBody[@"transitiontime"] = [NSNumber numberWithInt:3];

    // If RGB < 0.06, turn off lights
    if ((colorToSend.redComponent < 0.06) && (colorToSend.greenComponent < 0.06) && (colorToSend.blueComponent < 0.06)) {
        NSLog(@"Good stuff.");
        httpBody[@"on"] = [NSNumber numberWithBool:NO];
        self.colorWell.color = [NSColor blackColor];
    } else {
        httpBody[@"on"] = [NSNumber numberWithBool:YES];
        self.colorWell.color = colorToSend;
    }
    
    // Make sure that the above dictionary can be converted to JSON data
    if([NSJSONSerialization isValidJSONObject:httpBody])
    {
        // Convert the JSON object to NSData
        NSData * httpBodyData = [NSJSONSerialization dataWithJSONObject:httpBody options:0 error:nil];
        // set the http body
        [request setHTTPBody:httpBodyData];
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    }];
    return YES;
}

@end
