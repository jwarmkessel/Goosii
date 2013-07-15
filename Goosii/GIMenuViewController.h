//
//  GIMenuViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ECSlidingViewController.h>
#import "GIActivityViewController.h"

@interface GIMenuViewController : UITableViewController

@property (strong, nonatomic) IBOutletCollection(UITableView) NSArray *menu;

@end
