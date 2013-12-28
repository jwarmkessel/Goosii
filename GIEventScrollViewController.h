//
//  GIEventScrollViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 12/18/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GICompany;

@interface GIEventScrollViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *eventScrollView;

@property (nonatomic, strong) GICompany * company;

@property (nonatomic, strong) NSTimer *blinkTimer;
@property (nonatomic, strong) UILabel *fbPartLbl;
@property (assign) BOOL toggle;
@property (nonatomic, strong) UIButton* infoBtn;

- (void)showNoEventsPopUp:(NSString*)newsURL;

@end
