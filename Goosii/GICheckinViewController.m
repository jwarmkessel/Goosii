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
#import "GIDashboardViewController.h"
#import "GIEventBoardViewController.h"
#import "GIPlist.h"
#import "GIFulfillmentViewController.h"

#define METERS_PER_MILE 1609.344
#define METERS_TO_MILE_CONVERSION 0.00062137
#define DISTANCE_ALLOWED_FROM_COMPANY 200.0f

@interface GICheckinViewController ()
@property (strong, nonatomic) UIView *loadingMask;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@end

@implementation GICheckinViewController
@synthesize loadingMask, nearbyLocationsAry, locationManager, indicator;

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
    
    self.navigationController.navigationBarHidden = NO;

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 5;
    [self.locationManager startUpdatingLocation];
    
    self.nearbyLocationsAry = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    GICompany *company = [self.nearbyLocationsAry objectAtIndex:indexPath.row];
    cell.textLabel.text = company.name;
    return cell;
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
    
    if([selectedCompany.reward isEqualToString:@"YES"]) {
        segueName = @"rewardViewSegue";
    } else if([selectedCompany.fulfillment isEqualToString:@"YES"]) {
        segueName = @"fulfillmentViewSegue";
    } else {
        segueName = @"eventDrillDownViewSegue";
    }
    segueName = @"eventDrillDownViewSegue";
    NSLog(@"Segue path is %@", segueName);
    
    [self performSegueWithIdentifier:segueName sender:self];
    
    GICompany *curCompany = [self.nearbyLocationsAry objectAtIndex:indexPath.row];
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    //Enter the user into the contest if they haven't already.
    NSString *urlString = @"http://www.goosii.com:3001/enterContest";
    urlString = [urlString stringByAppendingFormat:@"/%@", [plist objectForKey:@"userId"]];
    urlString = [urlString stringByAppendingFormat:@"/%@", curCompany.companyId];
    
    NSLog(@"Requesting %@", urlString);

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               // your data or an error will be ready here
                               NSString* newStr = [[NSString alloc] initWithData:data
                                                                        encoding:NSUTF8StringEncoding];
                               NSLog(@"enterContests response: %@", newStr);
                               
                           }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Make sure your segue name in storyboard is the same as this line
    
    /*
     Get selected comp obj.
     reward trigger
     fulfillment trigger
     segueName = @"rewardViewSegue";

     segueName = @"fulfillmentViewSegue";

     segueName = @"testTableViewSegue";
     */
    if ([[segue identifier] isEqualToString:@"rewardViewSegue"]) {
        // Get reference to the destination view controller
        //GIDashboardViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        
        //[vc setCompany:[self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
    } else if([[segue identifier] isEqualToString:@"fulfillmentViewSegue"]) {
        GIFulfillmentViewController *vc = [segue destinationViewController];
        //vc.company = [self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row];
   
    } else if([[segue identifier] isEqualToString:@"eventDrillDownViewSegue"]) {
        GIEventBoardViewController *vc = [segue destinationViewController];
        vc.company = [self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        NSTimeInterval timeInMilliseconds = [[NSDate date] timeIntervalSince1970];
        
        timeInMilliseconds = timeInMilliseconds/1000;
        
        NSLog(@"startDate %f v curDate %f", [[vc.company startDate] floatValue], floor(timeInMilliseconds));
        if([[vc.company startDate] floatValue] <= timeInMilliseconds) {
            NSLog(@"Currently no events");
            [vc noEventsPopUp];
            
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    NSLog(@"The manager.location %@", manager.location);
    NSString *urlString = @"http://www.goosii.com:3001/nearbyCompanies";
    urlString = [urlString stringByAppendingFormat:@"/%@", [plist objectForKey:@"userId"]];    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               // your data or an error will be ready here
                               NSString* newStr = [[NSString alloc] initWithData:data
                                                                        encoding:NSUTF8StringEncoding];
                               
                               SBJsonParser *parser = [[SBJsonParser alloc] init];
                               
                               NSArray *jsonObject = [parser objectWithString:newStr];
                               
                               for (id company in jsonObject) {
                                   //NSDictionary *company = [jsonObject objectAtIndex:0];
                                   
                                   NSString *latitudeStr = [company objectForKey:@"latitude"];
                                   NSString *longitudeStr = [company objectForKey:@"longitude"];
                                   
                                   NSArray *participantsAry = [company objectForKey:@"participants"];
                                                                      
                                   NSString *totalParticipants = [NSString stringWithFormat:@"%lu", (unsigned long)[participantsAry count]];

                                   //NSLog(@"The Phone number %@", [company objectForKey:@"telephone"]);
                                   
                                   //Determine percentage of time
                                   NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
                                   
                                   //NSLog(@"The Current Date %f", timeInMiliseconds);
                                   NSDictionary *event = [company objectForKey:@"contest"];
                                   float startDate = floor([[event objectForKey:@"startDate"] floatValue]);
                                   float endDate = floor([[event objectForKey:@"endDate"] floatValue]);
                                   
                                   //NSLog(@"The start %f, end %f", startDate, endDate);
                                   float curTime = floor(timeInMiliseconds);
                                   
                                   float totalDuration = endDate - startDate;
                                   
                                   float elapsedTime = curTime - totalDuration;
                                   
                                   float percentage = elapsedTime / totalDuration;
                                   
                                   NSString *timePercent = [NSString stringWithFormat:@"%f", percentage];
                                   
//                                   NSLog(@"The percentage %f, elapsed %f, totalDuration %f, curTime %f", percentage, elapsedTime, totalDuration, curTime);
                                   
                                   //Calc percentage.
                                   float partPercentage = 0;
                                   
                                   NSDictionary *userObj = [company objectForKey:@"user"];
                                   NSArray *contests = [userObj objectForKey:@"contests"];
                                   for (id contest in contests) {
                                       NSString *contestCompanyId =[contest objectForKey:@"companyId"];
                                       NSString *companyId = [company objectForKey:@"_id"];
                                       
                                       if([contestCompanyId isEqualToString:companyId]) {
                                       
                                           float ttlParticipationCount = [[contest objectForKey:@"participationCount"] floatValue];
                                           
                                           if(totalDuration != 0.0) {
                                               partPercentage = elapsedTime / 86400000;
                                               partPercentage = floor(partPercentage);
                                               partPercentage = ttlParticipationCount / partPercentage;
                                           }
                                       }
                                   }
                                   
                                   NSString *partPer = [NSString stringWithFormat:@"%f", partPercentage];
                                   
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
                                   
                                  //Check rewards
                                   NSArray *rewards = [userObj objectForKey:@"rewards"];
                                   
                                   for (id contest in rewards) {
                                       NSString *contestCompanyId =[contest objectForKey:@"companyId"];
                                       NSString *companyId = [company objectForKey:@"_id"];
                                       
                                       if([contestCompanyId isEqualToString:companyId]) {
                                           
                                           NSLog(@"Setting reward for %@", [company objectForKey:@"name"]);
                                           isReward = @"YES";
                                       }
                                   }
                                   
                                   //Create company object and push to array.
                                   GICompany *companyObj = [[GICompany alloc] initWithName:[company objectForKey:@"name"] companyId:[company objectForKey:@"_id"] address:[company objectForKey:@"address"] telephone:[company objectForKey:@"telephone"] numOfParticipants:totalParticipants time:timePercent participation:partPer startDate:[event objectForKey:@"startDate"] endDate:[event objectForKey:@"endDate"] fulfillment:isFulfillment reward:isReward];
                                   

                                   //Determine whether company is near enough
                                   CLLocation *companyLocation = [[CLLocation alloc] initWithLatitude:[latitudeStr floatValue] longitude:[longitudeStr floatValue]];
                                   float distanceInMiles = METERS_TO_MILE_CONVERSION * [manager.location distanceFromLocation:companyLocation];
                                   //NSLog(@"%f miles", distanceInMiles);
                                   
                                   if(distanceInMiles < DISTANCE_ALLOWED_FROM_COMPANY) {
                                       //NSLog(@"Include the %@", [company objectForKey:@"name"]);
                                       [self.nearbyLocationsAry addObject:companyObj];
                                   }
                               }
                               [self.tableView reloadData];
                               [self.loadingMask removeFromSuperview];
                               [indicator stopAnimating];

                           }];
    
    [self.locationManager stopMonitoringSignificantLocationChanges ];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
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


@end
