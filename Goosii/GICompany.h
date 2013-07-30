//
//  GICompany.h
//  Goosii
//
//  Created by Justin Warmkessel on 7/4/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GICompany : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *companyId;
@property (strong, nonatomic) NSString *startDate;
@property (strong, nonatomic) NSString *endDate;
@property (strong, nonatomic) NSString *post;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *telephone;
@property (strong, nonatomic) NSString *totalParticipants;

-(id) initWithName:(NSString*)companyName companyId:(NSString*)companyId address:(NSString*)address telephone:(NSString*)telephone numOfParticipants:(NSString*)totalParticipants;

//-(id) initWithName:(NSString*)companyName companyId:(NSString*)companyId address:(NSString*)address telephone:(NSString*)telephone longitude:(NSString*)longitude latitude:(NSString *)latitude;
@end
