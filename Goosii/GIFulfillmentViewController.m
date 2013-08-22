//
//  GIFulfillmentViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 8/20/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIFulfillmentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import "GICompany.h"

@interface GIFulfillmentViewController ()
{
    UITextView *sharingTextView;
}
@property (nonatomic, strong) UIButton *participationBtn;
@end

@implementation GIFulfillmentViewController
@synthesize participationBtn, company;

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
    
    //Set image for the tableview background
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSString *urlString = [NSString stringWithFormat:@"http://www.goosii.com/companyAssets/%@/rewardImage.jpg", self.company.companyId];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    
    imgView.image = img;
    
    //TODO Not sure this is necessary
    [self.tableView setDelegate:self];
    
    [self.tableView setBackgroundView:imgView];
    
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)participationBtnHandler {
    NSLog(@"participation btn clicked");
    
    //This is the string that will get posted to the facebook wall.
    //http://goosii.com:3001/addFacebookPost/theString/theUserId
    //PList *plist = [[PList alloc] initWithNamespace:@"Goosii"];
    //    NSString *userId = [plist objectForKey:@"userId"];
    //    NSString *companyId = [plist objectForKey:@"companyId"];
    //
    //    NSString * wallText = @"I'm hanging at the HotSpot Cafe!";
    //    wallText = [wallText stringByAppendingString:@". http://yourcompanyname.Goosii.com/"];
    //    NSString *post = [self encodeToPercentEscapeString:wallText];
    //
    //    NSString *urlPost = [@"http://50.57.225.202:3001/enterSweepstake/" stringByAppendingString:post];
    //
    //    userId = [NSString stringWithFormat:@"/%@",userId];
    //    urlPost = [urlPost stringByAppendingString:userId];
    //    companyId = [NSString stringWithFormat:@"/%@",companyId];
    //    urlPost = [urlPost stringByAppendingString:companyId];
    //
    //    NSLog(@"The facebook urlpost %@", urlPost);
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *sharingComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                
            } else {
                NSLog(@"Posting to facebook.");
                
                NSLog(@"The result %d", result);
                //
                //                NSURL *url = [NSURL URLWithString:urlPost];
                //                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                //                NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                //
                //                if(!connection) {
                //                    NSLog(@"connection failed");
                //                }
                //
                //                [self performSegueWithIdentifier:@"sweepstakesDisplaySegue" sender:self];
            }
            
            [sharingComposer dismissViewControllerAnimated:YES completion:nil];
        };
        [sharingComposer setCompletionHandler:completionHandler];
        [sharingComposer setInitialText:[NSString stringWithFormat:@"%@ %@",[self editableText],[self permanentText]]];
        
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

- (NSString *)editableText
{
    return @"I'm hanging at the Hot Spot Cafe!"; //This is the text the user will be able to edit
}

