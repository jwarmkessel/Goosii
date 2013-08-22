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


@interface GIEventBoardViewController ()
{
    UITextView *sharingTextView;
}
@property (nonatomic, strong) UIView *loadingMask;
@property (nonatomic, strong) UIView *enteredPopUpView;

@property (nonatomic, strong) GIProgressBar *participationBar;
@property (nonatomic, strong) GIProgressBar *timeDurationBar;

@property (nonatomic, strong) UITableViewCell *moreInfoTblViewcell;
@property (nonatomic, strong) UITableViewCell *currentSelectedCell;
@property (nonatomic, strong) UIButton *participationBtn;

@property (nonatomic, strong) UIView *noEventsPopUpView;
@property (nonatomic, strong) UIView *companyInfoContainerView;

@property (nonatomic, strong) UIBarButtonItem *backButton;
@end

@implementation GIEventBoardViewController
@synthesize company, noEventsPopUpView, mapView, companyInfoContainerView, backButton;

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
    
    // change the back button to cancel and add an event handler
    
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"back"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(handleBack:)];
    self.navigationItem.leftBarButtonItem = backButton;

    //Set the color of the NavBar
    self.navigationController.navigationBar.tintColor = [self colorWithHexString:@"C63D0F"];
    self.wantsFullScreenLayout = YES;
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setAlpha:0.9];
    
    //Set mapview delegate
    [self.mapView setDelegate:self];
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    NSLog(@"Mapview did started loading");    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    NSLog(@"Mapview did finish loading");
}

- (void)showCompanyInfo {
    
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
    
    UITextView *companyNameLbl = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, xWidth,150.0f)];
    companyNameLbl.text = self.company.name;
    companyNameLbl.textAlignment = NSTextAlignmentCenter;;
    [companyNameLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:20.0f]];
    companyNameLbl.textColor = [UIColor whiteColor];
    companyNameLbl.backgroundColor = [UIColor clearColor];
    companyNameLbl.editable = NO;
    
    UITextView *addressLbl = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, xWidth,150.0f)];
    addressLbl.text = self.company.address;
    addressLbl.textAlignment = NSTextAlignmentCenter;;
    [addressLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:20.0f]];
    addressLbl.textColor = [UIColor whiteColor];
    addressLbl.backgroundColor = [UIColor clearColor];
    addressLbl.editable = NO;
    
    UITextView *telLbl = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, xWidth,150.0f)];
    telLbl.text = [NSString stringWithFormat:@"%@", self.company.telephone];
    telLbl.textAlignment = NSTextAlignmentCenter;;
    [telLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:20.0f]];
    telLbl.textColor = [UIColor whiteColor];
    telLbl.backgroundColor = [UIColor clearColor];
    telLbl.editable = NO;
    
    UIButton *closeCompanyInfoViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(xWidth-25, -10.0, 45.0, 45.0)];
    [closeCompanyInfoViewBtn setBackgroundColor:[UIColor blackColor]];
    [closeCompanyInfoViewBtn.layer setCornerRadius:22.5];
    
    [self.companyInfoContainerView addSubview:companyNameLbl];
    [self.companyInfoContainerView addSubview:addressLbl];
    [self.companyInfoContainerView addSubview:telLbl];
    [self.companyInfoContainerView addSubview:closeCompanyInfoViewBtn];
    
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

