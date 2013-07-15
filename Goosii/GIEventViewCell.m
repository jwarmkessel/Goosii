//
//  GIEventViewCell.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/12/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIEventViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation GIEventViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x = 10;
    frame.size.width -= 2 * 10;
    [super setFrame:frame];
    
    self.backgroundColor = [UIColor clearColor];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
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

//Possible solution for rotations
//- (void)setFrame:(CGRect)frame {
//    
//    if (self.superview){
//        float cellWidth = 500.0;
//        frame.origin.x = (self.superview.frame.size.width - cellWidth) / 2;
//        frame.size.width = cellWidth;
//    }
//    
//    [super setFrame:frame];
//}
@end
