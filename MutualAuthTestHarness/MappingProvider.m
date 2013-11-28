//
//  MappingProvider.m
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/28/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import "MappingProvider.h"
#import "BZUser.h"

@implementation MappingProvider

+ (RKMapping *)userMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BZUser class]];
    [mapping addAttributeMappingsFromArray:@[@"email"]];
    [mapping addAttributeMappingsFromDictionary:@{@"first_name":@"firstName", @"last_name":@"lastName"}];
    return mapping;
}

@end
