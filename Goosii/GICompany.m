//
//  GICompany.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/4/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GICompany.h"

@implementation GICompany
@synthesize name, companyId, address, telephone;

-(id) initWithName:(NSString*)companyName companyId:(NSString*)identifier address:(NSString*)companyAddress telephone:(NSString*)companyTelephone {
    
    self = [super init];
    if( !self ) return nil;
    
    self.name = companyName;
    self.companyId = identifier;
    self.address = companyAddress;
    self.telephone = companyTelephone;
    
    return self;
}
@end
