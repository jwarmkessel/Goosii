//
//  GIEventBoardViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/12/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIEventBoardViewController.h"
#import "GIProgressBar.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "GICountingLabel.h"
#import "GICompany.h"
#import "GIPlist.h"
#import "GICheckinViewController.h"
#import <MapKit/MapKit.h>
#import <ECSlidingViewController.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "GIRewardEmployeeController.h"

@interface GIEventBoardViewController ()
{
    UITextView *sharingTextView;
}
@property (nonatomic, strong) UIView *loadingMask;
@property (nonatomic, strong) UIView *enteredPopUpView;

@property (nonatomic, strong) UILabel *participationLbl;
@property (nonatomic, strong) GIProgressBar *timeDurationBar;

@property (nonatomic, strong) UITableViewCell *moreInfoTblViewcell;
@property (nonatomic, strong) UITableViewCell *currentSelectedCell;
@property (nonatomic, strong) UIButton *participationBtn;

@property (nonatomic, strong) UIView *noEventsPopUpView;
@property (nonatomic, strong) UIView *companyInfoContainerView;

@property (nonatomic, strong) UIBarButtonItem *backButton;

@property (nonatomic, strong) UIImageView *prizeImg;
@property (nonatomic, strong) UIButton* infoBtn;

@property (nonatomic, strong) GIRewardEmployeeController *rewardEmployeeView;
@end

@implementation GIEventBoardViewController
@synthesize company, noEventsPopUpView, mapView, companyInfoContainerView, backButton, participationLbl, prizeImg, toggle, blinkTimer, fbPartLbl, participationBar, infoBtn, rewardEmployeeView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Enter the user into the contest if they haven't already.
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    NSString *enterEventUrlString = [NSString stringWithFormat:@"%@enterContest/%@/%@", GOOSIIAPI,[plist objectForKey:@"userId"], self.company.companyId];
    
    NSURL *enterEventURL = [NSURL URLWithString:enterEventUrlString];
    NSURLRequest *enterEventRequest = [NSURLRequest requestWithURL:enterEventURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [NSURLConnection sendAsynchronousRequest:enterEventRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               // your data or an error will be ready here
                               NSString* newStr = [[NSString alloc] initWithData:data
                                                                        encoding:NSUTF8StringEncoding];
                               NSLog(@"response: %@", newStr);
                               
                               //If this is the first time checking in.
                               if([newStr isEqualToString:@"YES"]) {
                                   
                                   rewardEmployeeView = [[GIRewardEmployeeController alloc] initWithNibName:@"GIRewardEmployeeController" bundle:nil];
                                   [self addChildViewController:rewardEmployeeView];
                                   [self.tableView addSubview:rewardEmployeeView.view];

                                   UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(refreshPropertyList:)];
                                   self.navigationItem.rightBarButtonItem = anotherButton;
                               }
                           }];
    
    // do something only for logged in fb users} else {//do something else for non-fb users}
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        NSLog(@"I'm totally logged in");
    }else {
        NSLog(@"I'm totally NOT logged in");
    }

    //Make the call to action text animate with blinking.
    blinkTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(toggleButtonImage:) userInfo:nil repeats: YES];

    //Load the background image and reward image asynchronously. For now I'm removing the cached image until I have time to set Http Headers to handle caching.
    [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@/companyAssets/%@/rewardImageThumb.png", kBASE_URL, company.companyId] fromDisk:YES];

    UIImageView *imgView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/companyAssets/%@/backgroundImage.jpg", kBASE_URL, company.companyId];

    [imgView setImageWithURL:[NSURL URLWithString:urlString]
                   placeholderImage:[UIImage imageNamed:@"backgroundImage.jpg"]];

    NSString *urlRewardString = [NSString stringWithFormat:@"%@/companyAssets/%@/rewardImage.jpg", kBASE_URL, company.companyId];
    
    [self.prizeImg setImageWithURL:[NSURL URLWithString:urlRewardString]
            placeholderImage:[UIImage imageNamed:@"imagePlaceHolder.png"]];

    [self.tableView setBackgroundView:imgView];
    
    //Override the back button.
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"back"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(handleBack:)];

    self.navigationItem.leftBarButtonItem = backButton;

    //Set the color of the NavBar
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.tintColor = [self colorWithHexString:@"C63D0F"];

        #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        self.wantsFullScreenLayout = YES;
        #pragma GCC diagnostic warning "-Wdeprecated-declarations"
    } else {
        self.navigationController.navigationBar.barTintColor = [self colorWithHexString:@"C63D0F"];
        
    }
    
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setAlpha:0.9];
    
    //Set mapview delegate
    [self.mapView setDelegate:self];
}

