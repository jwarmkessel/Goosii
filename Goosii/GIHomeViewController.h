//
//  GIHomeViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 8/7/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface GIHomeViewController : UIViewController

@property (strong, nonatomic) UIButton *slidingMenuButton;
- (void) hideNavBar;

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *fbAccount;

@end



