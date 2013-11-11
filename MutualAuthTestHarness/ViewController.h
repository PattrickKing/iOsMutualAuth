//
//  ViewController.h
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/9/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (retain, nonatomic) NSURLConnection *connection;

//OSStatus extractIdentityAndTrust(CFDataRef inPKCS12Data, SecIdentityRef *outIdentity, SecTrustRef *outTrust, CFStringRef keyPassword);

OSStatus extractIdentityAndTrust(CFDataRef inPKCS12Data, SecIdentityRef *outIdentity, SecTrustRef *outTrust, CFStringRef keyPassword);

/*
- (OSStatus*) extractIdentityAndTrust(CFDataRef inPKCS12Data,
                                      SecIdentityRef *outIdentity,
                                      SecTrustRef *outTrust,
                                      CFStringRef keyPassword);
*/
@end
