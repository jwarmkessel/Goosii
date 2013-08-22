//
//  GIFulfillmentViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 8/20/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GICompany;

@interface GIFulfillmentViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) GICompany * company;

@end
