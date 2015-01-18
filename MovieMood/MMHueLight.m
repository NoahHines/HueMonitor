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
        _threshold = 0.05;
    }
    return self;
}

+ (void) getNumberOfLights:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))completionHandler
{
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
    
    CGFloat inputHue = 65535.0*[colorToSend hueComponent];
    CGFloat inputSat = 255.0*[colorToSend saturationComponent];
    CGFloat inputBri = 255.0*[colorToSend brightnessComponent];
        
    // URL is hardcoded to default Philips Hue url
    NSString * urlStr = [NSString stringWithFormat:@"http://10.0.1.2/api/newdeveloper/lights/%@/state/", self.lightID];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"PUT"];
    
    // Set the content type for the HTTP PUT request
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *httpBody = [[NSMutableDictionary alloc]init];
    httpBody[@"hue"] = [NSNumber numberWithInt:(int)inputHue];
    httpBody[@"sat"] = [NSNumber numberWithInt:(int)inputSat];
    httpBody[@"bri"] = [NSNumber numberWithInt:(int)inputBri];
    httpBody[@"transitiontime"] = [NSNumber numberWithInt:3];

    // If RGB < 0.06 turn off lights
    if ((colorToSend.redComponent < 0.06) && (colorToSend.greenComponent < 0.06) && (colorToSend.blueComponent < 0.06)) {
        NSLog(@"Good stuff.");
        httpBody[@"on"] = [NSNumber numberWithBool:NO];
    } else {
        httpBody[@"on"] = [NSNumber numberWithBool:YES];
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
