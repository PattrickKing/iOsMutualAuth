//
//  RKViewController.m
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/27/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import "RKViewController.h"
#import "BZHTTPRequestOperation.h"
#import "BZHTTPClient.h"
#import "BZUser.h"
#import <RestKit/RestKit.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "MappingProvider.h"

@interface RKViewController ()

@end

@implementation RKViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)RKCallServiceButton:(id)sender {
    
    NSURL *url = [NSURL URLWithString: @"https://0.0.0.0:4567/api/users/5276666536ddce0db800009c"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self basicAuthForRequest: request withUsername: @"johnyoates@gmail.com" andPassword: @"70e2a2e2a9fe55f3563d5a198e3f853d15de7f93499f903772667a84630f14a2"];
    
    BZHTTPRequestOperation *bzOperation = [[BZHTTPRequestOperation alloc] initWithRequest:request];
    NSIndexSet *statusCodeSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKMapping *mapping = [MappingProvider userMapping];
    
    RKResponseDescriptor *descriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodGET pathPattern:@"/api/users/5276666536ddce0db800009c" keyPath:@"user" statusCodes:statusCodeSet];
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithHTTPRequestOperation:bzOperation
                                                                                     responseDescriptors:@[descriptor]];
    
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        BZUser* loginUser = (BZUser*)mappingResult.firstObject;
        self.FirstNameLabel.text = loginUser.firstName;
        self.LastNameLabel.text = loginUser.lastName;
        self.EmailLabel.text = loginUser.email;
        NSLog(@"%@", loginUser.email);
        
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        NSLog(@"Sad Trombone");

    }];
    
    [operation start];
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


@end
