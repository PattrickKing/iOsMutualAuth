//
//  RKObjectManagerViewController.m
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/29/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import "RKObjectManagerViewController.h"
#import "BZUser.h"
#import "BZHTTPRequestOperation.h"
#import <RestKit/RestKit.h>


@interface RKObjectManagerViewController ()

@end

@implementation RKObjectManagerViewController

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
    _objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://0.0.0.0:4567/api"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)CallServiceButton:(id)sender {
    
    // Provide the credentials to RestKit.
    [_objectManager.HTTPClient
     clearAuthorizationHeader];
    
    NSString *uid = @"johnyoates@gmail.com";
    NSString *pwd = @"70e2a2e2a9fe55f3563d5a198e3f853d15de7f93499f903772667a84630f14a2";
    
    [_objectManager.HTTPClient
     setAuthorizationHeaderWithUsername:uid
     password:pwd];
    
    // Fetch the login user object.
    NSManagedObjectContext* transactionContext =
    [_objectManager.managedObjectStore
     newChildManagedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType
     tracksChanges:true];
    
    NSMutableURLRequest* loginRequest =
    [_objectManager
     requestWithObject:nil
     method:RKRequestMethodGET
     path:@"users/5276666536ddce0db800009c"
     parameters:nil];
    
    loginRequest.timeoutInterval = 7;
    
    [_objectManager registerRequestOperationClass:[BZHTTPRequestOperation class]];
    
    RKManagedObjectRequestOperation* loginOperation =
    [_objectManager
     managedObjectRequestOperationWithRequest:loginRequest
     managedObjectContext:transactionContext
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         BZUser* loginUser = (BZUser*)mappingResult.firstObject;
         NSLog(@"%@", loginUser.email);
     }
     failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error.localizedDescription);
         
         UIAlertView *alert =
         [[UIAlertView alloc]
          initWithTitle:@"Error"
          message:@"Please verify your email and login again."
          delegate:self
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil];
         [alert show];
     }];
    
    //loginOperation.savesToPersistentStore = true;
    
    [_objectManager enqueueObjectRequestOperation:loginOperation];
}
@end
