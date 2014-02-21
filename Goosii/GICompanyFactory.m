//
//  GICompanyFactory.m
//  Goosii
//
//  Created by Justin Warmkessel on 2/20/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "GICompanyFactory.h"
#import "GICompany.h"
#import <SBJson.h>
#import <CoreLocation/CoreLocation.h>

#define METERS_PER_MILE 1609.344
#define METERS_TO_MILE_CONVERSION 0.00062137

@interface GICompanyFactory ()
@property (strong, nonatomic) CLLocationManager *manager;

- (void)createCompanyArrayWithDistance:(NSString*)document;
- (void)createCompanyArray:(NSString*)document;
@end

@implementation GICompanyFactory
@synthesize companies;

-(id) initWithDocument:(NSString*) document {
    self = [super init];
    if( !self ) return nil;
    
    self.companies = [[NSMutableArray alloc] init];
    NSLog(@"%@", document);
    [self createCompanyArray:document];

    return self;
}

-(id) initWithDocument:(NSString*) document withLocationManager:(CLLocationManager*)locationManager {
    self = [super init];
    if( !self ) return nil;
    NSLog(@"%@", document);
    _manager = locationManager;
    self.companies = [[NSMutableArray alloc] init];
    [self createCompanyArrayWithDistance:document];
    
    return self;
}

- (void)createCompanyArrayWithDistance:(NSString*)document{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *superObject = [parser objectWithString:document];
    NSDictionary *userObj = [superObject objectForKey:@"userObject"];
    NSArray *results = [superObject objectForKey:@"results"];
    
    
    NSLog(@"hello");
    
    for (id result in results) {
        //This is the company object.
        NSDictionary *company = [result objectForKey:@"obj"];
        
        NSLog(@"hello");
        
        NSString *newsURLString = @"";
        
        if([[company objectForKey:@"newsURL"] length] != 0 ){
            newsURLString = [company objectForKey:@"newsURL"];
        }
        
        //Set longitude and latitude
        NSDictionary *location = [company objectForKey:@"location"];
        NSArray *coordinateArray = [location objectForKey:@"coordinates"];
        NSString *longitudeStr = [NSString stringWithFormat:@"%@", [coordinateArray objectAtIndex:0]];
        NSString *latitudeStr = [NSString stringWithFormat:@"%@", [coordinateArray objectAtIndex:1]];
        
        NSArray *participantsAry = [company objectForKey:@"participants"];
        
        NSString *isFollowing = @"NO";
        int totalParticipantsNum = [participantsAry count];
        
        //Check if user is participating in this event and temporarily add 1 if not
        for (id participantsId in participantsAry) {
            NSString *partObj = [participantsId objectForKey:@"userId"];
            
            if([[[NSUserDefaults standardUserDefaults] stringForKey:@"userId"] isEqualToString:partObj]){
                isFollowing = @"YES";
            }
        }
        
        if([isFollowing isEqualToString:@"NO"]){
            totalParticipantsNum++;
        }
        
        NSString *totalParticipants = [NSString stringWithFormat:@"%d", totalParticipantsNum];
        
        //Determine percentage of time
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
        
        //NSLog(@"The Current Date %f", timeInMiliseconds);
        NSDictionary *event = [company objectForKey:@"contest"];
        
        double startDate = floor([[event objectForKey:@"startDate"] doubleValue]);
        double endDate = floor([[event objectForKey:@"endDate"] doubleValue]);
        startDate = startDate / 1000;
        endDate = endDate / 1000;

        double totalDuration = endDate - startDate;
        
        //Elapsed time in seconds equals the current time minus the startdate.
        double elapsedTime = timeInMiliseconds - startDate;
        double percentage = elapsedTime / totalDuration;
        
        if(percentage >= 1.0) {
            percentage = 1;
        }
        
        NSString *timePercent = [NSString stringWithFormat:@"%lf", percentage];
        
        //Calculate Participation Percentage.
        float partPercentage = 0;
        float ttlParticipationCount = 0;
        
        NSArray *contests = [userObj objectForKey:@"contests"];
        
        for (id contest in contests) {
            
            NSString *contestCompanyId =[contest objectForKey:@"companyId"];
            NSString *companyId = [company objectForKey:@"_id"];
            
            if([contestCompanyId isEqualToString:companyId]) {
                
                if([contest objectForKey:@"participationCount"] == nil) {
                    ttlParticipationCount = 1;
                } else {
                    ttlParticipationCount = [[contest objectForKey:@"participationCount"] floatValue];
                }
                
                if(totalDuration != 0.0) {
                    partPercentage = elapsedTime / 86400;
                    
                    if(elapsedTime < 86400) {
                        partPercentage = 1;
                    }
                    
                    partPercentage = floor(partPercentage);
                    
                    if(ttlParticipationCount > 0) {
                        partPercentage =  ttlParticipationCount / partPercentage;
                    } else {
                        partPercentage = 0;
                    }
                    
                    if(partPercentage > 1) {
                        partPercentage = 1;
                    }
                }
                break;
            }
        }
        
        //Check fulfillments
        NSArray *fulfillments = [userObj objectForKey:@"fulfillments"];
        
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[fulfillments count]] forKey:@"fulfillments"];
        
