//
//  GIHomeViewController.m
//  Goosii
//
//  Created by Justin Warmkessel on 8/7/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIHomeViewController.h"
#import <ECSlidingViewController.h>

@interface GIHomeViewController ()
@property (nonatomic, strong) UIImageView *animationImgView;
@end

@implementation GIHomeViewController
@synthesize animationImgView, slidingMenuButton;

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
    
    self.animationImgView = [[UIImageView alloc] initWithFrame:CGRectMake(74, 100, 172, 117)];
    self.animationImgView.image = [UIImage imageNamed:@"BrokenEggAnim_017.png"];
    [self.view addSubview:self.animationImgView];
    
    /* This animate command is a recursive execution of animation block. Unusable */
    //[self animate:self.view withState:10 andLastState:80];
    
    [self runLogoAnimation];

    UITapGestureRecognizer *enterTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(enterTapHandler:)];
    [self.view addGestureRecognizer:enterTapGesture];
    
    self.slidingMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    slidingMenuButton.frame = CGRectMake(8, 10, 34, 24);
    [slidingMenuButton setBackgroundImage:[UIImage imageNamed:@"Slide.png"] forState:UIControlStateNormal];
    [slidingMenuButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.slidingMenuButton];
    
    [self.view setBackgroundColor:[self colorWithHexString:@"C63D0F"]];
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
    NSLog(@"Start animation");
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
