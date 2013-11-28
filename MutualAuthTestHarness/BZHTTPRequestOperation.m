//
//  BZHTTPRequestOperation.m
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/27/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import "BZHTTPRequestOperation.h"

@implementation BZHTTPRequestOperation

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

@end
