//
//  MMHueRequest.m
//  MovieMood
//
//  Created by Noah Hines on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "MMHueRequest.h"

@implementation MMHueRequest

/* function sendColor
   takes an NSColor object, converts it to Hue/Saturation/Brightness values
   and sends it to the light that has the id of the second parameter (lightId)
 */
+ (void)sendColor:(NSColor *)colorToSend toLights:(NSArray *)lightsArray {
    
    CGFloat inputHue = 65535.0*[colorToSend hueComponent];
    CGFloat inputSat = 255.0*[colorToSend saturationComponent];
    CGFloat inputBri = 255.0*[colorToSend brightnessComponent];
    
    // URL is hardcoded to default Philips Hue url
    //NSString * urlStr = [NSString stringWithFormat:@"http://10.0.1.2/api/newdeveloper/groups/0/action"];
    
    for (NSNumber *currentId in lightsArray) {
        
        // URL is hardcoded to default Philips Hue url
        
        NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        
        [request setHTTPMethod:@"PUT"];
        
        // Set the content type for the HTTP PUT request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSMutableDictionary *httpBody = [[NSMutableDictionary alloc]init];
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
            NSLog(@"Submitted lightbulb ID #%@", currentId);
        }];
        
    }
    
}
@end