//        if([fulfillments count] > 0) {
//            
//            [UIView animateWithDuration:1.0 animations:^{
//                self.slideMenuButtonNotificationLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[fulfillments count]];
//                self.slideMenuButtonNotificationLabel.alpha = 1;
//            }];
//        }
        
        NSString *isFulfillment = @"NO";
        for (id contest in fulfillments) {
            NSString *contestCompanyId =[contest objectForKey:@"companyId"];
            NSString *companyId = [company objectForKey:@"_id"];
            
            if([contestCompanyId isEqualToString:companyId]) {
                isFulfillment = @"YES";
            }
        }
        
        NSString * isReward = @"NO";
        
        //Check rewards and fulfillment
        NSArray *rewards = [userObj objectForKey:@"rewards"];
        
        
        for (id contest in rewards) {
            NSString *contestCompanyId =[contest objectForKey:@"companyId"];
            NSString *companyId = [company objectForKey:@"_id"];
            
            
            if([contestCompanyId isEqualToString:companyId] && [[contest objectForKey:@"fulfillment"] floatValue] == 0) {
                isReward = @"YES";
                isFulfillment = @"NO";
                
                //If there is a reward that is found and fulfilled then exit this iteration.
                break;
                
            } else if([contestCompanyId isEqualToString:companyId]) {
                isReward = @"YES";
                isFulfillment = @"YES";
                
                break;
            }
        }
        
        NSLog(@"Okay, create company");
        
        /*** Build the company list based on those that are either nearby or on whether this is a list of companies being followed ***/
        if(_manager) {
            
            NSLog(@"Location Manager exists");
            
            //Determine whether company is near enough
            NSLog(@"The longitude %@ AND the latitude %@", longitudeStr, latitudeStr);
            CLLocation *companyLocation = [[CLLocation alloc] initWithLatitude:[latitudeStr floatValue] longitude:[longitudeStr floatValue]];
            
            float distanceInMiles = METERS_TO_MILE_CONVERSION * [_manager.location distanceFromLocation:companyLocation];
            
            //Create company object and push to array.
            GICompany *companyObj = [[GICompany alloc] initWithName:[company objectForKey:@"name"]
                                                          companyId:[company objectForKey:@"_id"]
                                                            address:[company objectForKey:@"address"]
                                                          telephone:[company objectForKey:@"telephone"]
                                                  numOfParticipants:totalParticipants
                                                               time:timePercent
                                                      participation:[NSString stringWithFormat:@"%f", partPercentage]
                                                          startDate:[event objectForKey:@"startDate"]
                                                            endDate:[event objectForKey:@"endDate"]
                                                        fulfillment:isFulfillment
                                                             reward:isReward
                                                          longitude:longitudeStr
                                                           latitude:latitudeStr
                                                               post:[event objectForKey:@"post"]
                                                        eventReward:[event objectForKey:@"prize"]
                                                  participationPost:[event objectForKey:@"participationPost"]
                                                participationPoints:[NSString stringWithFormat:@"%f", ttlParticipationCount]
                                                           distance:[NSString stringWithFormat:@"%.2f mi", distanceInMiles]
                                                            website:[event objectForKey:@"website"]
                                                            newsUrl:newsURLString
                                                            following:isFollowing];
            
            //Get the distance allowed by the server for checking into nearby companies.
            NSDictionary *distanceConfiguration = [superObject objectForKey:@"distanceConfiguration"];
            
            if(distanceInMiles < [[distanceConfiguration objectForKey:@"distance"] floatValue]) {
                NSLog(@"Include the %@", [company objectForKey:@"name"]);
                [self.companies addObject:companyObj];
                
                NSLog(@"The count of companies as they are added %lu", (unsigned long)[self.companies count]);
            }
        } else {
            NSLog(@"Location Manager doesn't exists");
            //Create company object and push to array.
            GICompany *companyObj = [[GICompany alloc] initWithName:[company objectForKey:@"name"]
                                                          companyId:[company objectForKey:@"_id"]
                                                            address:[company objectForKey:@"address"]
                                                          telephone:[company objectForKey:@"telephone"]
                                                  numOfParticipants:totalParticipants
                                                               time:timePercent
                                                      participation:[NSString stringWithFormat:@"%f", partPercentage]
                                                          startDate:[event objectForKey:@"startDate"]
                                                            endDate:[event objectForKey:@"endDate"]
                                                        fulfillment:isFulfillment
                                                             reward:isReward
                                                          longitude:[company objectForKey:@"longitude"]
                                                           latitude:[company objectForKey:@"latitude"]
                                                               post:[event objectForKey:@"post"]
                                                        eventReward:[event objectForKey:@"prize"]
                                                  participationPost:[event objectForKey:@"participationPost"]
                                                participationPoints:[NSString stringWithFormat:@"%f", ttlParticipationCount]
                                                            website:[event objectForKey:@"website"]
                                                            newsUrl:newsURLString
                                                            following:isFollowing];
            
            NSLog(@"The count of companies as they are added %lu", (unsigned long)[self.companies count]);
            [self.companies addObject:companyObj];
   
        }
    }
}

