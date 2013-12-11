//
//  GIGlobalVariables.m
//  Goosii
//
//  Created by Justin Warmkessel on 9/16/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIGlobalVariables.h"

@implementation GIGlobalVariables

NSString * GOOSIIAPI;
NSString * NEW_RELIC_TOKEN;
- (id)init {

    if ((self = [super init])) {
        [self setEnvironmentVariables:kENVIRONMENT_FLAG];
    }

    return self;
}

- (void)setEnvironmentVariables:(NSString *)environment {
    if([environment isEqualToString:@"SANDBOX"]){
        GOOSIIAPI = [NSString stringWithFormat:@"%@:%@/", kBASE_URL, kSANDBOX_PORT];
        NEW_RELIC_TOKEN = @"AAd72363c0bc34636264aa4af9a4f00b6269cea4ab";
    } else if([environment isEqualToString:@"DEMO"]){
        GOOSIIAPI = [NSString stringWithFormat:@"%@:%@/", kBASE_URL, kDEMO_PORT];
        NEW_RELIC_TOKEN = @"AAd72363c0bc34636264aa4af9a4f00b6269cea4ab";        
    } else if([environment isEqualToString:@"PRODUCTION"]){
        GOOSIIAPI = [NSString stringWithFormat:@"%@:%@/", kBASE_URL, kPRODUCTION_PORT];
        NEW_RELIC_TOKEN = @"AA837b1ca979338732f49be10811f047cebbf7d098";
    }
}

@end
