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
#import "GICountingLabel.h"

@interface GIEventBoardViewController ()
@property (nonatomic, strong) GIProgressBar *participationBar;
@property (nonatomic, strong) GIProgressBar *timeDurationBar;

@property (nonatomic, strong) UITableViewCell *moreInfoTblViewcell;
@property (nonatomic, strong) UITableViewCell *currentSelectedCell;
@end

@implementation GIEventBoardViewController

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
    imgView.image = [UIImage imageNamed:@"vietSandwich.jpg"];
    
    //TODO Not sure this is necessary
    [self.tableView setDelegate:self];

    [self.tableView setBackgroundView:imgView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger totalParticipantsCellIndex = 4;
    NSInteger progressBarCellIndex = 6;
    NSInteger engagementCellIndex = 8;
    NSInteger companyNameCellIndex = 1;
    NSInteger moreInfoCellIndex = 2;
    NSInteger telephoneCellIndex = 3;
    
    //The current index
    NSInteger curCellIndex = [indexPath row];
    
    if(companyNameCellIndex == curCellIndex) {
        //Create a transparent layer on top of the cell as a background to the elements on top of it.
        //This is required because otherwise the alpha set on this element affects its child elements.
        UILabel *companyNameLbl = [[UILabel alloc] initWithFrame:CGRectMake((cell.layer.frame.size.width/2-160), 0.0, 320.0, 50.0)];
        companyNameLbl.text = @"HOT SPOT CAFE";
        [companyNameLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0]];
        companyNameLbl.textColor = [UIColor whiteColor];
        companyNameLbl.backgroundColor = [UIColor clearColor];
        companyNameLbl.textAlignment = UITextAlignmentCenter;
        
        UIView *transparentCompanyNameCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [transparentCompanyNameCell setAlpha:1];
        [transparentCompanyNameCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
//        transparentCompanyNameCell.layer.shadowColor = [UIColor blackColor].CGColor;
//        transparentCompanyNameCell.layer.shadowOpacity = 0.5;
//        transparentCompanyNameCell.layer.shadowRadius = 3;
//        transparentCompanyNameCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
//        transparentCompanyNameCell.layer.cornerRadius = 2;
  
        self.moreInfoTblViewcell = cell;
        [cell addSubview:transparentCompanyNameCell];
        [cell addSubview:companyNameLbl];
        
    }else if(moreInfoCellIndex == curCellIndex){
        UIView *addressCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [addressCell setAlpha:1];
        [addressCell setBackgroundColor:[self colorWithHexString:@"A60C00"]];
//        secondCell.layer.shadowColor = [UIColor blackColor].CGColor;
//        secondCell.layer.shadowOpacity = 0.5;
//        secondCell.layer.shadowRadius = 3;
//        secondCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
//        secondCell.layer.cornerRadius = 2;
        
        UILabel *addressLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, (10/2+2.5), 320.0,15.0)];
        addressLbl.text = @"2133 Morill Ave";
        [addressLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]];
        addressLbl.textColor = [UIColor whiteColor];
        addressLbl.backgroundColor = [UIColor clearColor];

        UILabel *cityInfoLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, addressLbl.layer.frame.origin.y + 15, 320.0,15.0)];
        cityInfoLbl.text = @"San Jose";
        [cityInfoLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]];
        cityInfoLbl.textColor = [UIColor whiteColor];
        cityInfoLbl.backgroundColor = [UIColor clearColor];
        
        
