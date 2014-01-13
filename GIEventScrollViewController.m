//
//  GIEventScrollViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 12/18/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIEventScrollViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GIProgressBar.h"
#import <QuartzCore/QuartzCore.h>
#import "GICountingLabel.h"
#import <Social/Social.h>
#import "GIPlist.h"
#import "GICompany.h"
#import "GICheckinViewController.h"
#import "GIRewardEmployeeController.h"

@interface GIEventScrollViewController () {
    UITextView *sharingTextView;
}
@property (nonatomic, strong) UIView *imageMaskView;
@property (nonatomic, strong) CAGradientLayer *maskLayer;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurView;

@property (nonatomic, strong) GIProgressBar *timeDurationBar;
@property (nonatomic, strong) UILabel *participationLbl;
@property (nonatomic, strong) GIProgressBar *participationBar;
@property (nonatomic, strong) UILabel *participateTitleLbl;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UILabel *companyNameLbl;
@property (nonatomic, strong) UILabel *companyLbl;

@property (nonatomic, strong) GIRewardEmployeeController *rewardEmployeeView;

@property (nonatomic, strong) UIImageView *rewardImageView;

@end

@implementation GIEventScrollViewController
@synthesize eventScrollView, timeDurationBar, participationLbl, participateTitleLbl, toggle, blinkTimer, company, webView, rewardEmployeeView;

BOOL isEvent = 1;
BOOL isTransformed = 0;

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //I need to set these items because company doesn't get allocated to memory until this point for some reason.
    _backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/companyAssets/%@/backgroundImage.jpg", kBASE_URL, self.company.companyId];
    
    
    /************* Test last moidifed code*/
    
    [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@/companyAssets/%@/backgroundImage.jpg", kBASE_URL, self.company.companyId] fromDisk:YES];
//
//    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@/companyAssets/%@/backgroundImage.jpg", kBASE_URL, self.company.companyId]];
//    
//    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@/companyAssets/%@/backgroundImage.jpg", kBASE_URL, self.company.companyId]];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//        /* retrieve file attributes */
//        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
//        if (attributes != nil) {
//            self.fileDate = [attributes fileModificationDate];
//        }
//        else {
//            URLCacheAlertWithError(error);
//        }
//    }
//    
    
    /***************************************/
    
//    [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@/companyAssets/%@/backgroundImage.jpg", kBASE_URL, self.company.companyId] fromDisk:YES];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    [request setHTTPMethod:@"HEAD"];
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//                               if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
//                                   NSString *lastModifiedString = [[httpResponse allHeaderFields] objectForKey:@"Last-Modified"];
//                                   NSLog(@"THE LAST MODIFIED STRING %@", lastModifiedString);
//                               }
//                           }];
    
//    [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@/companyAssets/%@/backgroundImage.jpg", kBASE_URL, self.company.companyId] fromDisk:YES];
    
    [_backgroundImageView setImageWithURL:[NSURL URLWithString:urlString]
                         placeholderImage:[UIImage imageNamed:@"backgroundImage.jpg"]];
    
    self.imageMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [self.imageMaskView setBackgroundColor:[UIColor blackColor]];
    [self.imageMaskView setAlpha:1];
    
//    self.blurView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, 320, 568)];
//    [self.view addSubview:self.blurView];
    
    [self.eventScrollView setDelegate:self];
    [self.eventScrollView setBackgroundColor:[UIColor clearColor]];
    [self.eventScrollView setContentSize:CGSizeMake(320, 1000)];
    self.eventScrollView.frame = CGRectMake(0,0,320,568);
    
    [self.view addSubview:_backgroundImageView];
    //    [self.view bringSubviewToFront:_backgroundImageView];
    //    [self.view bringSubviewToFront:self.imageMaskView];
    //    [self.view bringSubviewToFront:self.blurView];
    [self.view bringSubviewToFront:self.eventScrollView];
    
    if(!isEvent) {
        [self.view bringSubviewToFront:self.webView];
    }
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    
    //Make the call to action text animate with blinking.
    blinkTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(toggleButtonImage:) userInfo:nil repeats: YES];

    //Set the color of the NavBar
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.tintColor = [self colorWithHexString:@"C63D0F"];
  
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        self.wantsFullScreenLayout = YES;
    #pragma GCC diagnostic warning "-Wdeprecated-declarations"
    } else {
        self.navigationController.navigationBar.barTintColor = [self colorWithHexString:@"C63D0F"];
  
    }
    
