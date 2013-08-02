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

@interface GIParticipationViewController ()
@property (nonatomic, strong) GICompany *selCompany;

- (void)makeContestRequest;
- (BOOL)determineFulfillment: (NSString*)companyId;

@end

@implementation GIParticipationViewController
@synthesize eventList;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if(![self.slidingViewController.underLeftViewController isKindOfClass:[GIMenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    //    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    //Initialize the dataSource
    self.eventList = [[NSMutableArray alloc] init];
    [self makeContestRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    
    if([[segue identifier] isEqualToString:@"tabViewControllerSegue"]) {
//        GIEventBoardViewController *vc = [segue destinationViewController];
//        vc.company = [self.eventList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    } else if([[segue identifier] isEqualToString:@"fulfillmentViewSegue"]) {
        
    }
}

- (void)makeContestRequest {
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    NSString *urlString = @"http://www.goosii.com:3001/getUserContests/";
    urlString = [urlString stringByAppendingString:[plist objectForKey:@"userId"]];
    
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
                               
                               NSArray *jsonObject = [parser objectWithString:newStr];
                               
                               for (id company in jsonObject) {
                                   
                                   NSArray *participantsAry = [company objectForKey:@"participants"];
                                   
                                   NSString *totalParticipants = [NSString stringWithFormat:@"%lu", (unsigned long)[participantsAry count]];
                                   
                                   
                                   //GICompany *companyObj = [[GICompany alloc] initWithName:[company objectForKey:@"name"] companyId:[company objectForKey:@"_id"] address:[company objectForKey:@"address"] telephone:[company objectForKey:@"telephone"] numOfParticipants:totalParticipants];

                                   //[self.eventList addObject:companyObj];
                               }
                               
                               [self.tableView reloadData];
                               //[self.loadingMask removeFromSuperview];
                               
                           }];
}

- (BOOL)determineFulfillment: (NSString*)companyId {
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    NSString *urlString = @"http://www.goosii.com:3001/getUserFulfillments/";
    urlString = [urlString stringByAppendingString:[plist objectForKey:@"userId"]];
    urlString = [urlString stringByAppendingString:@"/"];
    urlString = [urlString stringByAppendingString:companyId];
    
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
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    //Determine whether selected event has fulfillment requirements.
    GICompany *company = [self.eventList objectAtIndex:indexPath.row];
    NSLog(@"The company id to use %@", company.companyId);
    
    BOOL fulfillment = [self determineFulfillment:company.companyId];
    
    if(fulfillment == YES) {
        [self performSegueWithIdentifier:@"fulfillmentViewSegue" sender:self];    
    } else {
        [self performSegueWithIdentifier:@"tabViewControllerSegue" sender:self];
    }

}

- (void)viewDidUnload {
    [self setEventList:nil];
    [super viewDidUnload];
}
@end
