//
//  GIEventScrollViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 12/18/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@class GICompany;

@interface GIEventScrollViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) UIScrollView *eventScrollView;

@property (nonatomic, strong) GICompany * company;

@property (nonatomic, strong) NSTimer *blinkTimer;
@property (nonatomic, strong) UILabel *fbPartLbl;
@property (assign) BOOL toggle;
@property (nonatomic, strong) UIButton* infoBtn;

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *fbAccount;

- (void)showNoEventsPopUp:(NSString*)newsURL;

@end