- (void)showNoEventsPopUp {
    float xPos = [[UIScreen mainScreen] bounds].size.width;
    //UIView *noEventsPopUpMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self.tableView setAlpha:0.5];
    xPos = xPos/2 - 100.0f;
    float yPos = 75.0f;
    CGRect noEventsPopUpRect = CGRectMake(xPos, yPos, 200.0f, 200.0f);
    self.noEventsPopUpView = [[UIView alloc] initWithFrame:noEventsPopUpRect];
    self.noEventsPopUpView.layer.borderColor = [UIColor blackColor].CGColor;
    self.noEventsPopUpView.layer.borderWidth = 3.0f;
    
    UITextView *noEventLbl = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 200.0f,150.0f)];
    noEventLbl.text = @"Sorry! There aren't any events at the moment.";
    noEventLbl.textAlignment = NSTextAlignmentCenter;;
    [noEventLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:20.0f]];
    noEventLbl.textColor = [UIColor whiteColor];
    noEventLbl.backgroundColor = [UIColor clearColor];
    noEventLbl.editable = NO;
    
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

        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
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
        companyNameLbl.text = self.company.name;
        [companyNameLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:20.0]];
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
        UIButton* infoBtn = [[UIButton alloc] initWithFrame:infoRect];
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
        [totalParticipantsLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:60.0]];
        totalParticipantsLbl.textColor = [UIColor whiteColor];
        totalParticipantsLbl.backgroundColor = [UIColor clearColor];
        totalParticipantsLbl.textAlignment = NSTextAlignmentCenter;
        
        UILabel *ttlPartLbl = [[UILabel alloc] initWithFrame:CGRectMake(cell.layer.frame.size.width/2-160, transparentTotalParticipantCell.layer.frame.size.height - 35, 320.0, 50.0)];
        ttlPartLbl.text = @"Participating";
        [ttlPartLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:15.0]];
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
        NSString *announceDateStr = [NSString stringWithFormat:@"Winner to be announced %@", timeStamp];
        
        UILabel *endDateLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 5.0f, 320.0,15.0)];
        endDateLbl.text = announceDateStr;
        [endDateLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:13.0]];
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
            
            float percentWidth = [self.company.timePercentage floatValue] * cell.frame.size.width;
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
        
        UILabel *participationLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 320.0f,15.0f)];
        participationLbl.text = @"Your Participation";
        [participationLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:13.0f]];
        participationLbl.textColor = [UIColor whiteColor];
        participationLbl.backgroundColor = [UIColor clearColor];
        
        //Progress bar elements for participation rate and the duration of the contest.
        float progressBarWidth = 280.0f;
        float xPos = (cell.frame.size.width/2 - (progressBarWidth/2));
        float progressBarThickness = 20.0f;
        CGRect participationBarBackgroundRect = CGRectMake(xPos, 20.0f, progressBarWidth, progressBarThickness);
        
        GIProgressBar *participationBarBackground = [[GIProgressBar alloc] initWithFrame:participationBarBackgroundRect hexStringColor:@"FF3100"];
        
        CGRect participationBarRect = CGRectMake(xPos, 20.0f, 0.0f, progressBarThickness);
        self.participationBar = [[GIProgressBar alloc] initWithFrame:participationBarRect hexStringColor:@"3EFF29"];
        
        self.participationBtn = [[UIButton alloc] initWithFrame:CGRectMake(cell.layer.frame.size.width/2 - (200/2), self.participationBar.layer.frame.origin.y + progressBarThickness + 15.0f, 200.0f, 50.0f)];

        [cell addSubview:transparentEngCell];
        [cell addSubview:participationBarBackground];
        [cell addSubview:self.participationBar];
        [cell addSubview:participationLbl];
        
        //Animate the progress bars to juic-ify this app!
        [UIView animateWithDuration:1 animations:^{
            
            float partWidth = [self.company.participationPercentage floatValue] * cell.frame.size.width;
            NSLog(@"The percentage %f and cell width %f", [self.company.participationPercentage floatValue], cell.frame.size.width);
            NSLog(@"The caluc %f", partWidth);
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
        
        UILabel *fbPartLbl = [[UILabel alloc] initWithFrame:CGRectMake((cell.frame.size.width/2-110), 10.0f, 220.0f,30.0f)];
        fbPartLbl.text = @"Post To Increase Participation";
        [fbPartLbl setFont:[UIFont fontWithName:@"Kailasa-Bold" size:15.0f]];
        fbPartLbl.textColor = [UIColor whiteColor];
        fbPartLbl.backgroundColor = [UIColor clearColor];
        fbPartLbl.textAlignment = NSTextAlignmentCenter;
        
        [cell addSubview:participationBackgroundImageView];
        [cell addSubview:fbPartLbl];
        [cell addSubview:self.participationBtn];
    }
    //            //disable touch gestures while loading mask is in place
    //            [self.tableView setUserInteractionEnabled:NO];
    //
    //            //Create and add a loading mask behind the pop up view.
    //            self.loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //            [self.loadingMask setBackgroundColor:[UIColor blackColor]];
    //            [self.loadingMask setAlpha:0.5];
    //
    //            //Add a pop up view to indicate to the user that an event has been entered into.
    //            float width = 240.0f;
    //            float height = 240.0f;
    //
    //            CGRect popUpRect = CGRectMake(320/2-120, 100.0f, width, height);
    //            self.enteredPopUpView = [[UIView alloc] initWithFrame:popUpRect];
    //            [self.enteredPopUpView setBackgroundColor:[self colorWithHexString:@"994747"]];
    //            self.enteredPopUpView.layer.shadowColor = [UIColor blackColor].CGColor;
    //            self.enteredPopUpView.layer.shadowOpacity = 0.5;
    //            self.enteredPopUpView.layer.shadowRadius = 3;
    //            self.enteredPopUpView.layer.shadowOffset = CGSizeMake(.6f, .6f);
    //            self.enteredPopUpView.layer.cornerRadius = 4;
    //
    //            CGRect textViewRect = CGRectMake(5.0f, 5.0f, 230.0f, 200.0f);
    //            UITextView *textView = [[UITextView alloc] initWithFrame:textViewRect];
    //            textView.text = @"You're Entered Into the Event.";
    //            textView.textAlignment = UITextAlignmentLeft;
    //            [textView setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]];
    //            [textView setBackgroundColor:[self colorWithHexString:@"EBDCDC"]];
    //
    //            [self.enteredPopUpView addSubview:textView];
    //
    //            [self.view addSubview:self.loadingMask];
    //            [self.view addSubview:self.enteredPopUpView];
    //
    //            CABasicAnimation *theAnimation;
    //
    //            theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    //            theAnimation.duration=0.2;
    //            theAnimation.repeatCount=2;
    //            theAnimation.autoreverses=YES;
    //            theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    //            theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    //            [self.enteredPopUpView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
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
                
                NSLog(@"The result %d", result);
                GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
                NSString *urlString = @"http://www.goosii.com:3001/addUserParticipation/";
                urlString = [urlString stringByAppendingString:[plist objectForKey:@"userId"]];
                urlString = [urlString stringByAppendingString:@"/"];
                urlString = [urlString stringByAppendingString:self.company.companyId];
                
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

#pragma mark - Table view data source

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

//- (void)moreInfoCellHandler {
//    NSLog(@"more info button clicked");
//    NSInteger animatedCellIndex = 1;
//    NSMutableArray *indexPathsArray = [[NSMutableArray alloc] init];
//    NSNumber *number = [NSNumber numberWithInt:animatedCellIndex];
//    [indexPathsArray addObject:number];
//    
//    [self.tableView reloadRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.currentSelectedCell.frame = CGRectMake(0.0, 0.0, self.currentSelectedCell.layer.frame.size.width, 400.0f);
//
//    } completion:^(BOOL finished) {
//        NSLog(@"Expansion complete");
//    }];
//}


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
