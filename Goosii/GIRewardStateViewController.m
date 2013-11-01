//
//  GIRewardStateViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 9/3/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIRewardStateViewController.h"
#import "GICompany.h"
#import <QuartzCore/QuartzCore.h>
#import "GIPlist.h"
#import <ECSlidingViewController.h>

@interface GIRewardStateViewController ()

@end

@implementation GIRewardStateViewController
@synthesize company, isRewarded;

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
	// Do any additional setup after loading the view.
    //Set image for the tableview background
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSString *urlString = [NSString stringWithFormat:@"%@/companyAssets/%@/rewardImage.jpg", kBASE_URL, self.company.companyId];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    
    imgView.image = img;
    
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    NSString *urlRewardString = [NSString stringWithFormat:@"%@getReward/%@/%@", GOOSIIAPI, self.company.companyId, [plist objectForKey:@"userId"]];
    
    NSLog(@"getUserContests %@", urlRewardString);
    NSURL *getRewardUrl = [NSURL URLWithString:urlRewardString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:getRewardUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&requestError];
    
    NSString* newStr = [[NSString alloc] initWithData:response
                                             encoding:NSUTF8StringEncoding];

    NSLog(@"THE REWARD RESPONSE %@", newStr);
    //The Company name and Info Panel
    UILabel *rewardStateLbl = [[UILabel alloc] initWithFrame:CGRectMake((320/2-160), 50 , 320.0, 40.0)];
    
    if([newStr isEqual: @"NO"]) {
        rewardStateLbl.text = @"You didn't win this time.";
    } else {
        rewardStateLbl.text = @"You've WON";   
    }
    
    [rewardStateLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0]];
    rewardStateLbl.textColor = [UIColor whiteColor];
    rewardStateLbl.backgroundColor = [UIColor clearColor];
    rewardStateLbl.textAlignment = NSTextAlignmentCenter;
    
    UIView *transparentWinStateCell = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, 40.0)];
    [transparentWinStateCell setAlpha:1];
    [transparentWinStateCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    transparentWinStateCell.layer.shadowColor = [UIColor blackColor].CGColor;
    transparentWinStateCell.layer.shadowOpacity = 0.5;
    transparentWinStateCell.layer.shadowRadius = 3;
    transparentWinStateCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
    transparentWinStateCell.layer.cornerRadius = 4;

    //The Company name and Info Panel
    UILabel *companyNameLbl = [[UILabel alloc] initWithFrame:CGRectMake((320/2-160), 100 , 320.0, 40.0)];
    companyNameLbl.text = self.company.name;
    [companyNameLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0]];
    companyNameLbl.textColor = [UIColor whiteColor];
    companyNameLbl.backgroundColor = [UIColor clearColor];
    companyNameLbl.textAlignment = NSTextAlignmentCenter;
    
    UIView *transparentCompanyNameCell = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 320, 40.0)];
    [transparentCompanyNameCell setAlpha:1];
    [transparentCompanyNameCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    transparentCompanyNameCell.layer.shadowColor = [UIColor blackColor].CGColor;
    transparentCompanyNameCell.layer.shadowOpacity = 0.5;
    transparentCompanyNameCell.layer.shadowRadius = 3;
    transparentCompanyNameCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
    transparentCompanyNameCell.layer.cornerRadius = 4;
    
    UITextView *rewardInstructions = [[UITextView alloc] initWithFrame:CGRectMake(0, 150, 320, 200)];
    
    if([newStr isEqual: @"NO"]) {
        rewardInstructions.text = @"Hey, don't worry too much about not being rewarded this time. You're automatically entered into every event, so you have plenty of chances.";
    } else {
        rewardInstructions.text = @"To collect your reward return to this establishment, check-in, and allow an employee to validate your reward.";
    }
    
    [rewardInstructions setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    [rewardInstructions setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]];
    rewardInstructions.textColor = [UIColor whiteColor];
    rewardInstructions.textAlignment = NSTextAlignmentCenter;
    
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

    [self.view addSubview:imgView];
    [self.view addSubview:transparentWinStateCell];
    [self.view addSubview:rewardStateLbl];
    
    [self.view addSubview:transparentCompanyNameCell];
    [self.view addSubview:companyNameLbl];
    
    [self.view addSubview:rewardInstructions];
    
    [self.view addSubview:skipBtn];
}

- (void)okayBtnHandler:sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setAlpha:0.0f];
    self.slidingViewController.panGesture.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
