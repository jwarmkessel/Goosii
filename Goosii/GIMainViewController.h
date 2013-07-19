//
//  GIMainViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIMainViewController : UITableViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView1;	// holds five small images to scroll horizontally
    IBOutlet UIPageControl *pageControl;    
}

@property (nonatomic, retain) UIView *scrollView1;
@property (nonatomic, retain) UIPageControl *pageControl;
@end
