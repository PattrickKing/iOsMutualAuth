//
//  RKViewController.h
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/27/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *FirstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *LastNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *EmailLabel;

- (IBAction)ForwardButton:(id)sender;
- (IBAction)RKCallServiceButton:(id)sender;

@end