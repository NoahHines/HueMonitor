//
//  MMHueRequest.m
//  MovieMood
//
//  Created by Noah Hines on 1/17/15.
//  Copyright (c) 2015 TeamHackers. All rights reserved.
//

#import "MMHueRequest.h"

@implementation MMHueRequest

+ (void)setColorConnectLights:(NSNumber *)hueValue {
    
    NSString * urlStr = [NSString stringWithFormat:@"http://10.0.1.2/api/newdeveloper/groups/0/action"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"PUT"];
    
    // Set the content type
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *httpBody = [[NSMutableDictionary alloc]init];
    //[httpBody setObject:0 forKey:@"hue"];
    httpBody[@"hue"] = hueValue;
    
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
