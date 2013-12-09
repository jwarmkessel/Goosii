//
//  GINoEventsNearby.m
//  Goosii
//
//  Created by Justin Warmkessel on 12/8/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GINoEventsNearby.h"
#import <QuartzCore/QuartzCore.h>

@interface GINoEventsNearby ()
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation GINoEventsNearby

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
//        CAGradientLayer *gradient = [CAGradientLayer layer];
//        gradient.frame = self.view.bounds;
//        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
//        [self.view.layer insertSublayer:gradient atIndex:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GINoEventsNearbyBackgroundGradient.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
