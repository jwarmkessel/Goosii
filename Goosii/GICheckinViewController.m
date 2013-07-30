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

#define METERS_PER_MILE 1609.344
#define METERS_TO_MILE_CONVERSION 0.00062137
#define DISTANCE_ALLOWED_FROM_COMPANY 200.0f

@interface GICheckinViewController ()
@property (strong, nonatomic) UIView *loadingMask;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation GICheckinViewController
@synthesize loadingMask, nearbyLocationsAry, locationManager;

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
    
    [self.view addSubview:self.loadingMask];
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
    
    [self performSegueWithIdentifier:@"testTableViewSegue" sender:self];
    
    GICompany *curCompany = [self.nearbyLocationsAry objectAtIndex:indexPath.row];
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    //Enter the user into the contest if they haven't already.
    NSString *urlString = @"http://www.goosii.com:3001/enterContest";
    urlString = [urlString stringByAppendingFormat:@"/%@", [plist objectForKey:@"userId"]];
    urlString = [urlString stringByAppendingFormat:@"/%@", curCompany.companyId];

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
    if ([[segue identifier] isEqualToString:@"dashboardDisplaySegue"]) {
        // Get reference to the destination view controller
        GIDashboardViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        
        [vc setCompany:[self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
    } else if([[segue identifier] isEqualToString:@"testTableViewSegue"]) {
        GIEventBoardViewController *vc = [segue destinationViewController];
        vc.company = [self.nearbyLocationsAry objectAtIndex:[self.tableView indexPathForSelectedRow].row];
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
    NSLog(@"The manager.location %@", manager.location);
    NSString *urlString = @"http://www.goosii.com:3001/nearbyCompanies";
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

                                   NSLog(@"The Phone number %@", [company objectForKey:@"telephone"]);
                                   GICompany *companyObj = [[GICompany alloc] initWithName:[company objectForKey:@"name"] companyId:[company objectForKey:@"_id"] address:[company objectForKey:@"address"] telephone:[company objectForKey:@"telephone"] numOfParticipants:totalParticipants];
                                   
                                   //Determine whether company is near enough
                                   CLLocation *companyLocation = [[CLLocation alloc] initWithLatitude:[latitudeStr floatValue] longitude:[longitudeStr floatValue]];
                                   float distanceInMiles = METERS_TO_MILE_CONVERSION * [manager.location distanceFromLocation:companyLocation];
                                   NSLog(@"%f miles", distanceInMiles);
                                   
                                   if(distanceInMiles < DISTANCE_ALLOWED_FROM_COMPANY) {
                                       NSLog(@"Include the %@", [company objectForKey:@"name"]);
                                       [self.nearbyLocationsAry addObject:companyObj];
                                   }
                               }
                               [self.tableView reloadData];
                               [self.loadingMask removeFromSuperview];

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
