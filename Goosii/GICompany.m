//
//  GICompany.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/4/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GICompany.h"

@implementation GICompany
@synthesize name, companyId, address, telephone, totalParticipants, timePercentage, participationPercentage, startDate, endDate;

-(id) initWithName:(NSString*)companyName companyId:(NSString*)identifier address:(NSString*)companyAddress telephone:(NSString*)companyTelephone numOfParticipants:(NSString*)ttlParticipants time:(NSString*)timePercent participation:(NSString*)partPercent startDate:(NSString*)start endDate:(NSString*)end{
    
    self = [super init];
    if( !self ) return nil;
    
    self.name = companyName;
    self.companyId = identifier;
    self.address = companyAddress;
    self.telephone = companyTelephone;
    self.totalParticipants = ttlParticipants;
    self.timePercentage = timePercent;
    self.participationPercentage = partPercent;
    self.startDate = start;
    self.endDate = end;
    
    return self;
}
@end
