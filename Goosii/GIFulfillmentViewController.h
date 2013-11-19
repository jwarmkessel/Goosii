//
//  GIFulfillmentViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 8/20/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GICompany;

@interface GIFulfillmentViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) GICompany * company;
@property (nonatomic, strong) NSTimer *blinkTimer;
@property (nonatomic, strong) UILabel *fbPartLbl;
@property (assign) BOOL toggle;

@end