-(void)refreshPropertyList:(id)sender {
    NSLog(@"removing from parent view controller");
    [rewardEmployeeView.view removeFromSuperview];
    [rewardEmployeeView removeFromParentViewController];
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)toggleButtonImage:(NSTimer*)timer {
    
    if(toggle) {
        fbPartLbl.textColor = [UIColor yellowColor];
    } else {
        fbPartLbl.textColor = [UIColor whiteColor];
    }

    toggle = !toggle;
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    NSLog(@"Mapview did started loading");    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    NSLog(@"Mapview did finish loading");
}

- (void)showCompanyInfo {
    infoBtn.enabled = NO;
    self.backButton.enabled = NO;
    //Get the window object.
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    float xPos = [[UIScreen mainScreen] bounds].size.width;
    [self.tableView setAlpha:0.5];
    xPos = xPos/2 - 125.0f;
    float yPos = 75.0f;
    float xWidth = 250;
    float yHeightMargin = 100.0f;
    float yHeight = [[UIScreen mainScreen] bounds].size.height - yHeightMargin;
    
    float layerCornerRadius = 5.0f;
    
    //Create the foundation layer for the company info screen.
    CGRect companyInfoContainerViewRect = CGRectMake(xPos, yPos, xWidth, yHeight);
    self.companyInfoContainerView = [[UIView alloc] initWithFrame:companyInfoContainerViewRect];
    
    //Add the foundation layer to the window.
    [window addSubview:self.companyInfoContainerView];
    
    //Initialize the mapview and add it to the foundation layer.
    CGRect noEventsPopUpRect = CGRectMake(0.0f, 0.0f, xWidth, yHeight);
    self.mapView = [[MKMapView alloc] initWithFrame:noEventsPopUpRect];
    [self.companyInfoContainerView addSubview:self.mapView];
    [self.mapView.layer setCornerRadius:layerCornerRadius];
    [self.mapView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.mapView.layer setShadowOpacity:0.8];
    [self.mapView.layer setShadowRadius:3.0];
    [self.mapView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    //MapView configurations
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = [self.company.latitude doubleValue];
    newRegion.center.longitude = [self.company.longitude doubleValue];
    newRegion.span.latitudeDelta = 1.0;
    newRegion.span.longitudeDelta = 8.0;
    [self.mapView setRegion:newRegion animated:YES];

    CGRect mapViewTintedLayerRect = CGRectMake(0.0f, 0.0f, xWidth, yHeight);
    UIView *mapViewTintedLayer = [[UIView alloc] initWithFrame:mapViewTintedLayerRect];
    [self.companyInfoContainerView addSubview:mapViewTintedLayer];

    [mapViewTintedLayer setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    [mapViewTintedLayer setAlpha:0.6];
    [mapViewTintedLayer.layer setBorderColor:[self colorWithHexString:@"C63D0F"].CGColor];
    [mapViewTintedLayer.layer setBorderWidth:1.5f];
    [mapViewTintedLayer.layer setCornerRadius:layerCornerRadius];
    
    UITextView *companyNameLbl = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, xWidth,44.0f)];
    companyNameLbl.text = self.company.name;
    [companyNameLbl setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    companyNameLbl.textAlignment = NSTextAlignmentCenter;;
    [companyNameLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    companyNameLbl.textColor = [UIColor whiteColor];
    companyNameLbl.editable = NO;
    
    UITextView *addressLbl = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, xWidth,150.0f)];
    addressLbl.text = self.company.address;
    addressLbl.textAlignment = NSTextAlignmentCenter;;
    [addressLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    addressLbl.textColor = [UIColor whiteColor];
    addressLbl.backgroundColor = [UIColor clearColor];
    addressLbl.editable = NO;
    
    UIButton *telephoneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 105.0, xWidth, 44.0f)];
    [telephoneBtn setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    [telephoneBtn setTitle:[NSString stringWithFormat:@"%@", self.company.telephone] forState:UIControlStateNormal];
    [telephoneBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    [telephoneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [telephoneBtn addTarget:self
                     action:@selector(telephoneBtnHandler:)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *companyInfoPrizeImage = [[UIImageView alloc] initWithFrame:CGRectMake(((xWidth/2)-50), 155.0f, 100.0,100.0f)];
    companyInfoPrizeImage.image = self.prizeImg.image;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;

    CGRect prizeLblRect = CGRectMake(0.0f, 250.0f, xWidth,200.0f);
    if(screenHeight < 568) {
        prizeLblRect = CGRectMake(0.0f, 175.0f, xWidth,200.0f);
    }
    
    UITextView *prizeLbl = [[UITextView alloc] initWithFrame:prizeLblRect];
    prizeLbl.text = [NSString stringWithFormat:@"Reward: %@", self.company.prize];
    prizeLbl.textAlignment = NSTextAlignmentCenter;;
    [prizeLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    prizeLbl.textColor = [UIColor blackColor];
    prizeLbl.backgroundColor = [UIColor clearColor];
    prizeLbl.editable = NO;
    
    
    CGRect closeCompanyInfoViewBtnRect = CGRectMake(10, 400.0, 230.0, 45.0);
    if(screenHeight < 568) {
        closeCompanyInfoViewBtnRect = CGRectMake(10, 300.0, 230.0, 45.0);
    }
    UIButton *closeCompanyInfoViewBtn = [[UIButton alloc] initWithFrame:closeCompanyInfoViewBtnRect];
    [closeCompanyInfoViewBtn setBackgroundColor:[self colorWithHexString:@"3b5999"]];

    [closeCompanyInfoViewBtn.layer setCornerRadius:3];
    [closeCompanyInfoViewBtn setTitle:@"Done" forState:UIControlStateNormal];
    [closeCompanyInfoViewBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
    [closeCompanyInfoViewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeCompanyInfoViewBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [closeCompanyInfoViewBtn.layer setShadowColor:[UIColor blackColor].CGColor];
    [closeCompanyInfoViewBtn.layer setShadowOpacity:0.8];
    [closeCompanyInfoViewBtn.layer setShadowRadius:3.0];
    
    [closeCompanyInfoViewBtn addTarget:self
                                action:@selector(closeCompanyInfoView:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [self.companyInfoContainerView addSubview:companyNameLbl];
    [self.companyInfoContainerView addSubview:addressLbl];
    [self.companyInfoContainerView addSubview:telephoneBtn];
    [self.companyInfoContainerView addSubview:prizeLbl];
    [self.companyInfoContainerView addSubview:companyInfoPrizeImage];
    [self.companyInfoContainerView addSubview:closeCompanyInfoViewBtn];
    [self.companyInfoContainerView setAlpha:0];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.companyInfoContainerView setAlpha:1];
        
    } completion:^(BOOL finished) {
        NSLog(@"finished");
    }];
    
    [UIView animateWithDuration:2.0 animations:^{
        MKCoordinateRegion newRegion;
        
        newRegion.center.latitude = [self.company.latitude doubleValue];
        newRegion.center.longitude = [self.company.longitude doubleValue];
        
        newRegion.span.latitudeDelta = 0.05;
        newRegion.span.longitudeDelta = 0.05;
        [self.mapView setRegion:newRegion animated:YES];
    } completion:^(BOOL finished) {
        NSLog(@"Done");
    }];
}

- (IBAction)telephoneBtnHandler:sender {
    NSLog(@"telephoneBtnHandler");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.company.telephone]]];
}

- (void)closeCompanyInfoView:(id)sender {
    infoBtn.enabled = YES;
    
    [UIView animateWithDuration:0.8 animations:^{
        self.companyInfoContainerView.frame = CGRectMake(self.companyInfoContainerView.frame.origin.x, -500, self.companyInfoContainerView.frame.size.width, self.companyInfoContainerView.frame.size.height);
        
        [self.companyInfoContainerView setAlpha:0];
        
    } completion:^(BOOL finished) {
        [self.companyInfoContainerView removeFromSuperview];
    }];
    
    self.backButton.enabled = YES;
    [self.tableView setAlpha:1];
}

- (void)showNoEventsPopUp:(NSString*)newsURL{
    NSLog(@"THE NEWSURL %@", newsURL);
    if( [newsURL length] != 0 ) {
        UIWebView *webView =[[UIWebView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
        
        webView.scalesPageToFit = YES;
        
        NSString *urlAddress = self.company.newsURLString;
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlAddress];
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        //Load the request in the UIWebView.
        [webView loadRequest:requestObj];
        
        [self.view addSubview:webView];
    } else {
        float xPos = [[UIScreen mainScreen] bounds].size.width;
        //UIView *noEventsPopUpMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

        [self.tableView setAlpha:0.5];
        xPos = xPos/2 - 100.0f;
        float yPos = 75.0f;



        CGRect noEventsPopUpRect = CGRectMake(xPos, yPos, 200.0f, 200.0f);
        self.noEventsPopUpView = [[UIView alloc] initWithFrame:noEventsPopUpRect];
        self.noEventsPopUpView.layer.borderColor = [UIColor blackColor].CGColor;
        self.noEventsPopUpView.layer.borderWidth = 3.0f;

        NSString *infoString = @"Sorry, no events.";

        UILabel *noEventLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 190.0f,50)];
        noEventLbl.text = infoString;
        noEventLbl.textAlignment = NSTextAlignmentCenter;
        [noEventLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f]];
        noEventLbl.textColor = [UIColor whiteColor];
        noEventLbl.backgroundColor = [UIColor clearColor];


        // border radius
        [self.noEventsPopUpView.layer setCornerRadius:30.0f];

        // border
        //[self.noEventsPopUpView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.noEventsPopUpView.layer setBorderWidth:1.5f];

        // drop shadow
        [self.noEventsPopUpView.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.noEventsPopUpView.layer setShadowOpacity:0.8];
        [self.noEventsPopUpView.layer setShadowRadius:3.0];
        [self.noEventsPopUpView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];

        [self.noEventsPopUpView setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self.noEventsPopUpView];

        [self.noEventsPopUpView addSubview:noEventLbl];

        [self.noEventsPopUpView setAlpha:0.3];

        [UIView
         animateWithDuration:0.2
         animations:^ {
             [self.noEventsPopUpView setAlpha:1];
             CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
             rotationAndPerspectiveTransform.m34 = 1.0 / -500;
             rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -45.0 * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
             noEventLbl.layer.transform = rotationAndPerspectiveTransform;
             

         }
         completion:^(BOOL finished) {
             
             [UIView
              animateWithDuration:0.1
              animations:^ {
                  CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                  rotationAndPerspectiveTransform.m34 = 1.0 / -500;
                  rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
                  noEventLbl.layer.transform = rotationAndPerspectiveTransform;

              }
              completion:^(BOOL finished) {
              }];
         }];
    }
    isEvent = NO;
}

