//
//  GIHomeViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 8/7/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIHomeViewController.h"
#import <ECSlidingViewController.h>
#import <CSAnimationView.h>

@interface GIHomeViewController ()
@property (nonatomic, strong) UIImageView *animationImgView;
@property (nonatomic, strong) CSAnimationView *goosiiLogoAnimationContainer;
@end

@implementation GIHomeViewController
@synthesize animationImgView, slidingMenuButton, goosiiLogoAnimationContainer;

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
    
    [self.navigationController.navigationBar setAlpha:0.0f];
    
    goosiiLogoAnimationContainer = [[CSAnimationView alloc] initWithFrame:CGRectMake(74, 100, 172, 117)];
    
    
    self.animationImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 172, 117)];
    self.animationImgView.image = [UIImage imageNamed:@"BrokenEggAnim_017.png"];

    
    goosiiLogoAnimationContainer.backgroundColor = [UIColor clearColor];
    [goosiiLogoAnimationContainer addSubview:self.animationImgView];
    [self.view addSubview:goosiiLogoAnimationContainer];
    
    goosiiLogoAnimationContainer.duration = 1;
    goosiiLogoAnimationContainer.delay    = 0;
    goosiiLogoAnimationContainer.type = CSAnimationTypeZoomOut;
    
    [goosiiLogoAnimationContainer startCanvasAnimation];
    
    [self runLogoAnimation];

    UITapGestureRecognizer *enterTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(enterTapHandler:)];
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
    
    CSAnimationView *enterBtnContainer = [[CSAnimationView alloc] initWithFrame:CGRectMake(20, 300, 280, 50)];
    
    UIButton *enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    enterBtn.frame = CGRectMake(0, 0, 280, 50);
    //[enterBtn setBackgroundColor:[self colorWithHexString:@"3b5999"]];
    [enterBtn addTarget:self action:@selector(enterBtn:) forControlEvents:UIControlEventTouchUpInside];
    [enterBtn setTitle:@"Tap anywhere to begin." forState:UIControlStateNormal];
    enterBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [enterBtn.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15.0f]];
    [enterBtn.titleLabel setTextColor:[UIColor whiteColor]];
    
    enterBtnContainer.backgroundColor = [UIColor clearColor];
    
    enterBtnContainer.duration = 1.5;
    enterBtnContainer.delay    = 0;
    enterBtnContainer.type = CSAnimationTypePop;
    
    [enterBtnContainer addSubview:enterBtn];
    [self.view addSubview:enterBtnContainer];
    
    [enterBtnContainer startCanvasAnimation];
    
    [self.view setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.slidingViewController.panGesture.enabled = YES;
    self.navigationController.navigationBarHidden = YES;
}

-(IBAction)enterBtn:(id)sender {
    [self performSegueWithIdentifier:@"checkinDisplaySegue" sender:self];       
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
    [self performSegueWithIdentifier:@"checkinDisplaySegue" sender:self];    
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

@end
