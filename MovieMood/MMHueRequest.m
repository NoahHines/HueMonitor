//
//  MMHueRequest.m
//  MovieMood
//
//  Created by Noah Hines on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "MMHueRequest.h"

@implementation MMHueRequest

+ (void)sendColor:(NSColor *)colorToSend {
    
    //colorToSend = [NSColor colorWithCalibratedRed:1 green:0 blue:0 alpha:1];
    
    //NSLog(@"hue! %g saturation! %g brightness! %g", [colorToSend hueComponent], [colorToSend saturationComponent], [colorToSend brightnessComponent]);

          
    CGFloat inputHue = 65535.0*[colorToSend hueComponent];
    CGFloat inputSat = 255.0*[colorToSend saturationComponent];
    CGFloat inputBri = 255.0*[colorToSend brightnessComponent];
    
    NSString * urlStr = [NSString stringWithFormat:@"http://10.0.1.2/api/newdeveloper/groups/0/action"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"PUT"];
    
    // Set the content type
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *httpBody = [[NSMutableDictionary alloc]init];
    //[httpBody setObject:0 forKey:@"hue"];
    httpBody[@"hue"] = [NSNumber numberWithInt:(int)inputHue];
    httpBody[@"sat"] = [NSNumber numberWithInt:(int)inputSat];
    httpBody[@"bri"] = [NSNumber numberWithInt:(int)inputBri];
    
    NSLog(@"%@", httpBody);
    
    // Make sure that the above dictionary can be converted to JSON data
    if([NSJSONSerialization isValidJSONObject:httpBody])
    {
        // Convert the JSON object to NSData
        NSData * httpBodyData = [NSJSONSerialization dataWithJSONObject:httpBody options:0 error:nil];
        // set the http body
        [request setHTTPBody:httpBodyData];
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"Complete!");
    }];
    
}


@end
