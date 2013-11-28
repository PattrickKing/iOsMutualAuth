//
//  ViewController.m
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/9/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)basicAuthForRequest:(NSMutableURLRequest *)request withUsername:(NSString *)username andPassword:(NSString *)password
{
    // Cast username and password as CFStringRefs via Toll-Free Bridging
    CFStringRef usernameRef = (__bridge CFStringRef)username;
    CFStringRef passwordRef = (__bridge CFStringRef)password;
    
    // Reference properties of the NSMutableURLRequest
    CFHTTPMessageRef authoriztionMessageRef = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (__bridge CFStringRef)[request HTTPMethod], (__bridge CFURLRef)[request URL], kCFHTTPVersion1_1);
    
    // Encodes usernameRef and passwordRef in Base64
    CFHTTPMessageAddAuthentication(authoriztionMessageRef, nil, usernameRef, passwordRef, kCFHTTPAuthenticationSchemeBasic, FALSE);
    
    // Creates the 'Basic - <encoded_username_and_password>' string for the HTTP header
    CFStringRef authorizationStringRef = CFHTTPMessageCopyHeaderFieldValue(authoriztionMessageRef, CFSTR("Authorization"));
    
    // Add authorizationStringRef as value for 'Authorization' HTTP header
    [request setValue:(__bridge NSString *)authorizationStringRef forHTTPHeaderField:@"Authorization"];
    
    // Cleanup
    CFRelease(authorizationStringRef);
    CFRelease(authoriztionMessageRef);
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSString *authMethod = challenge.protectionSpace.authenticationMethod;
    
    if ([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        // determine if server cert is correct
        BOOL shouldTrustServer = [self shouldTrustServer:challenge.protectionSpace.serverTrust];
        
        if (shouldTrustServer) {
            [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
            return;
        }
        
        [challenge.sender cancelAuthenticationChallenge:challenge];
        NSLog(@"shouldTrustServer failed.");
        return;
        
    } else if ([authMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        
        // gets a certificate from local resources
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"buzzClient" ofType:@"p12"];
        NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
        CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
        
        // Import .p12 data
        CFArrayRef keyref = NULL;
        OSStatus importStatus = SecPKCS12Import(inPKCS12Data,
                                                (__bridge CFDictionaryRef)[NSDictionary
                                                                           dictionaryWithObject:@"password"
                                                                           forKey:(__bridge id)kSecImportExportPassphrase],
                                                &keyref);
        if (importStatus != noErr) {
            [challenge.sender cancelAuthenticationChallenge:challenge];
            NSLog(@"SecPKCS12Import failed.");
            return;
        }
        
        // Identity
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(keyref, 0);
        SecIdentityRef identityRef = (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                                                          kSecImportItemIdentity);
        
        // Cert
        SecCertificateRef cert = NULL;
        OSStatus copyStatus = SecIdentityCopyCertificate(identityRef, &cert);
        
        if (copyStatus != noErr) {
            [challenge.sender cancelAuthenticationChallenge:challenge];
            NSLog(@"SecIdentityCopyCertificate failed.");
            return;
        }
        
        // the certificates array, containing the identity then the root certificate
        NSArray *myCerts = [[NSArray alloc] initWithObjects:(__bridge id)identityRef, (__bridge id)cert, nil];
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identityRef certificates:myCerts persistence:NSURLCredentialPersistencePermanent];
        
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
        return;
    }
    
    [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
}

/**
 * Method name: shouldTrustServer
 * Description: Determines if the remote host's (SecTrustRef) certificate matches the bundled server DER certificate.
 * Parameters: SecTrustRef
 */
- (BOOL)shouldTrustServer:(SecTrustRef)serverTrust {
    
    // Load up the bundled server public key certificate.
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"buzzServer" ofType:@"der"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    CFDataRef certDataRef = (__bridge_retained CFDataRef)certData;
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, certDataRef);
    
    // Establish a chain of trust anchored on our bundled certificate.
    CFArrayRef certArrayRef = CFArrayCreate(NULL, (void *)&cert, 1, NULL);
    SecTrustSetAnchorCertificates(serverTrust, certArrayRef);
    
    // Create a policy that ignores the host name
    SecPolicyRef policy = SecPolicyCreateSSL(true, NULL);
    SecTrustSetPolicies(serverTrust, policy);
    
    // Verify that trust.
    SecTrustResultType trustResult;
    SecTrustEvaluate(serverTrust, &trustResult);
    
    // Clean up.
    CFRelease(certArrayRef);
    CFRelease(cert);
    CFRelease(certDataRef);
    
    // Did our custom trust chain evaluate successfully?
    BOOL trusted = trustResult == kSecTrustResultUnspecified;
    return trusted;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.MessageTextView.text = dataString;
    NSLog(@"Data Is: %@", dataString);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)CallServiceButton:(id)sender {
    
    NSURL *url = [NSURL URLWithString: @"https://0.0.0.0:4567/api/users/5276666536ddce0db800009c"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self basicAuthForRequest: request withUsername: @"johnyoates@gmail.com" andPassword: @"70e2a2e2a9fe55f3563d5a198e3f853d15de7f93499f903772667a84630f14a2"];
    
    //initialize a connection from request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    //start the connection
    [self.connection start];
}
@end
