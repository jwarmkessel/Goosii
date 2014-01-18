//
//  GIHomeViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 8/7/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIHomeViewController.h"
#import <ECSlidingViewController.h>
#import <Social/Social.h>
#import "GIPlist.h"
#import <Flurry.h>

@interface GIHomeViewController ()
@property (nonatomic, strong) UIImageView *animationImgView;
@property (nonatomic, strong) UIButton *facebookBtn;
@property (nonatomic, strong) UITapGestureRecognizer *enterTapGesture;
@end

@implementation GIHomeViewController
@synthesize animationImgView, slidingMenuButton, facebookBtn, enterTapGesture;

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
    
    [self.navigationController.navigationBar setAlpha:0.0f];
    
    
    self.animationImgView = [[UIImageView alloc] initWithFrame:CGRectMake(74, 100, 172, 117)];
    self.animationImgView.image = [UIImage imageNamed:@"BrokenEggAnim_017.png"];
    
    [self.view addSubview:self.animationImgView];
    

    enterTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(enterTapHandler:)];
    
    enterTapGesture.enabled = YES;
    
    [self.view addGestureRecognizer:enterTapGesture];
    
    self.slidingMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        slidingMenuButton.frame = CGRectMake(8, 10, 38, 24);
    }else {
        slidingMenuButton.frame = CGRectMake(8, 30, 38, 24);
    }
    
    [slidingMenuButton setBackgroundImage:[UIImage imageNamed:@"Slide.png"] forState:UIControlStateNormal];
    [slidingMenuButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.slidingMenuButton];
    
    UIButton *enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    enterBtn.frame = CGRectMake(20, 300, 280, 50);
    //[enterBtn setBackgroundColor:[self colorWithHexString:@"3b5999"]];
    [enterBtn addTarget:self action:@selector(enterBtn:) forControlEvents:UIControlEventTouchUpInside];
    [enterBtn setTitle:@"Tap anywhere to begin." forState:UIControlStateNormal];
    enterBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [enterBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0f]];
    [enterBtn.titleLabel setTextColor:[UIColor whiteColor]];
    
    [self.view addSubview:enterBtn];

    [self.view setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
    
    [self runLogoAnimation];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.slidingViewController.panGesture.enabled = YES;
    self.navigationController.navigationBarHidden = YES;
}

-(IBAction)enterBtn:(id)sender {
    
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    NSLog(@"ENTER BTN CLICKED");
    if([plist objectForKey:@"userId"]) {
        [self performSegueWithIdentifier:@"checkinDisplaySegue" sender:self];
    } else {
        [self getUniqueUserId];
    }
}
-(IBAction)revealMenu:(id)sender {

    [self.slidingViewController anchorTopViewTo:ECRight animations:^{
        NSLog(@"Sliding");
    } onComplete:^{
        NSLog(@"complete");
    }];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:YES];
    
    [self hideNavBar];
}


- (void)enterTapHandler:(UITapGestureRecognizer *)recognizer {
    
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    NSLog(@"ENTER enterTapHandler CLICKED");
    if([plist objectForKey:@"userId"]) {
        [self performSegueWithIdentifier:@"checkinDisplaySegue" sender:self];
    } else {
        [self getUniqueUserId];
    }
}

-(void) animate:(UIView*) b withState: (int) state andLastState:(int) last_state {
    if (state < last_state) {
        float duration = 2;
        NSLog(@"Start animation %f", duration);

        [UIView animateWithDuration: duration
                    animations: ^{
                        
                        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"BrokenEggAnim_0%d.png", state]];
                        [self.animationImgView setImage:image];
                    }
                    completion:^(BOOL finished) {
                        [self animate:b withState:state+1 andLastState:last_state];
                        NSLog(@"Animation compltedddd");

                    }];
    }
}

- (void)runLogoAnimation {
    
    /*animation not working on device*/
    
    NSLog(@"Run intro animation");
    
    NSMutableArray *animationArray = [[NSMutableArray alloc] init];
    
    int i = 0;
    while(i <= 17) {
        NSString *animationFileNameStr;
        
        if(i < 10) {
            animationFileNameStr = [NSString stringWithFormat:@"BrokenEggAnim_00%d.png", i];
            //NSLog(@"File names %@", animationFileNameStr);
        } else {
            animationFileNameStr = [NSString stringWithFormat:@"BrokenEggAnim_0%d.png", i];
            //NSLog(@"File names %@", animationFileNameStr);
        }
        
        
        
        UIImage *image = (UIImage*)[UIImage imageNamed:animationFileNameStr];
        if(image != nil) {
            [animationArray  addObject:image];
        }
        
        i++;
    }
    
    NSLog(@"Populated array count %lu", (unsigned long)[animationArray count]);
    self.animationImgView.animationImages = animationArray;
    
    self.animationImgView.animationDuration = 2;
    self.animationImgView.animationRepeatCount = 1;
    NSLog(@"Starting animation now");
    [self.animationImgView startAnimating];
    
}



- (void) hideNavBar {
    NSLog(@"Hide the nav bar");
    [self.navigationController.navigationBar setAlpha:0.0f];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(BOOL)getUniqueUserId {
    
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    enterTapGesture.enabled = NO;
    //Start loading mask.
    UIView *loadingMask = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    loadingMask.backgroundColor = [UIColor blackColor];
    loadingMask.alpha = 0.5;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    [self.view addSubview:loadingMask];
    [self.view addSubview:indicator];
    
    [loadingMask setUserInteractionEnabled:NO];
    [indicator startAnimating];
    //Create http request string
    NSString *urlPost = [NSString stringWithFormat:@"%@getUserUniqueId", GOOSIIAPI];
    NSLog(@"Create User urlstring %@", urlPost);
    
    NSURL *url = [NSURL URLWithString:urlPost];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLResponse* response = nil;
    NSError *error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if(!error) {
        // your data or an error will be ready here
        NSString* newStr = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        
        NSLog(@"ReceivedData %@", newStr);
        newStr = [newStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        if(![newStr isEqualToString:@""]) {
            [plist setObject:newStr forKey:@"userId"];
            
            //Set the user's ID for flurry to track.
            [Flurry setUserID:newStr];
            
            [loadingMask removeFromSuperview];
            [indicator stopAnimating];
            enterTapGesture.enabled = YES;
            
            return YES;
        }
    }
    
    return NO;
}

@end
