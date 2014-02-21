//
//  GICompany.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/4/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GICompany.h"

@implementation GICompany
@synthesize name, companyId, address, telephone, totalParticipants, timePercentage, participationPercentage, startDate, endDate, fulfillment, reward, responseStr, longitude, latitude, post, prize, participationPost, participationPoints, website, newsURLString;

-(id) initWithName:(NSString*)companyName companyId:(NSString*)identifier address:(NSString*)companyAddress telephone:(NSString*)companyTelephone numOfParticipants:(NSString*)ttlParticipants time:(NSString*)timePercent participation:(NSString*)partPercent startDate:(NSString*)start endDate:(NSString*)end fulfillment:(NSString*)isFulfillment reward:(NSString*)isReward longitude:(NSString *)lngitude latitude:(NSString *)ltitude post:(NSString *)wallPost eventReward:(NSString *)eventPrize participationPost:(NSString *)partPost participationPoints:(NSString *)partPoints website:(NSString *)companyWebsite newsUrl:(NSString *)newsURL following:(NSString *)following {
    
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
    self.fulfillment = isFulfillment;
    self.reward = isReward;
    self.longitude = lngitude;
    self.latitude = ltitude;
    self.post = wallPost;
    self.prize = eventPrize;
    self.participationPost = partPost;
    self.participationPoints = partPoints;
    self.website = companyWebsite;
    self.newsURLString = newsURL;
    self.isFollowing = following;
    
    return self;
}

-(id) initWithName:(NSString*)companyName companyId:(NSString*)identifier address:(NSString*)companyAddress telephone:(NSString*)companyTelephone numOfParticipants:(NSString*)ttlParticipants time:(NSString*)timePercent participation:(NSString*)partPercent startDate:(NSString*)start endDate:(NSString*)end fulfillment:(NSString*)isFulfillment reward:(NSString*)isReward longitude:(NSString *)lngitude latitude:(NSString *)ltitude post:(NSString *)wallPost eventReward:(NSString *)eventPrize participationPost:(NSString *)partPost participationPoints:(NSString *)partPoints distance:(NSString *)curDistance website:(NSString *)companyWebsite newsUrl:(NSString *)newsURL following:(NSString *)following{
    
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
    self.fulfillment = isFulfillment;
    self.reward = isReward;
    self.longitude = lngitude;
    self.latitude = ltitude;
    self.post = wallPost;
    self.prize = eventPrize;
    self.participationPost = partPost;
    self.participationPoints = partPoints;
    self.distanceStr = curDistance;
    self.website = companyWebsite;
    self.newsURLString = newsURL;
    self.isFollowing = following;    
    
    return self;
}
@end
