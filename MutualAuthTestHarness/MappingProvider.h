//
//  MappingProvider.h
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/28/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface MappingProvider : NSObject

+ (RKMapping *)userMapping;

@end
