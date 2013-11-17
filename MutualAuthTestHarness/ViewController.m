//
//  ViewController.m
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/9/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+HashCategory.h"

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
    
    NSURL *url = [NSURL URLWithString: @"https://www.pluralsight.com/odata/Courses"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //initialize a connection from request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    //start the connection
    [connection start];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Get Server Cert From Application Bundle


- (BOOL)shouldTrustProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    // Load up the bundled server public key certificate.
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"pluralsight.com" ofType:@"der"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    CFDataRef certDataRef = (__bridge_retained CFDataRef)certData;
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, certDataRef);
    
    // Establish a chain of trust anchored on our bundled certificate.
    CFArrayRef certArrayRef = CFArrayCreate(NULL, (void *)&cert, 1, NULL);
    SecTrustRef serverTrust = protectionSpace.serverTrust;
    SecTrustSetAnchorCertificates(serverTrust, certArrayRef);
    
    // Verify that trust.
    SecTrustResultType trustResult;
    SecTrustEvaluate(serverTrust, &trustResult);
    
    // Clean up.
    CFRelease(certArrayRef);
    CFRelease(cert);
    CFRelease(certDataRef);
    
    // Did our custom trust chain evaluate successfully?
    return trustResult == kSecTrustResultUnspecified;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
//    NSLog(@"Authentication challenge");
//    
//    // load cert
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"pwk-compat" ofType:@"p12"];
//    NSData *p12data = [NSData dataWithContentsOfFile:path];
//    CFDataRef inP12data = (__bridge CFDataRef)p12data;
//    CFStringRef password = CFSTR("password");
//    
//    SecIdentityRef myIdentity;
//    SecTrustRef myTrust;
//    //OSStatus extractIdentityStatus = [self extractIdentityAndTrust :inPKCS12Data :&identity :&trust :password];
//    OSStatus status = [self extractIdentityAndTrust :inP12data :&myIdentity :&myTrust :password];
//    
//    SecCertificateRef myCertificate;
//    SecIdentityCopyCertificate(myIdentity, &myCertificate);
//    const void *certs[] = { myCertificate };
//    CFArrayRef certsArray = CFArrayCreate(NULL, certs, 1, NULL);
//    
//    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:myIdentity certificates:(__bridge NSArray*)certsArray persistence:NSURLCredentialPersistencePermanent];
//    
//    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    
    
    
    
    
    
    
    BOOL trustServer = [self shouldTrustProtectionSpace:challenge.protectionSpace];
    
    if (trustServer) {
        
        // gets a certificate from local resources
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"pwk-compat" ofType:@"p12"];
        NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
        CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
        
        CFStringRef password = CFSTR("passphrase");
        SecIdentityRef identity;
        SecTrustRef trust;
        
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
        
        
        /*
        // extract the identity and trust from the certificate
        OSStatus extractIdentityStatus = [self extractIdentityAndTrust :inPKCS12Data :&identity :&trust :password];
        
        if(extractIdentityStatus != noErr)
        {
            SecCertificateRef certificate = NULL;
            OSStatus status = SecIdentityCopyCertificate (identity, &certificate);
            
            if (status) {
                NSLog(@"SecIdentityCopyCertificate failed.\n");
            }
            
            const void *certs[] = {certificate};
            CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
            
            // create a credential from the certificate and identity, then reply to the challenge with the credential
            NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];
            
            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
            
        } else {
            [challenge.sender cancelAuthenticationChallenge:challenge];
        }
         */

        
        
    } else {
        
        [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
        
    }
    
    
}

- (OSStatus)extractIdentityAndTrust:(CFDataRef)inP12Data :(SecIdentityRef*)outIdentity :(SecTrustRef*)outTrust :(CFStringRef) keyPassword{
    
    OSStatus securityError = errSecSuccess;
    
    const void *keys[] =   { kSecImportExportPassphrase };
    const void *values[] = { keyPassword };
    CFDictionaryRef optionsDictionary = NULL;
    
    /* Create a dictionary containing the passphrase if one
     was specified.  Otherwise, create an empty dictionary. */
    optionsDictionary = CFDictionaryCreate(
                                           NULL, keys,
                                           values, (keyPassword ? 1 : 0),
                                           NULL, NULL);  // 1
    
    CFArrayRef items = NULL;
    securityError = SecPKCS12Import(inP12Data,
                                    optionsDictionary,
                                    &items);                    // 2
    
    
    //
    if (securityError == 0) {                                   // 3
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust,
                                             kSecImportItemIdentity);
        CFRetain(tempIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        
        CFRetain(tempTrust);
        *outTrust = (SecTrustRef)tempTrust;
    }
    
    if (optionsDictionary) {
        CFRelease(optionsDictionary);
    }
    
    if (items) {
        CFRelease(items);
    }
    
    return securityError;
}


#pragma mark Hashing and Comparing Server Cert

/*
- (void) connection:(NSURLConnection*)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSString* expectedCertHash = @"50d625d98813225e1fbb05f0e59dc15430d088b85b7f7bd4dca3fb698d526f5b";
    
    id <NSURLAuthenticationChallengeSender> sender = challenge.sender;
    
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    
    SecTrustRef trust = [protectionSpace serverTrust];
    
    CFIndex certificateIndex = 0;
    
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(trust, certificateIndex);
    
    NSData* serverCertificateData = (__bridge NSData*)SecCertificateCopyData(certificate);
    
    NSString *serverCertificateDataHash = [[serverCertificateData base64EncodedStringWithOptions:0] Hash];
    
    BOOL areCertificatesEqual = [serverCertificateDataHash isEqualToString:expectedCertHash];
    
    if(areCertificatesEqual)
    {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:trust];
        [sender useCredential:credential forAuthenticationChallenge:challenge];
    }
    else
    {
        [sender cancelAuthenticationChallenge:challenge];
    }
}
 */

//- (BOOL)connection:(NSURLConnection*)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    
//    
//    return YES;
//}

@end