- (void) handleBack:(id)sender {
    // pop to root view controller
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    NSLog(@"Nav controller array %lu", (unsigned long)[[self.navigationController viewControllers] count]);
    int parentViewControllerIndex = [viewControllerArray count] - 2;

    if([[self.navigationController.viewControllers objectAtIndex:(parentViewControllerIndex)] isKindOfClass:[GICheckinViewController class]]) {
        
        if(!isEvent) {
            [UIView
             animateWithDuration:0.1
             animations:^ {
                 [self.noEventsPopUpView setAlpha:0];
             }
             completion:^(BOOL finished) {
                 [self.noEventsPopUpView removeFromSuperview]; 
             }];

            
        }
        GICheckinViewController *checkinViewController = [self.navigationController.viewControllers objectAtIndex:(parentViewControllerIndex)];
        
        [checkinViewController setInset];
        [checkinViewController.locationManager startUpdatingLocation];

        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if(!isEvent) {
            [UIView
             animateWithDuration:0.1
             animations:^ {
                 [self.noEventsPopUpView setAlpha:0];
             }
             completion:^(BOOL finished) {
                 [self.noEventsPopUpView removeFromSuperview];
             }];
            
            
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.slidingViewController.panGesture.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger companyNameCellIndex = 1;
    NSInteger totalParticipantsCellIndex = 3;
    NSInteger progressBarCellIndex = 5;
    NSInteger engagementCellIndex = 7;
    NSInteger participationButtonIndex = 9;

    //The current index
    NSInteger curCellIndex = [indexPath row];
    
    if(companyNameCellIndex == curCellIndex) {
        //Create a transparent layer on top of the cell as a background to the elements on top of it.
        //This is required because otherwise the alpha set on this element affects its child elements.
        UILabel *companyNameLbl = [[UILabel alloc] initWithFrame:CGRectMake((cell.layer.frame.size.width/2-160), (cell.layer.frame.size.height/2-25), 320.0, 50.0)];
        
        NSLog(@"---------------------blah blah-cell width %f", cell.layer.frame.size.width);
        
        companyNameLbl.text = self.company.name;
        [companyNameLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0]];
        companyNameLbl.textColor = [UIColor whiteColor];
        companyNameLbl.backgroundColor = [UIColor clearColor];
        companyNameLbl.textAlignment = NSTextAlignmentCenter;
        
        UIView *transparentCompanyNameCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [transparentCompanyNameCell setAlpha:1];
        [transparentCompanyNameCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        transparentCompanyNameCell.layer.shadowColor = [UIColor blackColor].CGColor;
        transparentCompanyNameCell.layer.shadowOpacity = 0.5;
        transparentCompanyNameCell.layer.shadowRadius = 3;
        transparentCompanyNameCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
        transparentCompanyNameCell.layer.cornerRadius = 4;
        
        CGRect infoRect = CGRectMake((cell.layer.frame.size.width-50), (cell.layer.frame.size.height/2-15), 31, 30.0);;
        infoBtn = [[UIButton alloc] initWithFrame:infoRect];
        UIImage *infoBtnImage = [UIImage imageNamed:@"Info_Button.png"];
        [infoBtn setBackgroundImage:infoBtnImage forState:UIControlStateNormal];
        
        [infoBtn addTarget:self
                 action:@selector(showCompanyInfo)
                  forControlEvents:UIControlEventTouchDown];
  
        self.moreInfoTblViewcell = cell;
        [cell addSubview:transparentCompanyNameCell];
        [cell addSubview:companyNameLbl];
        [cell addSubview:infoBtn];
                
    }else if(totalParticipantsCellIndex == curCellIndex){        
        //Create a transparent layer on top of the cell as a background to the elements on top of it.
        //This is required because otherwise the alpha set on this element affects its child elements.
        UIView *transparentTotalParticipantCell = [[UIView alloc] initWithFrame:CGRectMake((cell.layer.frame.size.width/2-80), 0, cell.frame.size.width/2, cell.frame.size.height)];
        [transparentTotalParticipantCell setAlpha:0.6];
        [transparentTotalParticipantCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        transparentTotalParticipantCell.layer.shadowColor = [UIColor blackColor].CGColor;
        transparentTotalParticipantCell.layer.shadowOpacity = 0.5;
        transparentTotalParticipantCell.layer.shadowRadius = 3;
        transparentTotalParticipantCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
        transparentTotalParticipantCell.layer.cornerRadius = 2;
        
        //Create an animated counter to display the number of participants.        
        GICountingLabel *totalParticipantsLbl = [[GICountingLabel alloc] initWithFrame:CGRectMake((cell.frame.size.width/2 - 80.0), -10, 150, 100)];
        totalParticipantsLbl.format = @"%d";
        totalParticipantsLbl.method = UILabelCountingMethodLinear;
        [totalParticipantsLbl countFrom:0 to:[self.company.totalParticipants floatValue] withDuration:3.0f];
        [totalParticipantsLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:60.0]];
        totalParticipantsLbl.textColor = [UIColor whiteColor];
        totalParticipantsLbl.backgroundColor = [UIColor clearColor];
        totalParticipantsLbl.textAlignment = NSTextAlignmentCenter;
        
        UILabel *ttlPartLbl = [[UILabel alloc] initWithFrame:CGRectMake(cell.layer.frame.size.width/2-160, transparentTotalParticipantCell.layer.frame.size.height - 35, 320.0, 50.0)];
        ttlPartLbl.text = @"Participating";
        [ttlPartLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]];
        ttlPartLbl.textColor = [UIColor whiteColor];
        ttlPartLbl.backgroundColor = [UIColor clearColor];
        ttlPartLbl.textAlignment = NSTextAlignmentCenter;
        
        
        //Add the elements to the cell.
        [cell addSubview:transparentTotalParticipantCell];
        [cell addSubview:totalParticipantsLbl];
        [cell addSubview:ttlPartLbl];
        
    } else if(progressBarCellIndex == curCellIndex) {

        //Create a transparent layer on top of the cell as a background to the elements on top of it.
        //This is required because otherwise the alpha set on this element affects its child elements.
        UIView *cellTransparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [cellTransparentView setAlpha:0.6];
        [cellTransparentView setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        cellTransparentView.layer.shadowColor = [UIColor blackColor].CGColor;
        cellTransparentView.layer.shadowOpacity = 0.5;
        cellTransparentView.layer.shadowRadius = 3;
        cellTransparentView.layer.shadowOffset = CGSizeMake(.6f, .6f);
        cellTransparentView.layer.cornerRadius = 4;
        
        float progressBarThickness = 20.0f;
        
        //Convert milliseconds to seconds.
        NSTimeInterval seconds = [self.company.endDate floatValue];
        seconds = seconds / 1000;
        
        //Initiate the date object and formatter and set the participation string.
        NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm";
        NSString *timeStamp = [dateFormatter stringFromDate:epochNSDate];
        NSString *announceDateStr = [NSString stringWithFormat:@"Reward to be announced %@", timeStamp];
        
        UILabel *endDateLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 5.0f, 320.0,15.0)];
        endDateLbl.text = announceDateStr;
        [endDateLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:13.0]];
        endDateLbl.textColor = [UIColor whiteColor];
        endDateLbl.backgroundColor = [UIColor clearColor];
        
        float progressBarWidth = 280.0f;
        float xPos = (cell.frame.size.width/2 - (progressBarWidth/2));
        
        CGRect timeDurationBarRect = CGRectMake(xPos, 20.0f, 0.0f, progressBarThickness);
        
        //Set the color of the progress bars.
        CGRect backgroundRect = CGRectMake(xPos, 20.0f, progressBarWidth, progressBarThickness);

        GIProgressBar *backgroundProgressBar = [[GIProgressBar alloc] initWithFrame:backgroundRect hexStringColor:@"FF3100"];
        self.timeDurationBar = [[GIProgressBar alloc] initWithFrame:timeDurationBarRect hexStringColor:@"3EFF29"];

        //Add the child elements to the cell.
        [cell addSubview:cellTransparentView];
        [cell addSubview:backgroundProgressBar];
        [cell addSubview:self.timeDurationBar];
        [cell addSubview:endDateLbl];

        //Animate the progress bars to juic-ify this app!
        [UIView animateWithDuration:1 animations:^{
            
            float percentWidth = [self.company.timePercentage floatValue] * progressBarWidth;
            NSLog(@"The percentage %f and cell width %f", [self.company.timePercentage floatValue], cell.frame.size.width);
            NSLog(@"The caluc %f", percentWidth);
            self.timeDurationBar.frame = CGRectMake(xPos, 20, percentWidth, progressBarThickness);
            
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
    } else if(engagementCellIndex == curCellIndex) {
        //Create a transparent layer on top of the cell as a background to the elements on top of it.
        //This is required because otherwise the alpha set on this element affects its child elements.
        UIView *transparentEngCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [transparentEngCell setAlpha:0.6];
        [transparentEngCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        transparentEngCell.layer.shadowColor = [UIColor blackColor].CGColor;
        transparentEngCell.layer.shadowOpacity = 0.5;
        transparentEngCell.layer.shadowRadius = 3;
        transparentEngCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
        transparentEngCell.layer.cornerRadius = 4;
        
        self.participationLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 320.0f,15.0f)];
        
        float participationNum = [company.participationPercentage floatValue] * 100;
        
        self.participationLbl.text = [NSString stringWithFormat:@"%i%% Participation", (int) participationNum];
        [self.participationLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:13.0f]];
        self.participationLbl.textColor = [UIColor whiteColor];
        self.participationLbl.backgroundColor = [UIColor clearColor];
        
        //Progress bar elements for participation rate and the duration of the contest.
        float progressBarWidth = 280.0f;
        float xPos = (cell.frame.size.width/2 - (progressBarWidth/2));
        float progressBarThickness = 20.0f;
        CGRect participationBarBackgroundRect = CGRectMake(xPos, 20.0f, progressBarWidth, progressBarThickness);
        
        GIProgressBar *participationBarBackground = [[GIProgressBar alloc] initWithFrame:participationBarBackgroundRect hexStringColor:@"FF3100"];
        
        CGRect participationBarRect = CGRectMake(xPos, 20.0f, 1.0f, progressBarThickness);
        self.participationBar = [[GIProgressBar alloc] initWithFrame:participationBarRect hexStringColor:@"3EFF29"];
        
        self.participationBtn = [[UIButton alloc] initWithFrame:CGRectMake(cell.layer.frame.size.width/2 - (200/2), self.participationBar.layer.frame.origin.y + progressBarThickness + 15.0f, 200.0f, 50.0f)];

        [cell addSubview:transparentEngCell];
        [cell addSubview:participationBarBackground];
        [cell addSubview:self.participationBar];
        [cell addSubview:self.participationLbl];
        NSLog(@"CAN YOU BELIEVE %@", self.company.participationPercentage);
        //Animate the progress bars to juic-ify this app!
        [UIView animateWithDuration:1 animations:^{
            
            float partWidth = [self.company.participationPercentage floatValue] * progressBarWidth;
            NSLog(@"The percentage %f and cell width %f", [self.company.participationPercentage floatValue], cell.frame.size.width);
            NSLog(@"The calculation %f", partWidth);
            self.participationBar.frame = CGRectMake(xPos, 20, partWidth, progressBarThickness);
            
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
    } else if(participationButtonIndex == curCellIndex) {
        
        CGRect backgroundImageView = CGRectMake((cell.frame.size.width/2-(cell.frame.size.width/2)), 0.0f, cell.frame.size.width, cell.frame.size.height);

        UIImage *participationBtnImage = [UIImage imageNamed:@"FB_Back.png"];
        UIImage *fbParticipationBtnImage = [UIImage imageNamed:@"FB_Button.png"];
        UIImageView *participationBackgroundImageView = [[UIImageView alloc] initWithFrame:backgroundImageView];
        [participationBackgroundImageView setImage:participationBtnImage];
        
        CGRect fbBackgroundImageView = CGRectMake((cell.frame.size.width/2-44), 50.0f, 95.0, 95.0f);
        
        self.participationBtn = [[UIButton alloc] initWithFrame:fbBackgroundImageView];
        [self.participationBtn setBackgroundImage:fbParticipationBtnImage forState:UIControlStateNormal];
        
        [self.participationBtn addTarget:self
                                  action:@selector(participationBtnHandler)
                        forControlEvents:UIControlEventTouchDown];
        
        self.fbPartLbl = [[UILabel alloc] initWithFrame:CGRectMake((cell.frame.size.width/2-110), 10.0f, 220.0f,30.0f)];
        fbPartLbl.text = @"Post To Increase Participation";
        [fbPartLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0f]];
        fbPartLbl.textColor = [UIColor whiteColor];
        fbPartLbl.backgroundColor = [UIColor clearColor];
        fbPartLbl.textAlignment = NSTextAlignmentCenter;
        
        [cell addSubview:participationBackgroundImageView];
        [cell addSubview:fbPartLbl];
        [cell addSubview:self.participationBtn];
    }
}

