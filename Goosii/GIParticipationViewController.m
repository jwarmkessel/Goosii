//
//  GIParticipationViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIParticipationViewController.h"
#import <ECSlidingViewController.h>
#import "GIMenuViewController.h"
#import <SBJson.h>
#import "GICompany.h"
#import "GIPlist.h"
#import "GIEventBoardViewController.h"
#import "GIFulfillmentViewController.h"
#import "GIRewardStateViewController.h"
#import <ECSlidingViewController.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Reachability.h>
#import "GICompanyFactory.h"

@interface GIParticipationViewController ()
@property (nonatomic, strong) GICompany *selCompany;
@property (strong, nonatomic) UIView *loadingMask;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) Reachability *reach;
@property (nonatomic, strong) UIImageView *noInternetConexionView;
@property (assign) BOOL isInternetActive;

- (void)makeContestRequest;
- (BOOL)determineFulfillment: (NSString*)companyId;

@end

@implementation GIParticipationViewController
@synthesize eventList, loadingMask, indicator, noInternetConexionView, isInternetActive;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    //Configure Navigation Bar
    self.navigationController.navigationItem.title = @"Event Activity";

    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setAlpha:0.9];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView setContentInset:UIEdgeInsetsMake(-20,0,0,0)];
        self.navigationController.navigationBar.tintColor = [self colorWithHexString:@"C63D0F"];
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        self.wantsFullScreenLayout = YES;
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
        
    } else {
        self.navigationController.navigationBar.barTintColor = [self colorWithHexString:@"C63D0F"];
        
    }
    
    if(![self.slidingViewController.underLeftViewController isKindOfClass:[GIMenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    //    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    //Initialize the dataSource
    self.eventList = [[NSMutableArray alloc] init];
    
    //Add the back button to cancel and add an event handler
    
    UIImage *image = [UIImage imageNamed:@"Slide.png"];
    UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(myAboutButtonClicked:)];

    self.navigationItem.leftBarButtonItem = button2;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    NSLog(@"APPLICATION WILL ENTER FOREGROUND FROM CHECKIN VIEW");

    [self.tableView reloadData];

}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
}

