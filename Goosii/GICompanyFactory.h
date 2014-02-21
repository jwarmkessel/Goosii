//
//  GICompanyFactory.h
//  Goosii
//
//  Created by Justin Warmkessel on 2/20/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocationManager;
@interface GICompanyFactory : NSObject

@property (strong, nonatomic) NSMutableArray *companies;

-(id) initWithDocument:(NSString*) document;
-(id) initWithDocument:(NSString*)document withLocationManager:(CLLocationManager *)locationManager;
@end
