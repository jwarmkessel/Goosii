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

#define METERS_PER_MILE 1609.344
#define METERS_TO_MILE_CONVERSION 0.00062137
#define DISTANCE_ALLOWED_FROM_COMPANY 40.0f

@interface GICheckinViewController () {
    BOOL isFromChild;
}
@property (strong, nonatomic) UIView *loadingMask;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) GINoEventsNearby *noEventsNearbyController;
@end

@implementation GICheckinViewController
@synthesize loadingMask, nearbyLocationsAry, locationManager, indicator, noEventsNearbyController;

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

    //Start location services.
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 5;
    [self.locationManager startUpdatingLocation];
    
    self.nearbyLocationsAry = [[NSMutableArray alloc] init];
    
    // change the back button to cancel and add an event handler
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"back"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(handleBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    //Set the color of the NavBar
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setAlpha:0.9];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
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

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Check-in View Will Appear");
    [super viewWillAppear:YES];

    //Start loading mask.
    self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.loadingMask.backgroundColor = [UIColor blackColor];
    self.loadingMask.alpha = 0.5;
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    [self.view addSubview:self.loadingMask];
    [self.view addSubview:indicator];
    
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
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    GICompany *company = [self.nearbyLocationsAry objectAtIndex:indexPath.row];
//    
//    NSLog(@"%@", [NSString stringWithFormat:@"row %d", indexPath.row]);
//    
//    [cell.textLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0f]];
//    cell.textLabel.text = company.name;
//    
//    // Here we use the new provided setImageWithURL: method to load the web image
//    
//    NSString *urlRewardString = [NSString stringWithFormat:@"%@/companyAssets/%@/rewardImageThumb.png", kBASE_URL, company.companyId];
//    
//    [[SDImageCache sharedImageCache] removeImageForKey:urlRewardString fromDisk:YES];
//
//    NSLog(@"%@", urlRewardString);
//    [cell.imageView setImageWithURL:[NSURL URLWithString:urlRewardString]
//                   placeholderImage:[UIImage imageNamed:@"imagePlaceHolder.png"]];
//    
//    UILabel *milesLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, cell.frame.size.height)];
//    
//    milesLbl.text = company.distanceStr;
//    
//    cell.accessoryView =milesLbl;
//    return cell;
    
    /*******************************************************************************************/
    
    static NSString *CellIdentifier = @"Cell";
    GICompanyCheckinCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GICompanyCheckinCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    GICompany *company = [self.nearbyLocationsAry objectAtIndex:indexPath.row];
    
    NSLog(@"%@", [NSString stringWithFormat:@"row %d", indexPath.row]);
    
//    [cell.textLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0f]];
    [cell.nameLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0f]];

    cell.nameLabel.text = company.name;
    
    // Here we use the new provided setImageWithURL: method to load the web image
    
    NSString *urlRewardString = [NSString stringWithFormat:@"%@/companyAssets/%@/rewardImage.jpg", kBASE_URL, company.companyId];
    
    [[SDImageCache sharedImageCache] removeImageForKey:urlRewardString fromDisk:YES];
    
    NSLog(@"%@", urlRewardString);
    [cell.mainLabel setImageWithURL:[NSURL URLWithString:urlRewardString]
                   placeholderImage:[UIImage imageNamed:@"rewardBackgroundPlaceholder.png"]];
    
//    UILabel *milesLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, cell.frame.size.height)];
    cell.distancelbl.text = company.distanceStr;