//    self.navigationController.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//    self.navigationController.navigationBar.layer.shadowRadius = 3.0f;
//    
//  
//    self.navigationController.navigationBar.translucent = NO;
//    [self.navigationController.navigationBar setAlpha:1];
    self.navigationController.navigationBar.translucent = YES;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
//    self.eventScrollView.bounces = NO;
    
    

    //Override the back button.
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"Checkin"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(handleBack:)];

    self.navigationItem.leftBarButtonItem = self.backButton;


    //Set the reward image but hide it first.
    self.rewardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.000000, 63.000000, 320.000000, 178.000000)];
    
    [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@/companyAssets/%@/rewardImage.jpg", kBASE_URL, self.company.companyId] fromDisk:YES];
    
    NSString *rewardImageUrlString = [NSString stringWithFormat:@"%@/companyAssets/%@/rewardImage.jpg", kBASE_URL, self.company.companyId];
    
    NSLog(@"%@", rewardImageUrlString);
    
    [self.rewardImageView setImageWithURL:[NSURL URLWithString:rewardImageUrlString]
                         placeholderImage:[UIImage imageNamed:@"rewardBackgroundPlaceholder.png"]];
    
    [self.eventScrollView addSubview:self.rewardImageView];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.rewardImageView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    [self.rewardImageView.layer insertSublayer:gradient atIndex:0];
    
    UILabel *rewardDescLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.000000, 120.000000, 320.000000, 63.000000)];
    rewardDescLbl.text = self.company.prize;
    rewardDescLbl.textAlignment = NSTextAlignmentCenter;
    [rewardDescLbl setFont:[UIFont fontWithName:@"AppleSDGothicNeo-medium" size:16]];
    rewardDescLbl.textColor = [UIColor whiteColor];
    [self.rewardImageView addSubview:rewardDescLbl];
    
    _companyLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.000000, 238.000000, 320.000000, 178.000000)];
    [_companyLbl setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    [_companyLbl setAlpha:0.6];
    [self.eventScrollView addSubview:_companyLbl];
    
    NSLog(@"First Background Tag 1 %f, %f, %f, %f", _companyLbl.frame.origin.x, _companyLbl.frame.origin.y, _companyLbl.frame.size.width, _companyLbl.frame.size.height );
    _companyNameLbl = [[UILabel alloc] initWithFrame:_companyLbl.frame];
    _companyNameLbl.text = self.company.name;
    _companyNameLbl.textAlignment = NSTextAlignmentCenter;
    [_companyNameLbl setFont:[UIFont systemFontOfSize:30]];
    _companyNameLbl.textColor = [UIColor whiteColor];
    
    [self.eventScrollView addSubview:_companyNameLbl];
    
    
    UISwipeGestureRecognizer * SwipeLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
    [SwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_companyNameLbl setUserInteractionEnabled:YES];
    [_companyNameLbl addGestureRecognizer:SwipeLeft];
    
//    UISwipeGestureRecognizer * SwipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
//    [SwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
//    [_companyNameLbl setUserInteractionEnabled:YES];
//    [_companyNameLbl addGestureRecognizer:SwipeRight];
    
    
    UILabel *localsLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.000000, 417.000000, 320.000000, 188.000000)];
    [localsLbl setBackgroundColor:[self colorWithHexString:@"FDF3E7"]];
    [localsLbl setAlpha:0.8];
    [self.eventScrollView addSubview: localsLbl];
    NSLog(@"First Background Tag 2 %f, %f, %f, %f", localsLbl.frame.origin.x, localsLbl.frame.origin.y, localsLbl.frame.size.width, localsLbl.frame.size.height );
    GICountingLabel *localsTotalLbl = [[GICountingLabel alloc] initWithFrame:CGRectMake(localsLbl.frame.origin.x, localsLbl.frame.origin    .y, localsLbl.frame.size.width, (localsLbl.frame.size.height/2))];
    localsTotalLbl.format = @"%d Participating";
    localsTotalLbl.method = UILabelCountingMethodLinear;
    [localsTotalLbl countFrom:0 to:[self.company.totalParticipants floatValue] withDuration:3.0f];

    localsTotalLbl.textAlignment = NSTextAlignmentLeft;
    [localsTotalLbl setFont:[UIFont fontWithName:@"AppleSDGothicNeo-medium" size:40]];
    localsTotalLbl.textColor = [self colorWithHexString:@"3B3738"];
    
    [self.eventScrollView addSubview:localsTotalLbl];
    
    /***********************************************/
    //Logic for the TIME Progress Bar
    /***********************************************/
    float progressBarThickness = 50.0f;
    float progressBarWidth = 300.0f;
    
    //Convert milliseconds to seconds.
    NSTimeInterval seconds = [self.company.endDate floatValue];
    seconds = seconds / 1000;
    
    //Initiate the date object and formatter and set the participation string.
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm";
    NSString *timeStamp = [dateFormatter stringFromDate:epochNSDate];
    NSString *announceDateStr = [NSString stringWithFormat:@"Reward to be announced %@", timeStamp];
    
    UILabel *endDateLbl = [[UILabel alloc] initWithFrame:CGRectMake(localsTotalLbl.frame.origin.x + 15, localsTotalLbl.frame.origin.y + 70, progressBarWidth, progressBarThickness)];
    endDateLbl.text = announceDateStr;
    [endDateLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:13.0]];
    endDateLbl.textColor = [UIColor whiteColor];
    endDateLbl.backgroundColor = [UIColor clearColor];
    
    CGRect timeDurationBarRect = CGRectMake(localsTotalLbl.frame.origin.x + 10, localsTotalLbl.frame.origin.y + 70, 0, progressBarThickness);
    
    //Set the color of the progress bars.
    CGRect backgroundRect = CGRectMake(localsTotalLbl.frame.origin.x + 10, localsTotalLbl.frame.origin.y + 70, progressBarWidth, progressBarThickness);
    
    GIProgressBar *backgroundProgressBar = [[GIProgressBar alloc] initWithFrame:backgroundRect hexStringColor:@"3B3738"];
    [backgroundProgressBar setAlpha:0.6];

    self.timeDurationBar = [[GIProgressBar alloc] initWithFrame:timeDurationBarRect hexStringColor:@"2D5D28"];
    
    [self.eventScrollView addSubview:backgroundProgressBar];
    [self.eventScrollView addSubview:self.timeDurationBar];
    [self.eventScrollView addSubview:endDateLbl];
    
    //Animate the progress bars to juic-ify this app!
    [UIView animateWithDuration:1 animations:^{
        
        float percentWidth = [self.company.timePercentage floatValue] * progressBarWidth;
        NSLog(@"The caluc %f", percentWidth);
        self.timeDurationBar.frame = CGRectMake(localsTotalLbl.frame.origin.x + 10, localsTotalLbl.frame.origin.y + 70, percentWidth, progressBarThickness);
        
    } completion:^(BOOL finished) {
        NSLog(@"done");
    }];

    
    /***********************************************/
    //Logic for the Participation Progress
    /***********************************************/
    
    self.participationLbl = [[UILabel alloc] initWithFrame:CGRectMake(localsTotalLbl.frame.origin.x + 15, localsTotalLbl.frame.origin.y + 130, progressBarWidth, progressBarThickness)];
    
    float participationNum = [@"0" floatValue] * 100;
    
    self.participationLbl.text = [NSString stringWithFormat:@"%i%% Participation", (int) participationNum];
    [self.participationLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:13.0f]];
    self.participationLbl.textColor = [UIColor whiteColor];
    self.participationLbl.backgroundColor = [UIColor clearColor];
    
    //Progress bar elements for participation rate and the duration of the contest.
    CGRect participationBarBackgroundRect = CGRectMake(localsTotalLbl.frame.origin.x + 10, localsTotalLbl.frame.origin.y + 130, progressBarWidth, progressBarThickness);
    
    GIProgressBar *participationBarBackground = [[GIProgressBar alloc] initWithFrame:participationBarBackgroundRect hexStringColor:@"3B3738"];
    [participationBarBackground setAlpha:0.6];
    
    CGRect participationBarRect = CGRectMake(localsTotalLbl.frame.origin.x + 10, localsTotalLbl.frame.origin.y + 130, 0, progressBarThickness);

    self.participationBar = [[GIProgressBar alloc] initWithFrame:participationBarRect hexStringColor:@"2D5D28"];
    
    [self.eventScrollView addSubview:participationBarBackground];
    [self.eventScrollView addSubview:self.participationBar];
    [self.eventScrollView addSubview:self.participationLbl];

    //Animate the progress bars to juic-ify this app!
    [UIView animateWithDuration:1 animations:^{
        
        float partWidth = [self.company.participationPercentage floatValue] * progressBarWidth;
        NSLog(@"The calculation %f", partWidth);
        self.participationBar.frame = CGRectMake(localsTotalLbl.frame.origin.x + 10, localsTotalLbl.frame.origin.y + 130, partWidth, progressBarThickness);
        
    } completion:^(BOOL finished) {
        NSLog(@"done");
    }];

    
    /***********************************************/
    self.participateTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(localsTotalLbl.frame.origin.x + 5, localsTotalLbl.frame.origin.y + 180, progressBarWidth, progressBarThickness)];
    
    participateTitleLbl.text = @"Participate to improve you odds!";
    [participateTitleLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:10.0f]];
    participateTitleLbl.textColor = [UIColor whiteColor];
    participateTitleLbl.backgroundColor = [UIColor clearColor];
    
    UILabel *fulfillmentBackground = [[UILabel alloc] initWithFrame:CGRectMake(0.000000, 605.000000, 320.000000, 188.000000)];
    [fulfillmentBackground setBackgroundColor:[self colorWithHexString:@"7E8F7C"]];
    [fulfillmentBackground setAlpha:0.8];
    [self.eventScrollView addSubview: fulfillmentBackground];

    
    //FACEBOOK
    
    CGRect facebookBtnRect = CGRectMake(localsTotalLbl.frame.origin.x + 10, localsTotalLbl.frame.origin.y + 220, progressBarWidth, progressBarThickness);
    UIButton *facebookBtn = [[UIButton alloc] initWithFrame:facebookBtnRect];
    [facebookBtn setBackgroundColor:[self colorWithHexString:@"3b5999"]];
    
    [facebookBtn.layer setCornerRadius:3];
    [facebookBtn setTitle:@"Facebook" forState:UIControlStateNormal];
    [facebookBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    [facebookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [facebookBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [facebookBtn.layer setShadowColor:[UIColor blackColor].CGColor];
    [facebookBtn.layer setShadowOpacity:0.8];
    [facebookBtn.layer setShadowRadius:3.0];
    
    [self.eventScrollView addSubview:participateTitleLbl];
    [self.eventScrollView addSubview:facebookBtn];
    
    [facebookBtn addTarget:self
                    action:@selector(fbParticipationBtnHandler)
          forControlEvents:UIControlEventTouchUpInside];
    
    //TWITTER
    
    CGRect twitterBtnRect = CGRectMake(localsTotalLbl.frame.origin.x + 10, localsTotalLbl.frame.origin.y + 280, progressBarWidth, progressBarThickness);
    UIButton *twitterBtn = [[UIButton alloc] initWithFrame:twitterBtnRect];
    [twitterBtn setBackgroundColor:[self colorWithHexString:@"1dcaff"]];
    
    [twitterBtn.layer setCornerRadius:3];
    [twitterBtn setTitle:@"Twitter" forState:UIControlStateNormal];
    [twitterBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    [twitterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [twitterBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [twitterBtn.layer setShadowColor:[UIColor blackColor].CGColor];
    [twitterBtn.layer setShadowOpacity:0.8];
    [twitterBtn.layer setShadowRadius:3.0];
    
    [self.eventScrollView addSubview:twitterBtn];
    
    [twitterBtn addTarget:self
                   action:@selector(twitterParticipationBtnHandler)
         forControlEvents:UIControlEventTouchUpInside];
    
    //Enter the user into the contest if they haven't already.
//    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
//    
//    NSString *enterEventUrlString = [NSString stringWithFormat:@"%@enterContest/%@/%@", GOOSIIAPI,[plist objectForKey:@"userId"], self.company.companyId];
//    
//    NSURL *enterEventURL = [NSURL URLWithString:enterEventUrlString];
//    NSURLRequest *enterEventRequest = [NSURLRequest requestWithURL:enterEventURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    
//    [NSURLConnection sendAsynchronousRequest:enterEventRequest
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                               
//                               // your data or an error will be ready here
//                               NSString* newStr = [[NSString alloc] initWithData:data
//                                                                        encoding:NSUTF8StringEncoding];
//                               NSLog(@"response: %@", newStr);
//                               
//                               //If this is the first time checking in.
//                               if([newStr isEqualToString:@"YES"]) {
//                                   
//                                   rewardEmployeeView = [[GIRewardEmployeeController alloc] initWithNibName:@"GIRewardEmployeeController" bundle:nil];
//                                   [self addChildViewController:rewardEmployeeView];
//                                   
//                                   if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//                                       [self.rewardEmployeeView.view setCenter:CGPointMake(self.rewardEmployeeView.view.center.x, (self.rewardEmployeeView.view.center.y - 20.0))];
//                                   }
//                                   
//                                   [self.eventScrollView addSubview:rewardEmployeeView.view];
//                                   
//                                   UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(refreshPropertyList:)];
//                                   self.navigationItem.rightBarButtonItem = anotherButton;
//                               }
//                           }];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)swipe {
    
    NSLog(@"swipeLeft");
    NSLog(@"x %f y %f", _companyNameLbl.layer.anchorPoint.x, _companyNameLbl.layer.anchorPoint.y);
    NSLog(@"z %f", _companyNameLbl.layer.anchorPointZ);

    
    [UIView animateWithDuration:0.5 animations:^{
        
        if(!isTransformed){
            [_companyLbl setAlpha:0.1];
            [_companyNameLbl setAlpha:0.1];
            _companyLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
            _companyNameLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
            isTransformed = 1;
        }else {
            _companyLbl.layer.transform = CATransform3DMakeRotation(0, 0.0f, 1.0f, 0.0f);
            _companyNameLbl.layer.transform = CATransform3DMakeRotation(0, 0.0f, 1.0f, 0.0f);
            [_companyLbl setAlpha:0.5];
            [_companyNameLbl setAlpha:1];
            isTransformed = 0;
        }
        
//        if(swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
//            NSLog(@"Swipe Gesture Left LEEEFFFTTTT");
//            if(_companyNameLbl.layer.anchorPoint.x == 0) {
//                NSLog(@"swipe --> 0");
//                _companyLbl.layer.transform = CATransform3DMakeRotation((0), 0.0f, 1.0f, 0.0f);
//                _companyNameLbl.layer.transform = CATransform3DMakeRotation((0), 0.0f, 1.0f, 0.0f);
//                
//            }else {
//                NSLog(@"swipe --> 5");
//                _companyLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
//                _companyNameLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
//            }
//        } else if(swipe.direction == UISwipeGestureRecognizerDirectionRight) {
//            NSLog(@"Swipe Gesture Right");
//            if(_companyNameLbl.layer.anchorPoint.x == 0) {
//                NSLog(@"swipe --> 0");
//                _companyLbl.layer.transform = CATransform3DMakeRotation((0), 0.0f, 1.0f, 0.0f);
//                _companyNameLbl.layer.transform = CATransform3DMakeRotation((0), 0.0f, 1.0f, 0.0f);
//                
//            }else {
//                NSLog(@"swipe --> 5");
//                _companyLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
//                _companyNameLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
//            }
//        }
    } completion:^(BOOL finished) {
        NSLog(@"Complete");
    }];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)swipe {
    
    NSLog(@"swipeRight");
    NSLog(@"x %f y %f", _companyNameLbl.layer.anchorPoint.x, _companyNameLbl.layer.anchorPoint.y);
    NSLog(@"z %f", _companyNameLbl.layer.anchorPointZ);

    
    [UIView animateWithDuration:1.0 animations:^{
        
        if(swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
            NSLog(@"Swipe Gesture Left RIIIIIGHT");
            if(_companyNameLbl.layer.anchorPoint.x == 0) {
                NSLog(@"swipe --> 0");
                _companyLbl.layer.transform = CATransform3DMakeRotation((0), 0.0f, 1.0f, 0.0f);
                _companyNameLbl.layer.transform = CATransform3DMakeRotation((0), 0.0f, 1.0f, 0.0f);
                
            }else {
                NSLog(@"swipe --> 5");
                _companyLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
                _companyNameLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
            }
        } else if(swipe.direction == UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"Swipe Gesture Right");
            if(_companyNameLbl.layer.anchorPoint.x == 0) {
                NSLog(@"swipe --> 0");
                _companyLbl.layer.transform = CATransform3DMakeRotation((0), 0.0f, 1.0f, 0.0f);
                _companyNameLbl.layer.transform = CATransform3DMakeRotation((0), 0.0f, 1.0f, 0.0f);
                
            }else {
                NSLog(@"swipe --> 5");
                _companyLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
                _companyNameLbl.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
            }
        }

        
    } completion:^(BOOL finished) {
        NSLog(@"Complete");
    }];
}
-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    
    //blur the image http://evandavis.me/blog/2013/2/13/getting-creative-with-calayer-masks
//    [self setupBlurredImage];
    
    //setting up corresponding mask for the button.
//    self.maskLayer = [CALayer layer];
//    self.maskLayer.frame = CGRectMake(0,0,320,568);
    //    self.maskLayer.cornerRadius = self.testButton.layer.cornerRadius;
//    self.maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    //self.blurView.layer.mask = self.maskLayer;
    
//    [self.view sendSubviewToBack:_backgroundImageView];
//    [self.view bringSubviewToFront:self.eventScrollView];

}

- (void) handleBack:(id)sender {
    // pop to root view controller
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    NSLog(@"Nav controller array %lu", (unsigned long)[[self.navigationController viewControllers] count]);
    int parentViewControllerIndex = [viewControllerArray count] - 2;
    
    if([[self.navigationController.viewControllers objectAtIndex:(parentViewControllerIndex)] isKindOfClass:[GICheckinViewController class]]) {
        
        GICheckinViewController *checkinViewController = [self.navigationController.viewControllers objectAtIndex:(parentViewControllerIndex)];
        
        [checkinViewController setInset];
        [checkinViewController.locationManager startUpdatingLocation];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//blur the image
- (void)setupBlurredImage
{
    UIImage *theImage;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/companyAssets/%@/backgroundImage.jpg", kBASE_URL, @"5233805ec22ccd54d6fd2cff"];
    
    NSURL *url = [NSURL URLWithString: urlString];
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];

    theImage = image;
    
//    theImage = _backgroundImageView.image;
    
    //create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    //setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    //CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    //add our blurred image to the scrollview
    self.blurView.image = [UIImage imageWithCGImage:cgImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    CGPoint offset = scrollView.contentOffset;
    
    CGRect buttonFrame = CGRectMake(0,0,320, 568);
    buttonFrame.origin.x += offset.x;
    buttonFrame.origin.y += offset.y;
    NSLog(@"button's frame: %f, %f, %f, %f", buttonFrame.origin.x, buttonFrame.origin.y, buttonFrame.size.width, buttonFrame.size.height);
    //without the CATransaction the mask's frame setting is actually slighty animated, appearing to give it a delay as we scroll around
//    [CATransaction begin];
//    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//    self.maskLayer.frame = buttonFrame;
//    [CATransaction commit];
    
}                                               // any offset changes
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2) {} // any zoom scale changes

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0) {}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {}   // called on finger up as we are moving
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{}  // called when scroll view grinds to a halt

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {}// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scrollView;
}     // return a view that will be scaled. if delegate returns nil, nothing happens

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
}// scale between minimum and maximum. called after any 'bounce' animations

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
 
    return YES;
}// return a yes if you want to scroll to the top. if not defined, assumes YES
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
}// called when scrolling animation finished. may be called immediately if already at top

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

