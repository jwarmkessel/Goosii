//
//  GIMainViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIMainViewController.h"
#import <ECSlidingViewController.h>
#import "GIMenuViewController.h"

@interface GIMainViewController ()
@property (strong, nonatomic) IBOutlet UILabel *testLabel;
-(UIColor*)colorWithHexString:(NSString*)hex;
@end

@implementation GIMainViewController

@synthesize scrollView1, pageControl;

const CGFloat kScrollObjHeight	= 199.0;
const CGFloat kScrollObjWidth	= 280.0;
const NSUInteger kNumImages		= 3;
BOOL pageControlUsed;

- (void)layoutScrollImages
{
	UIImageView *view = nil;
	NSArray *subviews = [scrollView1 subviews];
    
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += (kScrollObjWidth);
		}
	}
	
	// set the content size so it can be scrollable
	[scrollView1 setContentSize:CGSizeMake((kNumImages * kScrollObjWidth), [scrollView1 bounds].size.height)];
}


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
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    NSLog(@"Main Screen Width %f and screen Height %f", rect.size.width, rect.size.height);
    //View configurations.
    self.tableView.scrollEnabled = NO;
    self.navigationController.navigationBarHidden = YES;
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    //Sliding menu code.
    if(![self.slidingViewController.underLeftViewController isKindOfClass:[GIMenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    // 1. setup the scrollview for multiple images and add it to the view controller
	//
	// note: the following can be done in Interface Builder, but we show this in code for clarity
    
    CGRect tutorialRect = CGRectMake(0.0f, 0.0f, 320.0, 300.0f);
    scrollView1 = [[UIScrollView alloc] initWithFrame:tutorialRect];
	[scrollView1 setBackgroundColor:[UIColor blackColor]];
	[scrollView1 setCanCancelContentTouches:NO];
	scrollView1.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView1.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	scrollView1.scrollEnabled = YES;
    [scrollView1 setDelegate:self];
    
    CGRect pageControlRect = CGRectMake(0.0f, tutorialRect.size.height - 100.0f, 320.0, 100.0f);
    pageControl = [[UIPageControl alloc] initWithFrame:pageControlRect];
    pageControl.numberOfPages = kNumImages;
    pageControl.currentPage = 0;

	// pagingEnabled property default is NO, if set the scroller will stop or snap at each photo
	// if you want free-flowing scroll, don't set this property.
	scrollView1.pagingEnabled = YES;
	
	// load all the images from our bundle and add them to the scroll view
	NSUInteger i;
	for (i = 1; i <= kNumImages; i++)
	{
		NSString *imageName = [NSString stringWithFormat:@"image%d.jpg", i];
		UIImage *image = [UIImage imageNamed:imageName];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		
		// setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
		CGRect rect = imageView.frame;
		rect.size.height = kScrollObjHeight;
		rect.size.width = kScrollObjWidth;
		imageView.frame = rect;
		imageView.tag = i;	// tag our images for later use when we place them in serial fashion
		[scrollView1 addSubview:imageView];
	}
	
	[self layoutScrollImages];	// now place the photos in serial layout within the scrollview
    
    //[self.tableView addSubview:scrollView1];
    //[self.tableView addSubview:pageControl];

}

- (void) hideNavBar {
    NSLog(@"Hide the nav bar");
    self.navigationController.navigationBarHidden = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (pageControlUsed) {
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImageView *animation = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    animation.image = [UIImage imageNamed:@"Intro_00079.png"];
    [cell addSubview:animation];
    
    [self runLogoAnimation];
    
//    cell.backgroundColor = [self colorWithHexString:@"C63D0F"];
//    
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.bounds.size.width/2 - 100, 50, 200, 150)];
//    imgView.image = [UIImage imageNamed:@"TransparentGoosiiLogo.png"];
//    
//    [cell addSubview:imgView];
//    
//    CGRect playBtnFrame = CGRectMake(cell.bounds.size.width/2 - 100, 360, 200, 100);
//    
//    UIButton *playBtn = [[UIButton alloc] initWithFrame:playBtnFrame];
//    
//    [playBtn setImage:[UIImage imageNamed:@"playBtn.png"] forState:UIControlStateNormal];
//    [playBtn addTarget:self action:@selector(checkinHandler) forControlEvents:UIControlEventTouchUpInside];
//    
//    [cell addSubview:playBtn];
}

- (void)runLogoAnimation {
    
    UIImageView *animation = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSMutableArray *animationArray = [[NSMutableArray alloc] init];
    
    int i = 1;
    while(i <= 80) {
        NSString *animationFileNameStr;
        
        if(i<10) {
            animationFileNameStr = [NSString stringWithFormat:@"Intro_0000%d.png", i];
            //NSLog(@"File names %@", animationFileNameStr);
        } else {
            animationFileNameStr = [NSString stringWithFormat:@"Intro_000%d.png", i];
            //NSLog(@"File names %@", animationFileNameStr);
        }
        
        UIImage *image = (UIImage*)[UIImage imageNamed:animationFileNameStr];
        [animationArray  addObject:image];
        
        i++;
    }
    
    animation.animationImages = animationArray;
    
    [self.tableView addSubview:animation];
    animation.animationDuration = 3;
    animation.animationRepeatCount = 1;
    [animation startAnimating];
}

- (void)checkinHandler {
    [self performSegueWithIdentifier:@"checkinDisplaySegue" sender:self];
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

- (void)viewDidUnload {
    [self setTestLabel:nil];
    [super viewDidUnload];
}
@end
