//
//  GIRewardViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 9/5/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GICompany;
@interface GIRewardViewController : UIViewController <UITextFieldDelegate> {
    
}

@property (strong, nonatomic) GICompany *company;
@property (strong, nonatomic) IBOutlet UITextView *userIntructTxtField;
@property (strong, nonatomic) IBOutlet UILabel *companyNameLbl;
@property (strong, nonatomic) IBOutlet UITextField *textInputField;
@end