- (NSString *)permanentText
{
    return @"http://yourcompanyname.Goosii.com/"; //The user will not be able to modify this text.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {

    //Create a transparent layer on top of the cell as a background to the elements on top of it.
    //This is required because otherwise the alpha set on this element affects its child elements.
    

    //The Company name and Info Panel
    UILabel *companyNameLbl = [[UILabel alloc] initWithFrame:CGRectMake((cell.layer.frame.size.width/2-160), (60/2-25), 320.0, 40.0)];
    companyNameLbl.text = self.company.name;
    [companyNameLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:20.0]];
    companyNameLbl.textColor = [UIColor whiteColor];
    companyNameLbl.backgroundColor = [UIColor clearColor];
    companyNameLbl.textAlignment = NSTextAlignmentCenter;
    
    UIView *transparentCompanyNameCell = [[UIView alloc] initWithFrame:CGRectMake(0, 10, cell.frame.size.width, 40.0)];
    [transparentCompanyNameCell setAlpha:1];
    [transparentCompanyNameCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    transparentCompanyNameCell.layer.shadowColor = [UIColor blackColor].CGColor;
    transparentCompanyNameCell.layer.shadowOpacity = 0.5;
    transparentCompanyNameCell.layer.shadowRadius = 3;
    transparentCompanyNameCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
    transparentCompanyNameCell.layer.cornerRadius = 4;
    
    [cell addSubview:transparentCompanyNameCell];
    [cell addSubview:companyNameLbl];
    
    //The Reward Panel
    UILabel *eventPrizeLbl = [[UILabel alloc] initWithFrame:CGRectMake((cell.layer.frame.size.width/2-160), 70, 320.0, 40.0)];
    eventPrizeLbl.text = self.company.reward;
    [eventPrizeLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:20.0]];
    eventPrizeLbl.textColor = [UIColor whiteColor];
    eventPrizeLbl.backgroundColor = [UIColor clearColor];
    eventPrizeLbl.textAlignment = NSTextAlignmentCenter;
    
    UIView *transparenteventPrizeCell = [[UIView alloc] initWithFrame:CGRectMake(0, 70, cell.frame.size.width, 40.0)];
    [transparenteventPrizeCell setAlpha:1];
    [transparenteventPrizeCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    transparenteventPrizeCell.layer.shadowColor = [UIColor blackColor].CGColor;
    transparenteventPrizeCell.layer.shadowOpacity = 0.5;
    transparenteventPrizeCell.layer.shadowRadius = 3;
    transparenteventPrizeCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
    transparenteventPrizeCell.layer.cornerRadius = 4;
    
    [cell addSubview:transparenteventPrizeCell];
    [cell addSubview:eventPrizeLbl];
    
    //The Prize Image and Participation Panel
//    UILabel *eventPrizeLbl = [[UILabel alloc] initWithFrame:CGRectMake((cell.layer.frame.size.width/2-160), 70, 320.0, 40.0)];
//    eventPrizeLbl.text = self.company.reward;
//    [eventPrizeLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:20.0]];
//    eventPrizeLbl.textColor = [UIColor whiteColor];
//    eventPrizeLbl.backgroundColor = [UIColor clearColor];
//    eventPrizeLbl.textAlignment = NSTextAlignmentCenter;
    
    
    UIView *transparenteventImgAndParticipationCell = [[UIView alloc] initWithFrame:CGRectMake((200/2-50), 130, 200, 100.0)];
    [transparenteventImgAndParticipationCell setAlpha:1];
    [transparenteventImgAndParticipationCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    transparenteventImgAndParticipationCell.layer.shadowColor = [UIColor blackColor].CGColor;
    transparenteventImgAndParticipationCell.layer.shadowOpacity = 0.5;
    transparenteventImgAndParticipationCell.layer.shadowRadius = 3;
    transparenteventImgAndParticipationCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
    transparenteventImgAndParticipationCell.layer.cornerRadius = 4;
    
    [cell addSubview:transparenteventImgAndParticipationCell];
//    [cell addSubview:eventPrizeLbl];
    
    //The Event Announcement Panel
    UILabel *eventAnnouncementLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 260, cell.frame.size.width, 20.0)];
    eventAnnouncementLbl.text = @"Event has ended.";
    [eventAnnouncementLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:15.0]];
    eventAnnouncementLbl.textColor = [UIColor whiteColor];
    eventAnnouncementLbl.backgroundColor = [UIColor clearColor];
    eventAnnouncementLbl.textAlignment = NSTextAlignmentCenter;

    UILabel *secondEventAnnouncementLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 280, cell.frame.size.width, 20.0)];
    secondEventAnnouncementLbl.text = @"Rewards have been announced.";
    [secondEventAnnouncementLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:15.0]];
    secondEventAnnouncementLbl.textColor = [UIColor whiteColor];
    secondEventAnnouncementLbl.backgroundColor = [UIColor clearColor];
    secondEventAnnouncementLbl.textAlignment = NSTextAlignmentCenter;
    
    UIView *eventAnnouncementCell = [[UIView alloc] initWithFrame:CGRectMake(0, 260, cell.frame.size.width, 50.0)];
    [eventAnnouncementCell setAlpha:1];
    [eventAnnouncementCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    eventAnnouncementCell.layer.shadowColor = [UIColor blackColor].CGColor;
    eventAnnouncementCell.layer.shadowOpacity = 0.5;
    eventAnnouncementCell.layer.shadowRadius = 3;
    eventAnnouncementCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
    eventAnnouncementCell.layer.cornerRadius = 4;
    
    [cell addSubview:eventAnnouncementCell];
    [cell addSubview:eventAnnouncementLbl];
    [cell addSubview:secondEventAnnouncementLbl];
    
    //The Participation Button
    CGRect backgroundImageView = CGRectMake((cell.frame.size.width/2-(cell.frame.size.width/2)), 340, cell.frame.size.width, 158);
    
    UIImage *participationBtnImage = [UIImage imageNamed:@"FB_Back.png"];
    UIImage *fbParticipationBtnImage = [UIImage imageNamed:@"FB_Button.png"];
    UIImageView *participationBackgroundImageView = [[UIImageView alloc] initWithFrame:backgroundImageView];
    [participationBackgroundImageView setImage:participationBtnImage];
    
    CGRect fbBackgroundImageView = CGRectMake((cell.frame.size.width/2-44), 390.0f, 95.0, 95.0f);
    
    self.participationBtn = [[UIButton alloc] initWithFrame:fbBackgroundImageView];
    [self.participationBtn setBackgroundImage:fbParticipationBtnImage forState:UIControlStateNormal];
    
    [self.participationBtn addTarget:self
                              action:@selector(participationBtnHandler)
                    forControlEvents:UIControlEventTouchDown];
    
    UILabel *fbPartLbl = [[UILabel alloc] initWithFrame:CGRectMake((cell.frame.size.width/2-110), 340.0f, 220.0f, 50.0f)];
    fbPartLbl.text = @"Post To Increase Participation";
    [fbPartLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:15.0f]];
    fbPartLbl.textColor = [UIColor whiteColor];
    fbPartLbl.backgroundColor = [UIColor clearColor];
    fbPartLbl.textAlignment = NSTextAlignmentCenter;
    
    [cell addSubview:participationBackgroundImageView];
    [cell addSubview:fbPartLbl];
    [cell addSubview:self.participationBtn];
    
    
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
