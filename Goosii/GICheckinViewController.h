//
//  GICheckinViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GICheckinViewController : UITableViewController <CLLocationManagerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLConnectionDownloadDelegate>

@property (strong, nonatomic) NSMutableArray *nearbyLocationsAry;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)setInset;
@end
