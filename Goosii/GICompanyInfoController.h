//
//  GICompanyInfoController.h
//  Goosii
//
//  Created by Justin Warmkessel on 12/3/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GICompany;

@interface GICompanyInfoController : UIViewController
@property (nonatomic, strong) GICompany *company;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil company:(GICompany *)companyObj;
@end
