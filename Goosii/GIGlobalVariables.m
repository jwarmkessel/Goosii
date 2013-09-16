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

- (id)init {

    if ((self = [super init])) {
        [self setEnvironmentVariables:kENVIRONMENT_FLAG];
    }

    return self;
}

- (void)setEnvironmentVariables:(NSString *)environment {
    if([environment isEqualToString:@"SANDBOX"]){
        GOOSIIAPI = [NSString stringWithFormat:@"%@%@/", kBASE_URL, kSANDBOX_PORT];
    } else if([environment isEqualToString:@"DEMO"]){
        GOOSIIAPI = [NSString stringWithFormat:@"%@%@/", kBASE_URL, kDEMO_PORT];
    } else if([environment isEqualToString:@"PRODUCTION"]){
        GOOSIIAPI = [NSString stringWithFormat:@"%@%@/", kBASE_URL, kPRODUCTION_PORT];
    }
}

@end
