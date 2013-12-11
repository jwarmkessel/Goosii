//
//  GIAppDelegate.h
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface GIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *fbAccount;

@end
