//
//  GICompanyCheckinCell.h
//  Goosii
//
//  Created by Justin Warmkessel on 1/3/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GICompanyCheckinCell : UITableViewCell

@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)NSString *reuseID;
@property (nonatomic, strong)UIImageView *mainLabel;
@property (nonatomic, strong)UILabel *distancelbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
