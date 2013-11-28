//
//  BZHTTPClient.m
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/27/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import "BZHTTPClient.h"

@implementation BZHTTPClient

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSString *authMethod = challenge.protectionSpace.authenticationMethod;
    
    if ([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSLog(@"Server Auth");
    } else if ([authMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        NSLog(@"Client Auth");
    }
}

@end