- (void)participationBtnHandler {
    
    
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
        
        [sharingComposer addURL:[NSURL URLWithString:company.website]];
        
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

- (void) updateParticipationPercentage {

    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    double startDate = floor([self.company.startDate doubleValue]);
    double endDate = floor([self.company.endDate doubleValue]);
    startDate = startDate / 1000;
    endDate = endDate / 1000;
    NSLog(@"START DATE %f", startDate);
    NSLog(@"END DATE %f", endDate);
    
    
    double curTime = floor(timeInMiliseconds);
    NSLog(@"CURRENT DATE %f", curTime);
    
    double totalDuration = endDate - startDate;
    NSLog(@"TOTAL DURATION IN MIL %f", totalDuration);
    
    double elapsedTime = curTime - startDate;
    //Participation percentage is calculated by number of number of participation counts divided by number of days.
    float partPercentage = 0;
    
    partPercentage = 0;

    float ttlParticipationCount = [self.company.participationPoints floatValue] + 1;

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
    [self.tableView reloadData];
    //Animate the progress bars to juic-ify this app!
    [UIView animateWithDuration:1 animations:^{

        
        participationBar.layer.frame = CGRectMake(10, 20, partWidth, 20);

        
        
    } completion:^(BOOL finished) {
        NSLog(@"done");

        NSLog(@"The participation bar after %f, %f, %f, %f", self.participationBar.layer.frame.origin.x, self.participationBar.layer.frame.origin.y, self.participationBar.layer.frame.size.width, self.participationBar.layer.frame.size.height);

    }];
}

- (NSString *)editableText {
    return self.company.participationPost; //This is the text the user will be able to edit
}

- (NSString *)permanentText {
    return @""; //The user will not be able to modify this text.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
//    if(indexPath.row == 2) {
//        [self moreInfoCellHandler];
//        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
//        self.currentSelectedCell = [self.tableView cellForRowAtIndexPath:path];
//        
//        // This is where magic happens...
//        [self.tableView beginUpdates];
//        [self.tableView endUpdates];
//    }
    
}



- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    return NO;
}


- (void)saveForLaterBtnHandler:sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.tableView.window endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    
    return YES;
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