- (void)toggleButtonImage:(NSTimer*)timer {
    
    if(toggle) {
        participateTitleLbl.textColor = [UIColor yellowColor];
    } else {
        participateTitleLbl.textColor = [UIColor whiteColor];
    }
    
    toggle = !toggle;
}

- (void)fbParticipationBtnHandler {
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *sharingComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else {
                NSLog(@"Posting to facebook.");
                
                //Update participation percentage
                [self updateParticipationPercentage];
                
                //request update user participation
                NSLog(@"The result %d", result);
                GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
                NSString *urlString = [NSString stringWithFormat:@"%@addUserParticipation/%@/%@", GOOSIIAPI, [plist objectForKey:@"userId"], self.company.companyId];
                
                NSLog(@"getUserContests %@", urlString);
                NSURL *url = [NSURL URLWithString:urlString];
                
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                
                [NSURLConnection sendAsynchronousRequest:urlRequest
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           
                                           // your data or an error will be ready here
                                           NSString* newStr = [[NSString alloc] initWithData:data
                                                                                    encoding:NSUTF8StringEncoding];
                                           
                                           NSLog(@"ReceivedData %@", newStr);
                                           
                                       }];
                
            }
            
            [sharingComposer dismissViewControllerAnimated:YES completion:nil];
        };
        [sharingComposer setCompletionHandler:completionHandler];
        [sharingComposer setInitialText:[NSString stringWithFormat:@"%@ %@",[self editableText],[self permanentText]]];
        
        [sharingComposer addURL:[NSURL URLWithString:self.company.website]];
        
        [self presentViewController:sharingComposer animated:YES completion:^{
            for (UIView *viewLayer1 in [[sharingComposer view] subviews]) {
                for (UIView *viewLayer2 in [viewLayer1 subviews]) {
                    if ([viewLayer2 isKindOfClass:[UIView class]]) {
                        for (UIView *viewLayer3 in [viewLayer2 subviews]) {
                            if ([viewLayer3 isKindOfClass:[UITextView class]]) {
                                [(UITextView *)viewLayer3 setDelegate:self];
                                sharingTextView = (UITextView *)viewLayer3;
                            }
                        }
                    }
                }
            }
        }];
    }
}

