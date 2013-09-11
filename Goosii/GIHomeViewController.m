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
    
    self.animationImgView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.animationImgView.image = [UIImage imageNamed:@"Intro_0078.png"];
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
        float duration = 10/80;
        NSLog(@"Start animation %f", duration);

        [UIView animateWithDuration: duration
                    animations: ^{
                        
                        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"Intro_000%d.png", state]];
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
    
    int i = 52;
    while(i <= 80) {
        NSString *animationFileNameStr;
        
        animationFileNameStr = [NSString stringWithFormat:@"Intro_00%d.png", i];
        //NSLog(@"File names %@", animationFileNameStr);

        
        UIImage *image = (UIImage*)[UIImage imageNamed:animationFileNameStr];
        if(image != nil) {
            [animationArray  addObject:image];
        }
        
        i++;
    }
    
    NSLog(@"Populated array count %lu", (unsigned long)[animationArray count]);
    self.animationImgView.animationImages = animationArray;
    
    self.animationImgView.animationDuration = 1;
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

@end