//
//  GIProgressBar.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/11/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIProgressBar.h"
#import <QuartzCore/QuartzCore.h>

@interface GIProgressBar ()
@property (strong, nonatomic) NSString * hexColor;
@end

@implementation GIProgressBar
@synthesize hexColor = _hexColor;

- (id)initWithFrame:(CGRect)frame hexStringColor:(NSString *)hexColor
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _hexColor = hexColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIColor *fillColor = [self colorWithHexString:self.hexColor];
    UIColor *strokeColor = [self colorWithHexString:@"000000"];
    //UIColor *fillColor = [UIColor colorWithRed:0.526 green:0.525 blue:0.526 alpha:1];
    //UIColor *strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 310, 50) cornerRadius:1];

    [fillColor setFill];
    [roundedRectanglePath fill];
    [strokeColor setStroke];
    roundedRectanglePath.lineWidth = 1;
    [roundedRectanglePath stroke];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 1;
    self.layer.shadowOffset = CGSizeMake(.6f, 1);
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

@end
