//
//  ViewController.h
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/9/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *MessageTextView;

- (IBAction)CallServiceButton:(id)sender;

@property (retain, nonatomic) NSURLConnection *connection;

- (IBAction)UnwindToMain:(UIStoryboardSegue *)seque;

@end
