//
//  GIDashboardViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIDashboardViewController.h"
#import "GIProgressBar.h"

@interface GIDashboardViewController ()
@property (nonatomic, strong) GIProgressBar *totalParticipantsBar;
@property (nonatomic, strong) GIProgressBar *participationBar;
@property (nonatomic, strong) GIProgressBar *timeDurationBar;
- (IBAction)optOutHandler:(id)sender;
@property (strong, nonatomic) IBOutlet UISwitch *optOutSwitch;

@end

@implementation GIDashboardViewController
@synthesize company, totalParticipantsBar, participationBar, timeDurationBar;

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
    NSLog(@"The view did load");
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Fun counter example
    NSMutableArray *countingArray;
    int numbers = 1;
    NSString *str;
    while(numbers!=100) {
        str = [NSString stringWithFormat:@"%d", numbers]; //%d or %i both is ok.
        [countingArray addObject:str];
        numbers++;
    }
    
    UILabel *totalParticipantsLbl = [[UILabel alloc] init];
    totalParticipantsLbl.text = [countingArray objectAtIndex:0];
    
    NSInteger isInt = 0;
    NSInteger isCellPath = [indexPath row];
    
    NSLog(@"is cell path %ld", (long)isCellPath);
    
    if(isCellPath == isInt) {
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 200.0f, cell.frame.size.height);
        
        //Total Participants progress bar.
        CGRect totalParticipantsBarRect = CGRectMake(10, 100, 0, 40);
        CGRect participationBarRect = CGRectMake(10, 200, 0, 40);
        CGRect timeDurationBarRect = CGRectMake(10, 300, 0, 40);
        
        self.totalParticipantsBar = [[GIProgressBar alloc] initWithFrame:totalParticipantsBarRect hexStringColor:@"31F700"];
        self.participationBar = [[GIProgressBar alloc] initWithFrame:participationBarRect hexStringColor:@"BD1A1A"];
        self.timeDurationBar = [[GIProgressBar alloc] initWithFrame:timeDurationBarRect hexStringColor:@"008CFF"];

        [cell addSubview:self.totalParticipantsBar];
        [cell addSubview:self.participationBar];
        [cell addSubview:self.timeDurationBar];
        
        [UIView animateWithDuration:1 animations:^{
            self.totalParticipantsBar.frame = CGRectMake(10, 100, 100, 40);
            self.participationBar.frame = CGRectMake(10, 200, 300, 40);
            self.timeDurationBar.frame = CGRectMake(10, 300, 50, 40);
            
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
        
    }
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.bounds.size.width/2 - 100, 50, 200, 150)];
//    imgView.image = [UIImage imageNamed:@"TransparentGoosiiLogo.png"];
//    
//    [cell addSubview:imgView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 0;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

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
}

- (IBAction)optOutHandler:(id)sender {
    
    if([self.optOutSwitch isOn]) {
        
        [UIView animateWithDuration:1 animations:^{
            self.totalParticipantsBar.frame = CGRectMake(10, 100, 100, 40);
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
        
        [UIView animateWithDuration:1 animations:^{
            self.participationBar.frame = CGRectMake(10, 200, 300, 40);
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
        
        [UIView animateWithDuration:1 animations:^{
            self.timeDurationBar.frame = CGRectMake(10, 300, 50, 40);
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.totalParticipantsBar.frame = CGRectMake(10, 100, 0, 40);
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
        
        [UIView animateWithDuration:1 animations:^{
            self.participationBar.frame = CGRectMake(10, 200, 0, 40);
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
        
        [UIView animateWithDuration:1 animations:^{
            self.timeDurationBar.frame = CGRectMake(10, 300, 0, 40);
        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
