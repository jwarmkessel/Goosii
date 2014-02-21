//
//  GICheckinViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GICheckinViewController.h"
#import <SBJson.h>
#import "GICompany.h"
#import "GIEventBoardViewController.h"
#import "GIPlist.h"
#import "GIFulfillmentViewController.h"
#import "GIRewardViewController.h"
#import "GIHomeViewController.h"
#import "GIMainViewController.h"
#import <ECSlidingViewController.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDImageCache.h>
#import "GINoEventsNearby.h"
#import "GIEventScrollViewController.h"
#import "GICompanyCheckinCell.h"
#import <ECSlidingViewController.h>
#import <Reachability.h>
#import "GICompanyFactory.h"

#define METERS_PER_MILE 1609.344
#define METERS_TO_MILE_CONVERSION 0.00062137
#define DISTANCE_ALLOWED_FROM_COMPANY 40.0f

@interface GICheckinViewController () {
    BOOL isFromChild;
}
@property (strong, nonatomic) UIView *loadingMask;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) GINoEventsNearby *noEventsNearbyController;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton *customSlidingMenuButton;
@property (nonatomic, strong) UILabel *slideMenuButtonNotificationLabel;
@property (nonatomic, strong) Reachability *reach;
@property (nonatomic, strong) UIImageView *noInternetConexionView;

@property (assign) BOOL isInternetActive;
@end

@implementation GICheckinViewController
@synthesize loadingMask, nearbyLocationsAry, locationManager, indicator, noEventsNearbyController, mapView, slidingMenuButton, customSlidingMenuButton, slideMenuButtonNotificationLabel, isEventsPageReopenedFromBackground, noInternetConexionView, isInternetActive;



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
    
    isEventsPageReopenedFromBackground = NO;
    
    NSLog(@"Check-in viewDidLoad");
    self.slidingViewController.panGesture.enabled = NO;
    //Set navigation controller variables.
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.autoresizesSubviews = YES;

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView setContentInset:UIEdgeInsetsMake(-20,0,0,0)];
        self.navigationController.navigationBar.tintColor = [self colorWithHexString:@"C63D0F"];
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        self.wantsFullScreenLayout = YES;
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
    } else {
        self.navigationController.navigationBar.barTintColor = [self colorWithHexString:@"C63D0F"];

    }
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [mapView setDelegate:self];
    
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    if(![plist objectForKey:@"locationTrigger"]) {
        [self.tableView addSubview:mapView];
    } else {
        //Start location services.
        NSLog(@"Instantiating self.locationManager");
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = 5;
        [self.locationManager startUpdatingLocation];
    }
    
    self.nearbyLocationsAry = [[NSMutableArray alloc] init];
    
    /********/
     //Initiate ECSlidingMenu Controller and add sliding menu button.
//     self.slidingMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
//     
//     
//     if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//     slidingMenuButton.frame = CGRectMake(8, 10, 38, 24);
//     }else {
//     slidingMenuButton.frame = CGRectMake(8, 30, 38, 24);
//     }
//     
//     [slidingMenuButton setBackgroundImage:[UIImage imageNamed:@"Slide.png"] forState:UIControlStateNormal];
//     [slidingMenuButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
//     
//     [self.view addSubview:self.slidingMenuButton];
    
    /********/
    
    customSlidingMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"Slide.png"];
    [customSlidingMenuButton setImage:image forState:UIControlStateNormal];
    customSlidingMenuButton.frame = CGRectMake(0, 0, 18, 30);
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customSlidingMenuButton];
    

    [customSlidingMenuButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
//    barButtonItem = [[UIBarButtonItem alloc] initWithImage:image
//                                                     style:UIBarButtonItemStyleBordered
//                                                    target:self
//                                                    action:@selector(revealMenu:)];
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem];

//    UIImage *addImage = [UIImage imageNamed:@"images/global/add"];
//    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [addButton setFrame:CGRectMake(0, 0, addImage.size.width, addImage.size.height)];
//    [addButton setBackgroundImage:addImage forState:UIControlStateNormal];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
//    [self.navigationItem setRightBarButtonItem:barButtonItem];
    
    // change the back button to cancel and add an event handler
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"back"
//                                                                   style:UIBarButtonItemStyleBordered
//                                                                  target:self
//                                                                  action:@selector(handleBack:)];
//    self.navigationItem.leftBarButtonItem = backButton;
    
    //Set the color of the NavBar
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setAlpha:0.9];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slidingViewUnderLeftWillAppear:) name:ECSlidingViewUnderLeftWillAppear object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.slideMenuButtonNotificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, -10.0, 30, 30)];
    self.slideMenuButtonNotificationLabel.text = [NSString stringWithFormat:@"0"];
    [self.slideMenuButtonNotificationLabel setBackgroundColor:[self colorWithHexString:@"C63E0F"]];
    self.slideMenuButtonNotificationLabel.font = [UIFont fontWithName:@"Trebuchet" size:5];
    [self.slideMenuButtonNotificationLabel setTextColor:[UIColor whiteColor]];
    self.slideMenuButtonNotificationLabel.textAlignment = NSTextAlignmentCenter;
    [self.slideMenuButtonNotificationLabel setTag:15];
    self.slideMenuButtonNotificationLabel.alpha = 0;
    [self.navigationController.navigationBar addSubview:self.slideMenuButtonNotificationLabel];
    
}

