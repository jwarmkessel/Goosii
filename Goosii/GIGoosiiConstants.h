//
//  GIGoosiiConstants.h
//  Goosii
//
//  Created by Justin Warmkessel on 9/13/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIGoosiiConstants : NSObject

/******************************
By changing the environment flag you can change which API environment you want to use. Set to: 

SANDBOX | PRODUCTION | DEMO
*/
#define kENVIRONMENT_FLAG @"SANDBOX"

/******************************/

#define kBASE_URL @"http://www.Goosii.com"

#define kSANDBOX_PORT @"3001"
#define kDEMO_PORT @"3007"
#define kPRODUCTION_PORT @"3005"

@end
