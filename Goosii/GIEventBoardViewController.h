//
//  GIEventBoardViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 7/12/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class GICompany;

@interface GIEventBoardViewController : UITableViewController <MKMapViewDelegate, UITextViewDelegate> {
    BOOL isEvent;
}

@property (nonatomic, strong) GICompany * company;

- (void)showNoEventsPopUp;
@end
