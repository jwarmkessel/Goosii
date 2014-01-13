//
//  GIUniqueIDGenerator.h
//  Goosii
//
//  Created by Justin Warmkessel on 1/7/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount;
@class ACAccountStore;

@interface GIUniqueIDGenerator : NSObject
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *fbAccount;

- (void)connectAndGenerateUniqueId;
@end
