//
//  GICompanyCheckinCell.m
//  Goosii
//
//  Created by Justin Warmkessel on 1/3/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "GICompanyCheckinCell.h"

@implementation GICompanyCheckinCell
@synthesize nameLabel, reuseID, mainLabel, distancelbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        reuseID = reuseIdentifier;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 255.0f, 50.0f)];
//        [nameLabel setTextColor:[UIColor blackColor]];
//        [nameLabel setBackgroundColor:[UIColor colorWithHue:32 saturation:100 brightness:63 alpha:1]];
        [nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
//        [nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:nameLabel];

        distancelbl = [[UILabel alloc] initWithFrame:CGRectMake(255.0f, 0.0f, 75.0f, 50.0f)];
        //        [nameLabel setTextColor:[UIColor blackColor]];
        //        [nameLabel setBackgroundColor:[UIColor colorWithHue:32 saturation:100 brightness:63 alpha:1]];
        [distancelbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
        //        [nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:distancelbl];
        
        mainLabel = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 51.0f, 320.0f, 148.0f)];
        
        [self.contentView addSubview:mainLabel];
        
//        NSDictionary *views = NSDictionaryOfVariableBindings(nameLabel, mainLabel);
//        if (reuseID == kCellIDTitle) {
//            NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nameLabel]|"
//                                                                           options: 0
//                                                                           metrics:nil
//                                                                             views:views];
//            [self.contentView addConstraints:constraints];
//            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nameLabel]|"
//                                                                  options: 0
//                                                                  metrics:nil
//                                                                    views:views];
//            [self.contentView addConstraints:constraints];
//        }
//        if (reuseID == kCellIDTitleMain) {
//            NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[nameLabel]|"
//                                                                           options:0
//                                                                           metrics:nil
//                                                                             views:views];
//            [self.contentView addConstraints:constraints];
//            
//            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainLabel]|"
//                                                                  options: 0
//                                                                  metrics:nil
//                                                                    views:views];
//            [self.contentView addConstraints:constraints];
//            
//            constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nameLabel][mainLabel(==nameLabel)]|"
//                                                                  options: 0
//                                                                  metrics:nil
//                                                                    views:views];
//            [self.contentView addConstraints:constraints];
//            
//        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