-(IBAction)myAboutButtonClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight animations:^{
        NSLog(@"Sliding");
    } onComplete:^{
        NSLog(@"complete");
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.slidingViewController.panGesture.enabled = YES;
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar setAlpha:1.0f];

    [super viewWillAppear:YES];
    [self.eventList removeAllObjects];

    //Start loading mask.
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.loadingMask.backgroundColor = [UIColor blackColor];
    self.loadingMask.alpha = 0.5;
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;

    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    NSLog(@"Add loading mask and indicator in activity view");
    [self.view addSubview:self.loadingMask];
    [self.view addSubview:indicator];
    
    [indicator startAnimating];
    
    noInternetConexionView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [noInternetConexionView setImage:[UIImage imageNamed:@"NoInternetConexion.png"]];
    noInternetConexionView.alpha = 0;
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:noInternetConexionView];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Allocate a reachability object
    self.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
    self.reach.reachableOnWWAN = YES;
    
    // Here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [self.reach startNotifier];
    
    [self makeContestRequest];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    NSLog(@"Reachability has Changed");
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window bringSubviewToFront:noInternetConexionView];
    
    // called after network status changes
    NetworkStatus internetStatus = [self.reach currentReachabilityStatus];
    
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"CHECKIN VIEW: The internet is down.");
            
            
            noInternetConexionView.alpha = 1;
            
            isInternetActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"CHECKIN VIEW: The internet is working via WIFI.");
            
            if(!isInternetActive) {
                [self makeContestRequest];
                noInternetConexionView.alpha = 0;
            }
            
            isInternetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"CHECKIN VIEW: The internet is working via WWAN.");

            if(!isInternetActive) {
                [self makeContestRequest];
                noInternetConexionView.alpha = 0;
            }
            
            isInternetActive = YES;
            
            break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"Calling Prepare for segue to %@", [segue identifier]);
    
    if ([[segue identifier] isEqualToString:@"rewardStateViewSegue"]) {
        NSLog(@"preparing to segue to rewardStateViewController");
        // Get reference to the destination view controller
        GIRewardStateViewController *vc = [segue destinationViewController];
        [vc setCompany:(GICompany*)[self.eventList objectAtIndex:[self.tableView indexPathForSelectedRow].row]];

    } else if([[segue identifier] isEqualToString:@"fulfillmentViewSegue"]) {
        GIFulfillmentViewController *vc = [segue destinationViewController];
        [vc setCompany:(GICompany*)[self.eventList objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        
    } else if([[segue identifier] isEqualToString:@"eventDrillDownViewSegue"]) {
        GIEventBoardViewController *vc = [segue destinationViewController];
        vc.company = [self.eventList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        NSTimeInterval timeInMilliseconds = [[NSDate date] timeIntervalSince1970];
        
        NSLog(@"The time in Milliseconds %f", timeInMilliseconds);
        
        GICompany *selectedCompany = (GICompany*)[self.eventList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        //TODO CHANGE THIS BACK TO <=
        if(([selectedCompany.endDate floatValue] / 1000) < timeInMilliseconds ||  timeInMilliseconds < ([selectedCompany.startDate floatValue] / 1000)) {
            NSLog(@"Currently no events");
            [vc showNoEventsPopUp:selectedCompany.newsURLString];
        }
    }
 
}

- (void)makeContestRequest {
    [self.eventList removeAllObjects];
    
    NSString *urlString = [NSString stringWithFormat:@"%@getUserContests/%@", GOOSIIAPI, [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]];
    NSLog(@"getUserContests %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    NSURLResponse* response = nil;
    NSError *error = nil;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

    if(!error) {        
        // your data or an error will be ready here
        NSString* responseDocumentString = [[NSString alloc] initWithData:data
                                                                 encoding:NSUTF8StringEncoding];
        
        GICompanyFactory *compFactory = [[GICompanyFactory alloc] initWithDocument:responseDocumentString];
        self.eventList = compFactory.companies;
       
        [self.tableView reloadData];

    } else {
       NSLog(@"Server Maintenance Under way.");
       CGRect rect = CGRectMake(0.0, 0.0, 320.0, 50.0);
       UIView *errorView = [[UIView alloc] initWithFrame:rect];
       [errorView setBackgroundColor:[self colorWithHexString:@"EED202"]];
       UILabel *errorStatusLbl = [[UILabel alloc] initWithFrame:rect];
       [errorStatusLbl setBackgroundColor:[self colorWithHexString:@"EED202"]];
       
       [errorStatusLbl setText:@"Oops, something went wrong. Check back in a few minutes"];
       
       errorStatusLbl.numberOfLines = 0;
       [errorStatusLbl sizeToFit];
       
       [errorStatusLbl setTextAlignment:NSTextAlignmentCenter];
       [self.tableView addSubview:errorView];
       [errorView addSubview:errorStatusLbl];
       [errorStatusLbl setCenter:errorView.center];
   }
    
    NSLog(@"Remove the loading mask in activities view");
    [self.loadingMask removeFromSuperview];
    [indicator stopAnimating];
}

- (BOOL)determineFulfillment: (NSString*)companyId {
    NSString *urlString = [NSString stringWithFormat:@"%@getUserFulfillments/%@/%@", GOOSIIAPI, [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"], companyId];
    
    NSLog(@"getUserContests %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&requestError];

    NSString* newStr = [[NSString alloc] initWithData:response
                                             encoding:NSUTF8StringEncoding];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *fulfillment = [parser objectWithString:newStr];

    if ([fulfillment objectForKey:@"companyId"] == nil) {
        NSLog(@"Response was nil %@", newStr);
        if (requestError != nil) {
            NSLog(@"huh");
        }
        
        return NO;
    }
    else {
        NSLog(@"ReceivedData %@", newStr);

        return YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.eventList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    GICompany *company = [self.eventList objectAtIndex:indexPath.row];
    
    NSString *urlRewardString = [NSString stringWithFormat:@"%@/companyAssets/%@/rewardImageThumb.png", kBASE_URL, company.companyId];
    
    [[SDImageCache sharedImageCache] removeImageForKey:urlRewardString fromDisk:YES];
    
    NSLog(@"%@", urlRewardString);
    [cell.imageView setImageWithURL:[NSURL URLWithString:urlRewardString]
                   placeholderImage:[UIImage imageNamed:@"imagePlaceHolder.png"]];
    [cell.textLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0f]];
    cell.textLabel.text = company.name;
    [cell.textLabel setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    
    NSLog(@"Make it red");
            [cell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    if([company.fulfillment isEqualToString:@"YES"]) {
        
        [cell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            UIView *cellBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            [cellBackgroundView setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
            [cell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
            [cell setBackgroundView:cellBackgroundView];
            cell.contentView.backgroundColor = [self colorWithHexString:@"C63D0F"];
            
            [cell setBackgroundColor:[UIColor clearColor]];
        }
    } else {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    return cell;
}

//Change the Height of the Cell [Default is 44]:
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"===============================>heightForRowAtIndexPath");
//    if (indexPath.section == 0) {
//        if (indexPath.row == 1) {
//            return 90;
//        }
//    }
    return 100;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GICompany *selectedCompany = [self.eventList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    
    NSString *segueName;
    
    if([selectedCompany.fulfillment isEqualToString:@"YES"]) {
        segueName = @"fulfillmentViewSegue";
    } else if([selectedCompany.reward isEqualToString:@"YES"]) {
        segueName = @"rewardStateViewSegue";
    } else {
        segueName = @"eventDrillDownViewSegue";
    }
    
    //TODO CHANGE THIS BY REMOVING IT!!!!!!!!!!!
    //segueName = @"eventDrillDownViewSegue";
    NSLog(@"Segue path is %@", segueName);
    
    [self performSegueWithIdentifier:segueName sender:self];
}

- (void)viewDidUnload {
    [self setEventList:nil];
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
