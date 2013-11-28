//
//  BZUser.h
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/28/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BZUser : NSObject

@property (nonatomic, strong) NSDate * agreedAt;
@property (nonatomic, strong) NSSet *contactedByPermissions;
@property (nonatomic, strong) NSSet *contactPermissions;
@property (nonatomic, strong) NSSet *conversations;
@property (nonatomic, strong) NSDate * dateOfBirth;
@property (nonatomic, strong) NSSet *devices;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * gender;
@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * login;
@property (nonatomic, strong) NSString * mood;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSSet *sentMessages;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSSet *symbolPermissions;
@property (nonatomic, strong) NSString * zipCode;

@end
