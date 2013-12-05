//
//  GIEventBoardViewController.h
//  Goosii
//
//  Created by Justin Warmkessel on 7/12/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class GICompany;
@class GIProgressBar;

@interface GIEventBoardViewController : UITableViewController <MKMapViewDelegate, UITextViewDelegate, UITextFieldDelegate> {
    BOOL isEvent;
}
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) GICompany * company;

@property (nonatomic, strong) NSTimer *blinkTimer;
@property (nonatomic, strong) UILabel *fbPartLbl;
@property (assign) BOOL toggle;
@property (nonatomic, strong) UIButton* infoBtn;
@property (nonatomic, strong) GIProgressBar *participationBar;

- (void)showNoEventsPopUp:(NSString*)newsURL;
@end
