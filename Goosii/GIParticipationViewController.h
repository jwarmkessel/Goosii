//
//  GIParticipationViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIParticipationViewController : UITableViewController <UITableViewDataSource, NSURLConnectionDelegate>
@property (strong, nonatomic) NSMutableArray *eventList;

- (void)makeContestRequest;
@end
