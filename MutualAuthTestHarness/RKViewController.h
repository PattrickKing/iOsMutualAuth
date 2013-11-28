//
//  RKViewController.h
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/27/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(UITextView) NSArray *RKMessageTextView;

- (IBAction)RKCallServiceButton:(id)sender;

@end