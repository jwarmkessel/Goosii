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
@property (strong, nonatomic) UIButton *telBtn;
@property (strong, nonatomic) IBOutlet UIImageView *rewardImageView;
@property (strong, nonatomic) IBOutlet UILabel *rewardLbl;
@property (strong, nonatomic) UIButton *addressLbl;
@end

@implementation GICompanyInfoController
@synthesize eventViewController, company, addressLbl, telBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil company:(GICompany *)companyObj {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect rect = CGRectMake(10, 0, 300, 400);
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
        CGRect rect = CGRectMake(10, 0, 300, 400);
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
    [self.rewardLbl setTextColor:[UIColor whiteColor]];
    [self.rewardLbl.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.rewardLbl.layer setShadowOpacity:0.8];
    [self.rewardLbl.layer setShadowRadius:3.0];
    CGRect telBtnRect = CGRectMake(9.000000, 208.000000, 280.000000, 30.000000);
    
    self.telBtn = [[UIButton alloc] initWithFrame:telBtnRect];
    [self.telBtn setTitle:[NSString stringWithFormat:@"Tel: %@", self.company.telephone] forState:UIControlStateNormal];
    [self.telBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    [self.telBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.telBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
//    [self.telBtn.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.telBtn.layer setShadowOpacity:0.8];
//    [self.telBtn.layer setShadowRadius:3.0];

    [self.telBtn setTitle:[NSString stringWithFormat:@"Tel: %@", self.company.telephone] forState:UIControlStateNormal];

    [self.telBtn.layer setBorderColor:[self colorWithHexString:@"3B5999"].CGColor];
    [self.telBtn.layer setBorderWidth:1.5f];
    [self.telBtn.layer setCornerRadius:3];

    self.telBtn.titleLabel.minimumScaleFactor = 8.0/[UIFont labelFontSize];
    self.telBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.view addSubview:self.telBtn];
    
    [self.telBtn addTarget:self
                    action:@selector(telBtnHandler:)
          forControlEvents:UIControlEventTouchUpInside];

    
    CGRect addressButtonRect = CGRectMake(9.000000, 246.000000, 280.000000, 30.000000);
    self.addressLbl = [[UIButton alloc] initWithFrame:addressButtonRect];
    
    [self.addressLbl setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addressLbl setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
//    [self.addressLbl.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.addressLbl.layer setShadowOpacity:0.8];
//    [self.addressLbl.layer setShadowRadius:3.0];
    
    [self.addressLbl setTitle:self.company.address forState:UIControlStateNormal];

//    [self.addressLbl.layer setBorderColor:[self colorWithHexString:@"3B5999"].CGColor];
//    [self.addressLbl.layer setBorderWidth:1.5f];
//    [self.addressLbl.layer setCornerRadius:3];
    
    self.addressLbl.titleLabel.minimumScaleFactor = 8.0/[UIFont labelFontSize];
    self.addressLbl.titleLabel.adjustsFontSizeToFitWidth = YES;

    [self.view addSubview:self.addressLbl];
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
        
        CGRect rect = CGRectMake(self.view.frame.origin.x, 60, 300, 400);
        
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


    
//    [self.addressLbl.titleLabel setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
//    [self.addressLbl setTintColor:[self colorWithHexString:@"C63D0f"]];

    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect closeCompanyInfoViewBtnRect = CGRectMake(10, 320.0, 230.0, 45.0);
    if(screenHeight < 568) {
        closeCompanyInfoViewBtnRect = CGRectMake(10, 320.0, 230.0, 45.0);
    }
    
    UIButton *closeCompanyInfoViewBtn = [[UIButton alloc] initWithFrame:closeCompanyInfoViewBtnRect];
    [closeCompanyInfoViewBtn setBackgroundColor:[self colorWithHexString:@"3b5999"]];
    
    [closeCompanyInfoViewBtn setCenter:CGPointMake(self.view.center.x - 10, 370.0)];
    
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

- (void)telBtnHandler:(id)sender {
    UIApplication *myApp = [UIApplication sharedApplication];
    NSString *theCall = [NSString stringWithFormat:@"tel://%@", [NSString stringWithFormat:@"%@", self.company.telephone]];
    NSLog(@"making call with %@",theCall);
    [myApp openURL:[NSURL URLWithString:theCall]];
}
@end