- (void)twitterParticipationBtnHandler {
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *sharingComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else {
                NSLog(@"Posting to twitter.");
                
                //Update participation percentage
                [self updateParticipationPercentage];
                
                //request update user participation
                NSLog(@"The result %d", result);
                GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
                NSString *urlString = [NSString stringWithFormat:@"%@addUserParticipation/%@/%@", GOOSIIAPI, [plist objectForKey:@"userId"], self.company.companyId];
                
                NSLog(@"getUserContests %@", urlString);
                NSURL *url = [NSURL URLWithString:urlString];
                
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                
                [NSURLConnection sendAsynchronousRequest:urlRequest
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           
                                           // your data or an error will be ready here
                                           NSString* newStr = [[NSString alloc] initWithData:data
                                                                                    encoding:NSUTF8StringEncoding];
                                           
                                           NSLog(@"ReceivedData %@", newStr);
                                           
                                       }];
                
            }
            
            [sharingComposer dismissViewControllerAnimated:YES completion:nil];
        };
        [sharingComposer setCompletionHandler:completionHandler];
        [sharingComposer setInitialText:[NSString stringWithFormat:@"%@ %@",[self editableText],[self permanentText]]];
        
        [sharingComposer addURL:[NSURL URLWithString:self.company.website]];
        
        [self presentViewController:sharingComposer animated:YES completion:^{
            for (UIView *viewLayer1 in [[sharingComposer view] subviews]) {
                for (UIView *viewLayer2 in [viewLayer1 subviews]) {
                    if ([viewLayer2 isKindOfClass:[UIView class]]) {
                        for (UIView *viewLayer3 in [viewLayer2 subviews]) {
                            if ([viewLayer3 isKindOfClass:[UITextView class]]) {
                                [(UITextView *)viewLayer3 setDelegate:self];
                                sharingTextView = (UITextView *)viewLayer3;
                            }
                        }
                    }
                }
            }
        }];
    }
}


