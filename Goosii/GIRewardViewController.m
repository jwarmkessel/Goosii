//
//  GIRewardViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 9/5/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIRewardViewController.h"
#import "GICompany.h"
#import <QuartzCore/QuartzCore.h>

@interface GIRewardViewController ()

@end

@implementation GIRewardViewController
@synthesize company, textInputField, companyNameLbl, userIntructTxtField, isRewarded;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;

    //TODO Remove this shim
    //self.company.reward  = [NSString stringWithFormat:@"YES"];
    
    if([self.company.reward isEqualToString:@"YES"]) {
        
        NSLog(@"There is a company reward");
        self.textInputField.delegate = self; // ADD THIS LINE
        self.textInputField.placeholder = @"Password";
        self.textInputField.backgroundColor = [UIColor whiteColor];
        self.textInputField.textColor = [UIColor blackColor];
        self.textInputField.font = [UIFont systemFontOfSize:14.0f];
        self.textInputField.borderStyle = UITextBorderStyleRoundedRect;
        self.textInputField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textInputField.returnKeyType = UIReturnKeyDone;
        self.textInputField.textAlignment = NSTextAlignmentLeft;
        self.textInputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textInputField.tag = 2;
        self.textInputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        self.companyNameLbl.text = self.company.name;
        [self.userIntructTxtField setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        self.userIntructTxtField.textColor = [UIColor whiteColor];
        
        CGRect saveForLaterRect = CGRectMake(10, 300, 300, 50);
        UIButton *saveForLaterBtn = [[UIButton alloc] initWithFrame:saveForLaterRect];
        
        [saveForLaterBtn setBackgroundColor:[self colorWithHexString:@"3b5999"]];
        
        [saveForLaterBtn setTitle:@"Save For Later" forState:UIControlStateNormal];
        [saveForLaterBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
        [saveForLaterBtn.titleLabel setTextColor:[UIColor whiteColor]];
        
        [saveForLaterBtn.layer setBorderWidth:3.0];
        [saveForLaterBtn.layer setBorderColor:[[UIColor blackColor] CGColor]];
        
        [saveForLaterBtn.layer setShadowOffset:CGSizeMake(5, 5)];
        [saveForLaterBtn.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [saveForLaterBtn.layer setShadowOpacity:0.5];
        
        [saveForLaterBtn addTarget:self
                    action:@selector(saveForLaterBtnHandler:)
          forControlEvents:UIControlEventTouchDown];
        
        [self.view addSubview:saveForLaterBtn];
        
    } else {
        NSLog(@"There is NOT a company reward");
        UIView *notRewardedView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [notRewardedView setBackgroundColor:[self colorWithHexString:@"C63D0F"]];        

        CGRect noRewardLblRect = CGRectMake(10,100,300,100);
        UITextView *notRewardedLbl = [[UITextView alloc] initWithFrame:noRewardLblRect];
        notRewardedLbl.text = @"Sorry, you're not rewarded this time. No worries though, you're already entered into the next event.";
        [notRewardedLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]];
        notRewardedLbl.textColor = [UIColor whiteColor];
        notRewardedLbl.backgroundColor = [UIColor clearColor];
        notRewardedLbl.textAlignment = NSTextAlignmentCenter;
        
        CGRect skipBtnRect = CGRectMake(10, 250, 300, 50);
        UIButton *skipBtn = [[UIButton alloc] initWithFrame:skipBtnRect];
        
        [skipBtn setBackgroundColor:[self colorWithHexString:@"3b5999"]];
        
        [skipBtn setTitle:@"OK, I got it." forState:UIControlStateNormal];
        [skipBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
        [skipBtn.titleLabel setTextColor:[UIColor whiteColor]];
        
        [skipBtn.layer setBorderWidth:3.0];
        [skipBtn.layer setBorderColor:[[UIColor blackColor] CGColor]];
        
        [skipBtn.layer setShadowOffset:CGSizeMake(5, 5)];
        [skipBtn.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [skipBtn.layer setShadowOpacity:0.5];
        
        [skipBtn addTarget:self
                    action:@selector(okayBtnHandler:)
          forControlEvents:UIControlEventTouchDown];
        
        [self.view addSubview:notRewardedView];
        [notRewardedView addSubview:notRewardedLbl];
        [notRewardedView addSubview:skipBtn];
    }

}

- (void)okayBtnHandler:sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)saveForLaterBtnHandler:sender {
    [self.navigationController popToRootViewControllerAnimated:YES];    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
    
    NSString *validatePasswordUrlString = [NSString stringWithFormat:@"%@checkPassword/%@/%@", GOOSIIAPI, self.company.companyId, textField.text];
    
    NSURL *url = [NSURL URLWithString:validatePasswordUrlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&requestError];
    
    NSString* newStr = [[NSString alloc] initWithData:response
                                             encoding:NSUTF8StringEncoding];
    
    NSLog(@"THE REWARD RESPONSE %@", newStr);
    
    if([newStr isEqualToString:@"valid"]) {
        NSLog(@"Success XOXOXOXOXOXOXOXOX");
        
        [self displayRewardModalView];
    }
}

- (void)displayRewardModalView {
    
    CGRect rewardRect = CGRectMake(10, 100, 300, 300);
    UIView *rewardView = [[UIView alloc] initWithFrame:rewardRect];
    
    [rewardView setBackgroundColor:[self colorWithHexString:@"ffffff" ]];
    
    CGRect instructionRect = CGRectMake(10, 20, 280, 200);
    UITextView *instructions = [[UITextView alloc] initWithFrame:instructionRect];
    NSString *instructText = [NSString stringWithFormat:@"Give this customer: %@", self.company.prize];
    [instructions setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    instructions.textAlignment = NSTextAlignmentCenter;
    instructions.text = instructText;
    
    CGRect validateBtnRect = CGRectMake(10, 220, 280, 50);
    UIButton *validateBtn = [[UIButton alloc] initWithFrame:validateBtnRect];
    
    [validateBtn setBackgroundColor:[self colorWithHexString:@"3b5999"]];
    
    [validateBtn setTitle:@"Validate!" forState:UIControlStateNormal];
    [validateBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    [validateBtn.titleLabel setTextColor:[UIColor whiteColor]];
    
    [validateBtn.layer setBorderWidth:3.0];
    [validateBtn.layer setBorderColor:[[UIColor blackColor] CGColor]];
    
    [validateBtn.layer setShadowOffset:CGSizeMake(5, 5)];
    [validateBtn.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [validateBtn.layer setShadowOpacity:0.5];
    
    [validateBtn addTarget:self
                action:@selector(validateBtnHandler:)
      forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:rewardView];
    [rewardView addSubview:instructions];
    [rewardView addSubview:validateBtn];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    if (textField.tag == 1) {
        UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:2];
        [passwordTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)validateBtnHandler:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setTextInputField:nil];
    [self setCompanyNameLbl:nil];
    [self setUserIntructTxtField:nil];
    [super viewDidUnload];
}

-(UIColor*)colorWithHexString:(NSString*)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


@end
