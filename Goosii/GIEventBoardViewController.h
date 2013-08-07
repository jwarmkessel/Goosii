//
//  GIEventBoardViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 7/12/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GICompany;

@interface GIEventBoardViewController : UITableViewController  {
    BOOL isEvent;
}

@property (nonatomic, strong) GICompany * company;

- (void)showNoEventsPopUp;
@end