- (void)slidingViewUnderLeftWillAppear:(NSNotification *)notification {
    [self.slideMenuButtonNotificationLabel removeFromSuperview];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    NSLog(@"APPLICATION WILL ENTER FOREGROUND FROM CHECKIN VIEW");
    
    if(!self.loadingMask) {
        [self setLoadingMaskAndIndicator];
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;


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
            
            noInternetConexionView.alpha = 0;

            
            isInternetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"CHECKIN VIEW: The internet is working via WWAN.");
            
            
            noInternetConexionView.alpha = 0;
            
            isInternetActive = YES;
            
            break;
        }
    }
    
    NSLog(@"Instantiating self.locationManager");
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 5;
    [self.locationManager startUpdatingLocation];
}

-(void)revealMenu:(id)sender {

    NSLog(@"Remove the notification from super view");
    
    //NSArray *subViews = [self.navigationController.view subviews];
//    NSArray *subViews = [self.navigationController.navigationBar subviews];
    
//    for( id thing in subViews) {
//        [thing removeFromSuperview];
//    }
    
//    [[subViews firstObject] removeFromSuperview];
//    UILabel *blah = (UILabel*)[self.navigationController.view viewWithTag:15];
//    [blah removeFromSuperview];
    
    [self.slidingViewController anchorTopViewTo:ECRight animations:^{
        NSLog(@"Sliding");
        [self.slideMenuButtonNotificationLabel removeFromSuperview];
    } onComplete:^{
        NSLog(@"Completed");
        [self.slideMenuButtonNotificationLabel removeFromSuperview];
    }];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
}

- (void)setInset {
    NSLog(@"Check-in setInset");
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [self.tableView setContentInset:UIEdgeInsetsMake(-20,0,0,0)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    self.slidingViewController.panGesture.enabled = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Check-in View Will Appear");
    
    [super viewWillAppear:YES];
    
    if(!noInternetConexionView) {
        noInternetConexionView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [noInternetConexionView setImage:[UIImage imageNamed:@"NoInternetConexion.png"]];
        noInternetConexionView.alpha = 0;
        isInternetActive = YES;
        [[[UIApplication sharedApplication] keyWindow] addSubview:noInternetConexionView];
    }

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if(!isEventsPageReopenedFromBackground) {
        NSLog(@"THE LOADING MASK IS BEING LOADED FROM VIEWWILLAPPEAR");
        [self setLoadingMaskAndIndicator];
        isEventsPageReopenedFromBackground = YES;
    }
    
    NSLog(@"Step 1");
    
    // Allocate a reachability object
    self.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    NSLog(@"Step 2");
    // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
    self.reach.reachableOnWWAN = YES;
    NSLog(@"Step 3");
    // Here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    NSLog(@"Step 4");
    [self.reach startNotifier];
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
                [self.locationManager startUpdatingLocation];
                noInternetConexionView.alpha = 0;
            }
            
            isInternetActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"CHECKIN VIEW: The internet is working via WWAN.");
            
            if(!isInternetActive) {
                [self.locationManager startUpdatingLocation];
                noInternetConexionView.alpha = 0;
            }
            
            isInternetActive = YES;
            
            break;
        }
    }
    
//    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
//    switch (hostStatus)
//    {
//        case NotReachable:
//        {
//            NSLog(@"A gateway to the host server is down.");
//            //            self.hostActive = NO;
//            
//            break;
//        }
//        case ReachableViaWiFi:
//        {
//            NSLog(@"A gateway to the host server is working via WIFI.");
//            //            self.hostActive = YES;
//            
//            break;
//        }
//        case ReachableViaWWAN:
//        {
//            NSLog(@"A gateway to the host server is working via WWAN.");
//            //            self.hostActive = YES;
//            
//            break;
//        }
//    }

}