//    milesLbl.text = company.distanceStr;
    if([company.fulfillment isEqualToString:@"YES"]) {

        [cell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
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
    
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    NSLog(@"The manager.location %@", manager.location);
    NSString *urlString = [NSString stringWithFormat:@"%@geoSpatialQuery/%@/%f/%f", GOOSIIAPI, [plist objectForKey:@"userId"], manager.location.coordinate.longitude, manager.location.coordinate.latitude];
    
    NSLog(@"THE URL STRING FOR CHECKING IN %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [self.nearbyLocationsAry removeAllObjects];
                               if(!error) {
                                   NSLog(@"THE RESPONSE %@", response);
                                   
                                   // your data or an error will be ready here
                                   NSString* newStr = [[NSString alloc] initWithData:data
                                                                            encoding:NSUTF8StringEncoding];
                                   
                                   NSLog(@"%@", newStr);
                                   
                                   SBJsonParser *parser = [[SBJsonParser alloc] init];
                                   
                                   NSDictionary *superObject = [parser objectWithString:newStr];
                                   NSDictionary *userObj = [superObject objectForKey:@"userObject"];
                                   NSArray *results = [superObject objectForKey:@"results"];
                                   
                                   for (id result in results) {
                                       //This is the company object.
                                       NSDictionary *company = [result objectForKey:@"obj"];
                                       
                                       NSString *newsURLString = @"";
                                       
                                       if([[company objectForKey:@"newsURL"] length] != 0 ){
                                           newsURLString = [company objectForKey:@"newsURL"];
                                           NSLog(@"                                 ---------=========> THE NEWS URL %@", newsURLString);
                                       }

                                       //Set longitude and latitude
                                       NSDictionary *location = [company objectForKey:@"location"];
                                       NSArray *coordinateArray = [location objectForKey:@"coordinates"];
                                       NSString *longitudeStr = [NSString stringWithFormat:@"%@", [coordinateArray objectAtIndex:0]];
                                       NSString *latitudeStr = [NSString stringWithFormat:@"%@", [coordinateArray objectAtIndex:1]];

                                       NSArray *participantsAry = [company objectForKey:@"participants"];
                                       
                                       BOOL isParticipating = NO;
                                       int totalParticipantsNum = [participantsAry count];
                                       
                                       NSLog(@"The total participants num %lu", (unsigned long)[participantsAry count]);
                                       
                                       //Check if user is participating in this event and temporarily add 1 if not
                                       for (id participantsId in participantsAry) {
                                           NSLog(@"Checking if user is already a participant %@", [NSString stringWithFormat:@"%d", totalParticipantsNum]);
                                           NSString *partObj = [participantsId objectForKey:@"userId"];
                                           
                                           
                                           
                                           if([[plist objectForKey:@"userId"] isEqualToString:partObj]){
                                               NSLog(@"User is totally entered already %@", [NSString stringWithFormat:@"%d", totalParticipantsNum]);
                                               isParticipating = YES;
                                           }
                                       }
                                       
                                       if(!isParticipating){
                                           NSLog(@"Incrementing users count %@", [NSString stringWithFormat:@"%d", totalParticipantsNum]);
                                           totalParticipantsNum++;
                                       }
                                       
                                       NSString *totalParticipants = [NSString stringWithFormat:@"%d", totalParticipantsNum];
                                       

                                       //Determine percentage of time
                                       NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
                                                                          
                                       
                                       //NSLog(@"The Current Date %f", timeInMiliseconds);
                                       NSDictionary *event = [company objectForKey:@"contest"];
                                       
                                       double startDate = floor([[event objectForKey:@"startDate"] doubleValue]);
                                       double endDate = floor([[event objectForKey:@"endDate"] doubleValue]);
                                       startDate = startDate / 1000;
                                       endDate = endDate / 1000;

                                       
                                       NSLog(@"             The company name %@", [company objectForKey:@"name"]);
                                       NSLog(@"             The start date %f", startDate);
                                       NSLog(@"             The end date %f", endDate);
                                       
                                       NSLog(@"             The current date %f", timeInMiliseconds);
                                       
                                       float totalDuration = endDate - startDate;
                                       
                                       
                                       //Elapsed time in seconds equals the current time minus the startdate.
                                       float elapsedTime = timeInMiliseconds - startDate;

                                       
                                       NSLog(@"             ELAPSED TIME %f", elapsedTime);
                                       NSLog(@"             TOTALDURATION TIME %f", totalDuration);
                                       float percentage = elapsedTime / totalDuration;
                                       
                                       NSLog(@"                         The percentage %f", percentage);
                                       
                                       if(percentage > 1.0) {
                                           percentage = 1;
                                       }
                                       
                                       NSString *timePercent = [NSString stringWithFormat:@"%f", percentage];
                                       
                                       //Calculate Participation Percentage.
                                       float partPercentage = 0;
                                       float ttlParticipationCount = 0;
                                       
                                       NSArray *contests = [userObj objectForKey:@"contests"];
                                       
                                       for (id contest in contests) {
                                           
                                           NSLog(@" %@ ", [company objectForKey:@"name"]);
                                           
                                           NSString *contestCompanyId =[contest objectForKey:@"companyId"];
                                           NSString *companyId = [company objectForKey:@"_id"];
                                           
                                           if([contestCompanyId isEqualToString:companyId]) {
                                               
                                               NSLog(@"         %@ and %@", contestCompanyId, companyId);
                                               
                                               if([contest objectForKey:@"participationCount"] == nil) {
                                                   NSLog(@"         total participation is nil so we add one");
                                                   ttlParticipationCount = 1;
                                               } else {
                                                   ttlParticipationCount = [[contest objectForKey:@"participationCount"] floatValue];
                                               }
                                           
                                               NSLog(@"         The participation count %f", ttlParticipationCount);
                                           
                                               if(totalDuration != 0.0) {
                                                   partPercentage = elapsedTime / 86400;
                                                   
                                                   if(elapsedTime < 86400) {
                                                       partPercentage = 1;
                                                   }
                                                   
                                                   partPercentage = floor(partPercentage);

                                                   if(ttlParticipationCount > 0) {
                                                       partPercentage =  ttlParticipationCount / partPercentage;
                                                   } else {
                                                       partPercentage = 0;
                                                   }
                                                   
                                                   if(partPercentage > 1) {
                                                       partPercentage = 1;
                                                   }
                                                   
                                                   NSLog(@"         PART PERCENTAGE %f", partPercentage);
                                               }
                                               
                                               break;
                                           }
                                       }                                
                                       
                                       //Check fulfillments
                                       NSArray *fulfillments = [userObj objectForKey:@"fulfillments"];
                                       
                                       NSString *isFulfillment = @"NO";
                                       for (id contest in fulfillments) {
                                           NSString *contestCompanyId =[contest objectForKey:@"companyId"];
                                           NSString *companyId = [company objectForKey:@"_id"];
                                           
                                           if([contestCompanyId isEqualToString:companyId]) {
                                               NSLog(@"Setting fulfillment for %@", [company objectForKey:@"name"]);                                           
                                               isFulfillment = @"YES";
                                           }
                                       }
                                       
                                       NSString * isReward = @"NO";
                                       
                                      //Check rewards and fulfillment
                                       NSArray *rewards = [userObj objectForKey:@"rewards"];

                                       
                                       for (id contest in rewards) {
                                           NSString *contestCompanyId =[contest objectForKey:@"companyId"];
                                           NSString *companyId = [company objectForKey:@"_id"];
                                           
                                           
                                           if([contestCompanyId isEqualToString:companyId] && [[contest objectForKey:@"fulfillment"] floatValue] == 0) {
                                               NSLog(@"Setting reward for %@", [company objectForKey:@"name"]);
                                               isReward = @"YES";
                                               isFulfillment = @"NO";
                                               
                                               //If there is a reward that is found and fulfilled then exit this iteration.
                                               break;

                                           } else if([contestCompanyId isEqualToString:companyId]) {
                                               isReward = @"YES";
                                               isFulfillment = @"YES";
                                               
                                               break;
                                           }
                                       }
                                       

                                       
                                       NSLog(@"FINALLY THE PARTICIPATION PERCENTAGE %@", [NSString stringWithFormat:@"%f", partPercentage]);
                                       
                                       //Determine whether company is near enough
                                       NSLog(@"The longitude %@ AND the latitude %@", longitudeStr, latitudeStr);
                                       CLLocation *companyLocation = [[CLLocation alloc] initWithLatitude:[latitudeStr floatValue] longitude:[longitudeStr floatValue]];

                                       float distanceInMiles = METERS_TO_MILE_CONVERSION * [manager.location distanceFromLocation:companyLocation];

                                       [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@/companyAssets/%@/rewardImageThumb.png", kBASE_URL, [company objectForKey:@"_id"]] fromDisk:YES];
                                       
                                       //Create company object and push to array.
                                       GICompany *companyObj = [[GICompany alloc] initWithName:[company objectForKey:@"name"]
                                                                                     companyId:[company objectForKey:@"_id"]
                                                                                       address:[company objectForKey:@"address"]
                                                                                     telephone:[company objectForKey:@"telephone"]
                                                                             numOfParticipants:totalParticipants
                                                                                          time:timePercent
                                                                                 participation:[NSString stringWithFormat:@"%f", partPercentage]
                                                                                     startDate:[event objectForKey:@"startDate"]
                                                                                       endDate:[event objectForKey:@"endDate"]
                                                                                   fulfillment:isFulfillment
                                                                                        reward:isReward
                                                                                     longitude:longitudeStr
                                                                                      latitude:latitudeStr
                                                                                          post:[event objectForKey:@"post"]
                                                                                   eventReward:[event objectForKey:@"prize"]
                                                                             participationPost:[event objectForKey:@"participationPost"]
                                                                           participationPoints:[NSString stringWithFormat:@"%f", ttlParticipationCount]
                                                                                      distance:[NSString stringWithFormat:@"%.2f mi", distanceInMiles]
                                                                                       website:[event objectForKey:@"website"]
                                                                                       newsUrl:newsURLString];

                                       //Get the distance allowed by the server for checking into nearby companies.
                                       NSDictionary *distanceConfiguration = [superObject objectForKey:@"distanceConfiguration"];

                                       if(distanceInMiles < [[distanceConfiguration objectForKey:@"distance"] floatValue]) {
                                           NSLog(@"Include the %@", [company objectForKey:@"name"]);
                                           [self.nearbyLocationsAry addObject:companyObj];
                                       }
                                   }

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
                                   
                               } else {
                                   NSLog(@"Server Maintenance Under way.");
                                   CGRect rect = CGRectMake(0.0, 0.0, 320.0, 50.0);
                                   UIView *errorView = [[UIView alloc] initWithFrame:rect];
                                   [errorView setBackgroundColor:[self colorWithHexString:@"EED202"]];
                                   UILabel *errorStatusLbl = [[UILabel alloc] initWithFrame:rect];
                                   [errorStatusLbl setBackgroundColor:[self colorWithHexString:@"EED202"]];
                                   
                                   [errorStatusLbl setText:@"Oops, you are probably not connected to the Internet."];
                                   
                                   errorStatusLbl.numberOfLines = 0;
                                   [errorStatusLbl sizeToFit];
                                   
                                   [errorStatusLbl setTextAlignment:NSTextAlignmentCenter];
                                   [self.tableView addSubview:errorView];
                                   [errorView addSubview:errorStatusLbl];
                                   [errorStatusLbl setCenter:errorView.center];
                               }
                           }];
    
    [self.locationManager stopMonitoringSignificantLocationChanges ];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
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
