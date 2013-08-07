//
//  GIFulfillmentViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/25/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIFulfillmentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>

@interface GIFulfillmentViewController ()
{
    UITextView *sharingTextView;
}
@property (nonatomic, strong) UIButton *participationBtn;
@end

@implementation GIFulfillmentViewController
@synthesize participationBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[self colorWithHexString:@"C63D0F"]];

    self.participationBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - (200/2), self.view.frame.origin.y, 200.0f, 50.0f)];
    [self.participationBtn setTitle:@"Post To Facebook" forState:UIControlStateNormal];
    [self.participationBtn setBackgroundColor:[self colorWithHexString:@"3B5998"]];
    
    [self.participationBtn addTarget:self
                              action:@selector(participationBtnHandler)
                    forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.participationBtn];
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