- (NSString *)editableText {
    return self.company.participationPost; //This is the text the user will be able to edit
}

- (NSString *)permanentText {
    return @""; //The user will not be able to modify this text.
}

- (void) updateParticipationPercentage {
    NSLog(@"updateParticipationPercentage");
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    double startDate = floor([self.company.startDate doubleValue]);
    double endDate = floor([self.company.endDate doubleValue]);
    startDate = startDate / 1000;
    endDate = endDate / 1000;
    
    double curTime = floor(timeInMiliseconds);
    double totalDuration = endDate - startDate;
    double elapsedTime = curTime - startDate;
    
    float partPercentage = 0;
    
    float ttlParticipationCount = [self.company.participationPoints floatValue] + 1;
    self.company.participationPoints = [NSString stringWithFormat:@"%f", ttlParticipationCount];
    
    NSLog(@" ======== > Checking Total Participation Count %f", ttlParticipationCount);
    
    if(totalDuration != 0.0) {
        partPercentage = elapsedTime / 86400;
        
        if(elapsedTime < 86400) {
            partPercentage = 1;
        }
        partPercentage = floor(partPercentage);
        partPercentage =  ttlParticipationCount / partPercentage;
        
        if(partPercentage > 1) {
            partPercentage = 1;
        }
    }
    
    self.company.participationPercentage = [NSString stringWithFormat:@"%f", partPercentage];
    float participationNum = [self.company.participationPercentage floatValue] * 100;
    self.participationLbl.text = [NSString stringWithFormat:@"%i%% Participation", (int) participationNum];
    
    float partWidth = [self.company.participationPercentage floatValue] * 280.0;
    NSLog(@"The percentage %f and cell width %f", [self.company.participationPercentage floatValue], 300.0f);
    NSLog(@"The calculation %f", partWidth);
    
    NSLog(@"The participation bar %f, %f, %f, %f", self.participationBar.layer.frame.origin.x, self.participationBar.layer.frame.origin.y, self.participationBar.layer.frame.size.width, self.participationBar.layer.frame.size.height);
    
    CGRect newRect = CGRectMake(self.participationBar.frame.origin.x, self.participationBar.frame.origin.y, partWidth, 50.0);
    [self.participationBar removeFromSuperview];
    
    self.participationBar = [[GIProgressBar alloc] initWithFrame:newRect];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //TODO How do reload the participation progress bar~
        //        [self.tableView reloadData];
        //Animate the progress bars to juic-ify this app!
        [UIView animateWithDuration:1 animations:^{
            
            float partWidth = [self.company.participationPercentage floatValue] * 320;
            NSLog(@"The calculation %f", partWidth);
            self.participationBar.layer.frame = CGRectMake(0 + 10, 30, partWidth, 50);
            
//            [self.eventScrollView setNeedsDisplay];
            
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
    });
}

- (void)showNoEventsPopUp:(NSString*)newsURL{
    NSLog(@"THE NEWSURL %@", newsURL);
    
    isEvent = 0;

    self.webView =[[UIWebView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    
    webView.scalesPageToFit = YES;
    
    NSString *urlAddress = self.company.newsURLString;
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    //URL Requst Object
    //        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    
    webView.scrollView.scrollEnabled = TRUE;
    webView.scalesPageToFit = TRUE;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [webView setCenter:CGPointMake(webView.center.x, (webView.center.y - 20.0))];
    }
    
    [self.view addSubview:webView];
    [self.view bringSubviewToFront:webView];
}
@end
