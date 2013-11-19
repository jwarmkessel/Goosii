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

@interface GIParticipationViewController ()
@property (nonatomic, strong) GICompany *selCompany;
@property (strong, nonatomic) UIView *loadingMask;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

- (void)makeContestRequest;
- (BOOL)determineFulfillment: (NSString*)companyId;

@end

@implementation GIParticipationViewController
@synthesize eventList, loadingMask, indicator;

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
}

-(IBAction)myAboutButtonClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight animations:^{
        NSLog(@"Sliding");
    } onComplete:^{
        NSLog(@"complete");
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.slidingViewController.panGesture.enabled = YES;
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar setAlpha:1.0f];

    [super viewWillAppear:YES];
    [self.eventList removeAllObjects];

    [self makeContestRequest];
    
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
        [vc setCompany:[self.eventList objectAtIndex:[self.tableView indexPathForSelectedRow].row]];

    } else if([[segue identifier] isEqualToString:@"fulfillmentViewSegue"]) {
        GIFulfillmentViewController *vc = [segue destinationViewController];
        [vc setCompany:[self.eventList objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        
    } else if([[segue identifier] isEqualToString:@"eventDrillDownViewSegue"]) {
        GIEventBoardViewController *vc = [segue destinationViewController];
        vc.company = [self.eventList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        NSTimeInterval timeInMilliseconds = [[NSDate date] timeIntervalSince1970];
        
        NSLog(@"The time in Milliseconds %f", timeInMilliseconds);
        
        //NSLog(@"startDate %f v curDate %f", [[vc.company startDate] floatValue], floor(timeInMilliseconds));
        float endDateInSeconds = [[vc.company endDate] floatValue] / 1000;
        NSLog(@"The time in endDateInSeconds %f", endDateInSeconds);

        float startDateInSeconds = [[vc.company startDate] floatValue] / 1000;
        
        //TODO CHANGE THIS BACK TO <=
        if(endDateInSeconds <= timeInMilliseconds ||  timeInMilliseconds < startDateInSeconds) {
            NSLog(@"Currently no events");
            [vc showNoEventsPopUp];
            
        }
    }
 
}

- (void)makeContestRequest {
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    NSString *urlString = [NSString stringWithFormat:@"%@getUserContests/%@", GOOSIIAPI, [plist objectForKey:@"userId"]];
    
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
                               
                               SBJsonParser *parser = [[SBJsonParser alloc] init];
//                               
                               NSDictionary *jsonObject = [parser objectWithString:newStr];
                               
                               NSDictionary *userObj = [jsonObject objectForKey:@"userObject"];
                               
                               NSArray *companyArray = [jsonObject objectForKey:@"contests"];
                               
                               for (id company in companyArray) {
                                   
                                   NSArray *participantsAry = [company objectForKey:@"participants"];
                                   
                                   NSString *totalParticipants = [NSString stringWithFormat:@"%lu", (unsigned long)[participantsAry count]];
                                   
                                   //NSLog(@"The Phone number %@", [company objectForKey:@"telephone"]);
                                   
                                   //Determine percentage of time
                                   NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
                                   
                                   //NSLog(@"The Current Date %f", timeInMiliseconds);
                                   NSDictionary *event = [company objectForKey:@"contest"];
                                   
                                   double startDate = floor([[event objectForKey:@"startDate"] doubleValue]);
                                   double endDate = floor([[event objectForKey:@"endDate"] doubleValue]);
                                   startDate = startDate / 1000;
                                   endDate = endDate / 1000;
                                   NSLog(@"START DATE %f", startDate);
                                   NSLog(@"END DATE %f", endDate);
                                   
                                   double curTime = floor(timeInMiliseconds);
                                   NSLog(@"CURRENT DATE %f", curTime);
                                   
                                   double totalDuration = endDate - startDate;
                                   NSLog(@"TOTAL DURATION IN MIL %f", totalDuration);
                                   
                                   //Elapsed time in seconds equals the current time minus the startdate.
                                   double elapsedTime = curTime - startDate;
                                   
                                   NSLog(@"ELAPSED TIME %f", elapsedTime);
                                   
                                   double percentage = elapsedTime / totalDuration;
                                   
                                   if(percentage > 1.0) {
                                       percentage = 1;
                                   }
                                   
                                   NSString *timePercent = [NSString stringWithFormat:@"%f", percentage];
                                   
                                   //Calculate Participation Percentage.
                                   float partPercentage = 0;
                                   float ttlParticipationCount = 0;
                                   
                                   NSArray *contests = [userObj objectForKey:@"contests"];
                                   for (id contest in contests) {
                                       partPercentage = 0;
                                       
                                       NSString *contestCompanyId =[contest objectForKey:@"companyId"];
                                       NSString *companyId = [company objectForKey:@"_id"];
                                       
                                       if([contestCompanyId isEqualToString:companyId]) {
                                           
                                           ttlParticipationCount = 0;
                                           
                                           if([contest objectForKey:@"participationCount"] == nil) {
                                               NSLog(@"total participation is nil so we add one");
                                               ttlParticipationCount = 1;
                                           } else {
                                               ttlParticipationCount = [[contest objectForKey:@"participationCount"] floatValue];
                                           }
                                           
                                           NSLog(@"The participation count %f", ttlParticipationCount);
                                           
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
                                               
                                               NSLog(@"PART PERCENTAGE %f", partPercentage);
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
                                   NSLog(@"Set Reward flag");
//                                   NSArray *rewards = [userObj objectForKey:@"rewards"];
//                                   
//                                   for (id contest in rewards) {
//                                       NSString *contestCompanyId =[contest objectForKey:@"companyId"];
//                                       NSString *companyId = [company objectForKey:@"_id"];
//                                       
//                                       if([contestCompanyId isEqualToString:companyId]) {
//                                           NSLog(@"Set Reward flag to YES");
//                                           NSLog(@"Setting reward for %@", [company objectForKey:@"name"]);
//                                           isReward = @"YES";
//                                       }
//                                   }
                                   
                                   //Check rewards and fulfillment
                                   NSArray *rewards = [userObj objectForKey:@"rewards"];
                                   
                                   for (id contest in rewards) {
                                       NSString *contestCompanyId =[contest objectForKey:@"companyId"];
                                       NSString *companyId = [company objectForKey:@"_id"];
                                       
                                       if([contestCompanyId isEqualToString:companyId]) {
                                           
                                           if ( [[contest objectForKey:@"fulfillment"] floatValue] == 0 ) {
                                               NSLog(@"Setting reward for %@", [company objectForKey:@"name"]);
                                               isReward = @"YES";
                                               isFulfillment = @"NO";
                                           } else {
                                               isFulfillment = @"YES";
                                               isReward = @"YES";
                                           }
                                       }
                                   }
                                   
                                   //Create company object and push to array.
                                   GICompany *companyObj = [[GICompany alloc] initWithName:[company objectForKey:@"name"]
                                                                                 companyId:[company objectForKey:@"_id"]
                                                                                   address:[company objectForKey:@"address"]
                                                                                 telephone:[company objectForKey:@"telephone"]
                                                                         numOfParticipants:totalParticipants
                                                                                      time:timePercent
                                                                             participation:partPer
                                                                                 startDate:[event objectForKey:@"startDate"]
                                                                                   endDate:[event objectForKey:@"endDate"]
                                                                               fulfillment:isFulfillment
                                                                                    reward:isReward
                                                                                 longitude:[company objectForKey:@"longitude"]
                                                                                  latitude:[company objectForKey:@"latitude"]
                                                                                      post:[event objectForKey:@"post"]
                                                                               eventReward:[event objectForKey:@"prize"]
                                                                         participationPost:[event objectForKey:@"participationPost"]
                                                                       participationPoints:[NSString stringWithFormat:@"%f", ttlParticipationCount]
                                                                                   website:[event objectForKey:@"website"]];
                                   
                                   NSLog(@"Adding company object");
                                   [self.eventList addObject:companyObj];

                               }
                               
                               [self.tableView reloadData];
                               [self.loadingMask removeFromSuperview];
                               [indicator stopAnimating];
                           }];
}

- (BOOL)determineFulfillment: (NSString*)companyId {
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    NSString *urlString = [NSString stringWithFormat:@"%@getUserFulfillments/%@/%@", GOOSIIAPI, [plist objectForKey:@"userId"], companyId];
    
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
    [cell.textLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0f]];
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
    
    GICompany *curCompany = [self.eventList objectAtIndex:indexPath.row];
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    //Enter the user into the contest if they haven't already.
    NSString *urlString = [NSString stringWithFormat:@"%@enterContest/%@/%@", GOOSIIAPI, [plist objectForKey:@"userId"], curCompany.companyId];
    
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
