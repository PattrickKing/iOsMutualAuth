//
//  RKObjectManagerViewController.h
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/29/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPClient.h>
#import "RKObjectManager.h"

@class RKObjectManager;

@interface RKObjectManagerViewController : UIViewController {
    RKObjectManager* _objectManager;
}
- (IBAction)CallServiceButton:(id)sender;

@end
