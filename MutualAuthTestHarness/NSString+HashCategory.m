//
//  NSObject+NSStringHashCategory.m
//  MutualAuthTestHarness
//
//  Created by Patrick King on 11/9/13.
//  Copyright (c) 2013 Patrick King Consulting LLC. All rights reserved.
//

#import "NSString+HashCategory.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (NSStringHashCategory)

-(NSString*) Hash {
    
    const char *cStr = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19],
                   result[20], result[21], result[22], result[23], result[24],
                   result[25], result[26], result[27],
                   result[28], result[29], result[30], result[31]
                   ];
    return [s lowercaseString];
}

@end