//        [secondCell.layer setBorderColor:[UIColor blackColor].CGColor];
//        [secondCell.layer setBorderWidth:0.5f];
        
        [cell addSubview:addressCell];
        [cell addSubview:addressLbl];
        [cell addSubview:cityInfoLbl];
        
    }else if(telephoneCellIndex == curCellIndex) {
        UIView *telephoneCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [telephoneCell setAlpha:1];
        [telephoneCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];

        UILabel *telephoneLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, cell.layer.frame.size.height - 40, 320.0, 50.0)];
        telephoneLbl.text = @"(408)605-4692";
        [telephoneLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]];
        telephoneLbl.textColor = [UIColor whiteColor];
        telephoneLbl.backgroundColor = [UIColor clearColor];
        
        [cell addSubview:telephoneCell];
        [cell addSubview:telephoneLbl];
        
    }else if(totalParticipantsCellIndex == curCellIndex){
        
        //Create a transparent layer on top of the cell as a background to the elements on top of it.
        //This is required because otherwise the alpha set on this element affects its child elements.
        UIView *transparentTotalParticipantCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [transparentTotalParticipantCell setAlpha:0.6];
        [transparentTotalParticipantCell setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
        transparentTotalParticipantCell.layer.shadowColor = [UIColor blackColor].CGColor;
        transparentTotalParticipantCell.layer.shadowOpacity = 0.5;
        transparentTotalParticipantCell.layer.shadowRadius = 3;
        transparentTotalParticipantCell.layer.shadowOffset = CGSizeMake(.6f, .6f);
        transparentTotalParticipantCell.layer.cornerRadius = 2;
        
        //Create an animated counter to display the number of participants.
        GICountingLabel *totalParticipantsLbl = [[GICountingLabel alloc] initWithFrame:CGRectMake((cell.frame.size.width/2 - 75.0), 0, 150, 100)];
        totalParticipantsLbl.format = @"%d";
        totalParticipantsLbl.method = UILabelCountingMethodLinear;
        [totalParticipantsLbl countFrom:0 to:100 withDuration:3.0f];
        [totalParticipantsLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:60.0]];
        totalParticipantsLbl.textColor = [UIColor whiteColor];
        totalParticipantsLbl.backgroundColor = [UIColor clearColor];
        totalParticipantsLbl.textAlignment = NSTextAlignmentCenter;
        
        UILabel *ttlPartLbl = [[UILabel alloc] initWithFrame:CGRectMake(cell.layer.frame.size.width/2-160, cell.layer.frame.size.height - 40, 320.0, 50.0)];
        ttlPartLbl.text = @"Participating";
        [ttlPartLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0]];
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
        cellTransparentView.layer.cornerRadius = 2;
        
        
        float progressBarThickness = 40.0f;
        
        UILabel *endDateLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, progressBarThickness + 15, 320.0,15.0)];
        endDateLbl.text = @"Winner Announced July 22, 2013";
        [endDateLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]];
        endDateLbl.textColor = [UIColor whiteColor];
        endDateLbl.backgroundColor = [UIColor clearColor];
        
        //Progress bar elements for participation rate and the duration of the contest.

        CGRect timeDurationBarRect = CGRectMake(0, 10, 0, progressBarThickness);
        
        //Set the color of the progress bars.
        self.timeDurationBar = [[GIProgressBar alloc] initWithFrame:timeDurationBarRect hexStringColor:@"3EFF29"];
        
        //Add the child elements to the cell.
        [cell addSubview:cellTransparentView];
        [cell addSubview:self.timeDurationBar];
        [cell addSubview:endDateLbl];

        //Animate the progress bars to juic-ify this app!
        [UIView animateWithDuration:1 animations:^{
        
            self.timeDurationBar.frame = CGRectMake(0, 10, 50, progressBarThickness);
            
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
        transparentEngCell.layer.cornerRadius = 2;
        
        UILabel *participationLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 320.0,15.0)];
        participationLbl.text = @"Your Participation";
        [participationLbl setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0]];
        participationLbl.textColor = [UIColor whiteColor];
        participationLbl.backgroundColor = [UIColor clearColor];
        
        //Progress bar elements for participation rate and the duration of the contest.
        float progressBarThickness = 40.0f;
        CGRect participationBarRect = CGRectMake(0, 20, 0, progressBarThickness);
        self.participationBar = [[GIProgressBar alloc] initWithFrame:participationBarRect hexStringColor:@"ffffff"];
        
        [cell addSubview:transparentEngCell];
        [cell addSubview:self.participationBar];
        [cell addSubview:participationLbl];
        
        //Animate the progress bars to juic-ify this app!
        [UIView animateWithDuration:1 animations:^{
            
            self.participationBar.frame = CGRectMake(0, 20, 150, progressBarThickness);
            
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
    }
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
    if(indexPath.row == 2) {
        [self moreInfoCellHandler];
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        self.currentSelectedCell = [self.tableView cellForRowAtIndexPath:path];
        
        // This is where magic happens...
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

- (void)moreInfoCellHandler {
    NSLog(@"more info button clicked");
    NSInteger animatedCellIndex = 1;
    NSMutableArray *indexPathsArray = [[NSMutableArray alloc] init];
    NSNumber *number = [NSNumber numberWithInt:animatedCellIndex];
    [indexPathsArray addObject:number];
    
    [self.tableView reloadRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
    [UIView animateWithDuration:0.3 animations:^{
        self.currentSelectedCell.frame = CGRectMake(0.0, 0.0, self.currentSelectedCell.layer.frame.size.width, 400.0f);

    } completion:^(BOOL finished) {
        NSLog(@"Expansion complete");
    }];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
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