- (void)setLoadingMaskAndIndicator {
    //Start loading mask.
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.loadingMask.backgroundColor = [UIColor blackColor];
    self.loadingMask.alpha = 0.5;
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    
    
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.loadingMask];
    [[[UIApplication sharedApplication] keyWindow] addSubview:indicator];
    
    [indicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handleBack:(id)sender {
    // pop to root view controller
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    int parentViewControllerIndex = [viewControllerArray count] - 2;
    GIHomeViewController *checkinViewController = [self.navigationController.viewControllers objectAtIndex:(parentViewControllerIndex)];
    [self.navigationController popViewControllerAnimated:YES];
    
    [checkinViewController hideNavBar];
    
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
    return [self.nearbyLocationsAry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    GICompanyCheckinCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GICompanyCheckinCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    GICompany *company = [self.nearbyLocationsAry objectAtIndex:indexPath.row];
    
    NSLog(@"%@", [NSString stringWithFormat:@"row %d", indexPath.row]);
    
    [cell.nameLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0f]];

    cell.nameLabel.text = company.name;
    
    // Here we use the new provided setImageWithURL: method to load the web image
    
    NSString *urlRewardString = [NSString stringWithFormat:@"%@/companyAssets/%@/rewardImage.jpg", kBASE_URL, company.companyId];
    
    [[SDImageCache sharedImageCache] removeImageForKey:urlRewardString fromDisk:YES];
    
    NSLog(@"%@", urlRewardString);
    
    cell.mainLabel.alpha = 0;
    
    [cell.mainLabel setImageWithURL:[NSURL URLWithString:urlRewardString] placeholderImage:[UIImage imageNamed:@"rewardBackgroundPlaceholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [UIView animateWithDuration:0.4 animations:^{

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            cell.mainLabel.alpha = 1;
#pragma clang diagnostic pop

            cell.mainLabel = nil;
        } completion:^(BOOL finished) {
            NSLog(@"Image loaded");
        }];
    }];
    
    cell.distancelbl.text = company.distanceStr;

    if([company.fulfillment isEqualToString:@"YES"]) {

        [cell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            UIView *cellBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            [cellBackgroundView setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
            [cell setBackgroundView:cellBackgroundView];
            
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        
 
        
    } else {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    return cell;
}

//Change the Height of the Cell [Default is 44]:
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 198;
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
    // Navigation logic may go here. Create and push another view controller.
    // Pass the selected object to the new view controller.
    //[self.navigationController pushViewController:detailViewController animated:YES];
    
    GICompany *selectedCompany = [self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    
    NSString *segueName;
    
    if([selectedCompany.fulfillment isEqualToString:@"YES"]) {
        segueName = @"fulfillmentViewSegue";
    } else if([selectedCompany.reward isEqualToString:@"YES"]) {
        segueName = @"rewardViewSegue";
    } else {
        segueName = @"eventDrillDownViewSegue";
    }
    
    //TODO CHANGE THIS BY REMOVING IT!!!!!!!!!!!
    //segueName = @"eventDrillDownViewSegue";
    NSLog(@"Segue path is %@", segueName);
    
    [self performSegueWithIdentifier:segueName sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self.slideMenuButtonNotificationLabel removeFromSuperview];
    
    NSLog(@"Calling rewardViewSegue");
    if ([[segue identifier] isEqualToString:@"rewardViewSegue"]) {
        
        NSLog(@"setting up rewardViewSegue");
        // Get reference to the destination view controllers
        GIRewardViewController *vc = [segue destinationViewController];
        [vc setCompany:[self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        
    } else if([[segue identifier] isEqualToString:@"fulfillmentViewSegue"]) {
        GIFulfillmentViewController *vc = [segue destinationViewController];
        [vc setCompany:[self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
   
    } else if([[segue identifier] isEqualToString:@"eventDrillDownViewSegue"]) {
        GIEventScrollViewController *vc = [segue destinationViewController];
        vc.company = (GICompany*)[self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        NSTimeInterval timeInMilliseconds = [[NSDate date] timeIntervalSince1970];
        
        NSLog(@"The time in Milliseconds %f", timeInMilliseconds);
        
        GICompany *selectedCompany = (GICompany*)[self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:([selectedCompany.endDate floatValue] / 1000)];
        // Divided by 1000 (i.e. removed three trailing zeros) ^^^^^^^^
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        // Fri, 28 Jun 2013 11:26:29 GMT
        NSLog(@"formattedDateString: %@", formattedDateString);
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"HH:mm:ss"];
        
        NSDate *now = [[NSDate alloc] init];
        
        NSLog(@"Compare NOW %@ with Interval %@", now, formattedDateString);
        
        NSString *theDate = [dateFormat stringFromDate:now];
        NSString *theTime = [timeFormat stringFromDate:now];
        
        NSLog(@"\n"
              "theDate: |%@| \n"
              "theTime: |%@| \n"
              , theDate, theTime);
        
        NSLog(@"Compare milliseconds ENDDATE %f with MILLISECONDS %f", [selectedCompany.endDate floatValue], timeInMilliseconds);

        //TODO CHANGE THIS BACK TO <=
        if(([selectedCompany.endDate floatValue] / 1000) < timeInMilliseconds ||  timeInMilliseconds < ([selectedCompany.startDate floatValue] / 1000)) {
            
            NSLog(@"Currently no events");
            [vc showNoEventsPopUp:selectedCompany.newsURLString];
        }
    }
}

#pragma mark -CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"didEnterRegion");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"didExitRegion");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
}
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    NSLog(@"didFinishDeferredUpdatesWithError");
    
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"locationManagerDidPauseLocationUpdates");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"The manager.location %@", manager.location);
    
    NSLog(@"manager.location.horizontalAccuracy %f && self.locationManager.desiredAccuracy %f",manager.location.horizontalAccuracy, self.locationManager.desiredAccuracy  );
    
//    if (manager.location.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
    
        NSString *urlString = [NSString stringWithFormat:@"%@geoSpatialQuery/%@/%f/%f", GOOSIIAPI, [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"], manager.location.coordinate.longitude, manager.location.coordinate.latitude];
        
        NSLog(@"THE URL STRING FOR CHECKING IN %@", urlString);
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        
        NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        if(!error) {
                                   
           [self.nearbyLocationsAry removeAllObjects];
           
           if(!error) {
               NSLog(@"THE RESPONSE %@", response);
               
               // your data or an error will be ready here
               NSString* documentResponseString = [[NSString alloc] initWithData:data
                                                        encoding:NSUTF8StringEncoding];
               
               GICompanyFactory *compFactory = [[GICompanyFactory alloc] initWithDocument:documentResponseString withLocationManager:manager];
               self.nearbyLocationsAry = compFactory.companies;
               
               //Stop updating users location
               [self.locationManager stopMonitoringSignificantLocationChanges];
               [self.locationManager stopUpdatingLocation];

               [self.loadingMask removeFromSuperview];
               [indicator stopAnimating];
               NSLog(@"POST NSURLCONNECTION & RELOADING TABLE VIEW %lu", (unsigned long)[self.nearbyLocationsAry count] );
               [self.tableView reloadData];
               
               if([self.nearbyLocationsAry count] == 0) {
                   noEventsNearbyController = [[GINoEventsNearby alloc] initWithNibName:@"GINoEventsNearby" bundle:nil];
                   
                   [self addChildViewController:noEventsNearbyController];
                   [self.tableView addSubview:noEventsNearbyController.view];
                   
               }
           } else if(error) {
               NSLog(@"Server Maintenance Under way.");
               CGRect rect = CGRectMake(0.0, 0.0, 320.0, 50.0);
               UIView *errorView = [[UIView alloc] initWithFrame:rect];
               [errorView setBackgroundColor:[self colorWithHexString:@"4965D6"]];
               UILabel *errorStatusLbl = [[UILabel alloc] initWithFrame:rect];
               [errorStatusLbl setBackgroundColor:[self colorWithHexString:@"4965D6"]];
               
               [errorStatusLbl setText:@"Server Error. Our Engineers Are On It!"];
               [errorStatusLbl setTextColor:[UIColor whiteColor]];
               
               errorStatusLbl.numberOfLines = 0;
               [errorStatusLbl sizeToFit];
               
               [errorStatusLbl setTextAlignment:NSTextAlignmentCenter];
               [self.tableView addSubview:errorView];
               [errorView addSubview:errorStatusLbl];
               [errorStatusLbl setCenter:errorView.center];
           }
        }
        
        [self.locationManager stopMonitoringSignificantLocationChanges ];
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        
        [UIView animateWithDuration:0.5 animations:^{
            mapView.alpha = 0;
        } completion:^(BOOL finished) {
            [mapView removeFromSuperview];
        }];
//    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Asynchronous call failed");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"CLLocation is working didUpdateToLocation: %@", newLocation);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion");
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    NSLog(@"locationManagerShouldDisplayHeadingCalibration");
    return YES;
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 5;
    [self.locationManager startUpdatingLocation];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    
    NSLog(@"mapViewDidFinishLoadingMap");
    NSLog(@"Instantiating self.locationManager");
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 5;
    [self.locationManager startUpdatingLocation];
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
