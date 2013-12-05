//
//  GICompanyInfoController.m
//  Goosii
//
//  Created by Justin Warmkessel on 12/3/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GICompanyInfoController.h"
#import "GIEventBoardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "GICompany.h"

@interface GICompanyInfoController ()
@property (nonatomic, strong) GIEventBoardViewController *eventViewController;
@property (strong, nonatomic) IBOutlet UIButton *telBtn;
- (IBAction)telBtnHandler:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *rewardImageView;
@property (strong, nonatomic) IBOutlet UILabel *rewardLbl;
@end

@implementation GICompanyInfoController
@synthesize eventViewController, company;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil company:(GICompany *)companyObj {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect rect = CGRectMake(10, 0, 300, 300);
        self.view.frame = rect;
        self.company = companyObj;
        
        NSLog(@"INITALIZING %@", self.company.companyId);
    }
    return self;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect rect = CGRectMake(10, 0, 300, 300);
        self.view.frame = rect;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //I need to set these items because company doesn't get allocated to memory until this point for some reason.
    [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@/companyAssets/%@/rewardImageThumb.png", kBASE_URL, self.company.companyId] fromDisk:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/companyAssets/%@/rewardImage.jpg", kBASE_URL, self.company.companyId];
    
    NSLog(@"%@", urlString);
    
    [self.rewardImageView setImageWithURL:[NSURL URLWithString:urlString]
            placeholderImage:[UIImage imageNamed:@"backgroundImage.jpg"]];
    
    [self.rewardImageView setCenter:CGPointMake(self.view.center.x - 10, 120)];
    [self.rewardLbl setText:self.company.prize];

    
    /*NEW TRICKS I'm using interface builder to set the cornerRadius and borderWidth. Check "Identity Inspector" and "Run time attributes".
     
     Self.telBtn is manually adjusted in the xib to be centered as the setCenter() doesn't work well with interface builder.
     */
    [self.telBtn setTitle:[NSString stringWithFormat:@"Tel: %@", self.company.telephone] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view setAlpha:0];

    [self.view setBackgroundColor:[self colorWithHexString:@"C63D0F"]];

    [self.view.layer setBorderColor:[self colorWithHexString:@"C63D0F"].CGColor];
    [self.view.layer setBorderWidth:1.5f];
    [self.view.layer setCornerRadius:3];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setAlpha:1.0];
        
        CGRect rect = CGRectMake(self.view.frame.origin.x, 60, 300, 300);
        
        self.view.frame = rect;
        
    } completion:^(BOOL finished) {
        NSLog(@"Animation complete");
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.eventViewController = (GIEventBoardViewController*) self.parentViewController;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect closeCompanyInfoViewBtnRect = CGRectMake(10, 220.0, 230.0, 45.0);
    if(screenHeight < 568) {
        closeCompanyInfoViewBtnRect = CGRectMake(10, 220.0, 230.0, 45.0);
    }
    
    UIButton *closeCompanyInfoViewBtn = [[UIButton alloc] initWithFrame:closeCompanyInfoViewBtnRect];
    [closeCompanyInfoViewBtn setBackgroundColor:[self colorWithHexString:@"3b5999"]];
    
    [closeCompanyInfoViewBtn setCenter:CGPointMake(self.view.center.x - 10, 270.0)];
    
    [closeCompanyInfoViewBtn.layer setCornerRadius:3];
    [closeCompanyInfoViewBtn setTitle:@"Okay" forState:UIControlStateNormal];
    [closeCompanyInfoViewBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    [closeCompanyInfoViewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeCompanyInfoViewBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [closeCompanyInfoViewBtn.layer setShadowColor:[UIColor blackColor].CGColor];
    [closeCompanyInfoViewBtn.layer setShadowOpacity:0.8];
    [closeCompanyInfoViewBtn.layer setShadowRadius:3.0];
    
    [closeCompanyInfoViewBtn addTarget:self
                                action:@selector(closeCompanyInfoView:)
                      forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:closeCompanyInfoViewBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeCompanyInfoView:(id)sender {
    GIEventBoardViewController *parentVC = (GIEventBoardViewController *)self.parentViewController;
    parentVC.infoBtn.enabled = YES;
    [parentVC.tableView setAlpha:1];
    
    [UIView animateWithDuration:0.8 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, -500, self.view.frame.size.width, self.view.frame.size.height);
        
        [self.view setAlpha:0];
        
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
    }];
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

- (IBAction)telBtnHandler:(id)sender {
    UIApplication *myApp = [UIApplication sharedApplication];
    NSString *theCall = [NSString stringWithFormat:@"tel://%@", [NSString stringWithFormat:@"%@", self.company.telephone]];
    NSLog(@"making call with %@",theCall);
    [myApp openURL:[NSURL URLWithString:theCall]];
}
@end