- (void)createCompanyArray:(NSString*)document {
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *jsonObject = [parser objectWithString:document];
    NSDictionary *userObj = [jsonObject objectForKey:@"userObject"];
    NSArray *companyArray = [jsonObject objectForKey:@"results"];
    
    for (id company in companyArray) {
        
        NSArray *participantsAry = [company objectForKey:@"participants"];
        
        NSString *totalParticipants = [NSString stringWithFormat:@"%lu", (unsigned long)[participantsAry count]];
        
        //NSLog(@"The Phone number %@", [company objectForKey:@"telephone"]);
        NSString *isFollowing = @"NO";
        int totalParticipantsNum = [participantsAry count];
        
        //Check if user is participating in this event and temporarily add 1 if not
        for (id participantsId in participantsAry) {
            NSString *partObj = [participantsId objectForKey:@"userId"];
            
            if([[[NSUserDefaults standardUserDefaults] stringForKey:@"userId"] isEqualToString:partObj]){
                isFollowing = @"YES";
            }
        }
        
        if([isFollowing isEqualToString:@"NO"]){
            totalParticipantsNum++;
        }
        
        //Determine percentage of time
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
        
        //NSLog(@"The Current Date %f", timeInMiliseconds);
        NSDictionary *event = [company objectForKey:@"contest"];
        
        double startDate = floor([[event objectForKey:@"startDate"] doubleValue]);
        double endDate = floor([[event objectForKey:@"endDate"] doubleValue]);
        startDate = startDate / 1000;
        endDate = endDate / 1000;
        NSLog(@"START DATE %f", startDate);
        NSLog(@"END DATE %f", endDate);
        
        double curTime = floor(timeInMiliseconds);
        NSLog(@"CURRENT DATE %f", curTime);
        
        double totalDuration = endDate - startDate;
        NSLog(@"TOTAL DURATION IN MIL %f", totalDuration);
        
        //Elapsed time in seconds equals the current time minus the startdate.
        double elapsedTime = curTime - startDate;
        
        NSLog(@"ELAPSED TIME %f", elapsedTime);
        
        double percentage = elapsedTime / totalDuration;
        
        if(percentage > 1.0) {
            percentage = 1;
        }
        
        NSString *timePercent = [NSString stringWithFormat:@"%f", percentage];
        
        //Calculate Participation Percentage.
        float partPercentage = 0;
        float ttlParticipationCount = 0;
        
        NSArray *contests = [userObj objectForKey:@"contests"];
        
        for (id contest in contests) {
            
            NSLog(@" %@ ", [company objectForKey:@"name"]);
            
            NSString *contestCompanyId =[contest objectForKey:@"companyId"];
            NSString *companyId = [company objectForKey:@"_id"];
            
            if([contestCompanyId isEqualToString:companyId]) {
                
                NSLog(@"         %@ and %@", contestCompanyId, companyId);
                
                if([contest objectForKey:@"participationCount"] == nil) {
                    NSLog(@"         total participation is nil so we add one");
                    ttlParticipationCount = 1;
                } else {
                    ttlParticipationCount = [[contest objectForKey:@"participationCount"] floatValue];
                }
                
                NSLog(@"         The participation count %f", ttlParticipationCount);
                
                if(totalDuration != 0.0) {
                    partPercentage = elapsedTime / 86400;
                    
                    if(elapsedTime < 86400) {
                        partPercentage = 1;
                    }
                    
                    partPercentage = floor(partPercentage);
                    
                    if(ttlParticipationCount > 0) {
                        partPercentage =  ttlParticipationCount / partPercentage;
                    } else {
                        partPercentage = 0;
                    }
                    
                    if(partPercentage > 1) {
                        partPercentage = 1;
                    }
                    
                    NSLog(@"         PART PERCENTAGE %f", partPercentage);
                }
                
                break;
            }
        }
        
        NSString *partPer = [NSString stringWithFormat:@"%f", partPercentage];
        
        //Check fulfillments
        NSArray *fulfillments = [userObj objectForKey:@"fulfillments"];
        
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[fulfillments count]] forKey:@"fulfillments"];
        
        NSString *isFulfillment = @"NO";
        for (id contest in fulfillments) {
            NSString *contestCompanyId =[contest objectForKey:@"companyId"];
            NSString *companyId = [company objectForKey:@"_id"];
            
            if([contestCompanyId isEqualToString:companyId]) {
                NSLog(@"Setting fulfillment for %@", [company objectForKey:@"name"]);
                isFulfillment = @"YES";
            }
        }
        
        NSString * isReward = @"NO";
        
        //Check rewards and fulfillment
        NSArray *rewards = [userObj objectForKey:@"rewards"];
        
        for (id contest in rewards) {
            NSString *contestCompanyId =[contest objectForKey:@"companyId"];
            NSString *companyId = [company objectForKey:@"_id"];
            
            
            if([contestCompanyId isEqualToString:companyId] && [[contest objectForKey:@"fulfillment"] floatValue] == 0) {
                NSLog(@"Setting reward for %@", [company objectForKey:@"name"]);
                isReward = @"YES";
                isFulfillment = @"NO";
                
                //If there is a reward that is found and fulfilled then exit this iteration.
                break;
                
            } else if([contestCompanyId isEqualToString:companyId]) {
                isReward = @"YES";
                isFulfillment = @"YES";
                
                break;
            }
        }
        
        NSString *newsURLString = @"";
        
        if([[company objectForKey:@"newsURL"] length] != 0 ){
            newsURLString = [company objectForKey:@"newsURL"];
            NSLog(@"                                 ---------=========> THE NEWS URL %@", newsURLString);
        }
        
        //Create company object and push to array.
        GICompany *companyObj = [[GICompany alloc] initWithName:[company objectForKey:@"name"]
                                                      companyId:[company objectForKey:@"_id"]
                                                        address:[company objectForKey:@"address"]
                                                      telephone:[company objectForKey:@"telephone"]
                                              numOfParticipants:totalParticipants
                                                           time:timePercent
                                                  participation:partPer
                                                      startDate:[event objectForKey:@"startDate"]
                                                        endDate:[event objectForKey:@"endDate"]
                                                    fulfillment:isFulfillment
                                                         reward:isReward
                                                      longitude:[company objectForKey:@"longitude"]
                                                       latitude:[company objectForKey:@"latitude"]
                                                           post:[event objectForKey:@"post"]
                                                    eventReward:[event objectForKey:@"prize"]
                                              participationPost:[event objectForKey:@"participationPost"]
                                            participationPoints:[NSString stringWithFormat:@"%f", ttlParticipationCount]
                                                        website:[event objectForKey:@"website"]
                                                        newsUrl:newsURLString
                                                      following:isFollowing];
        
        NSLog(@"Adding company object");
        [self.companies addObject:companyObj];
        
    }
}



@end
