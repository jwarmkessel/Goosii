//
//  GIPlist.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/10/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIPlist.h"

@implementation GIPlist

-(id)initWithNamespace:(NSString*)theNamespace {
 	if((self = [super init])) {
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        plistPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", theNamespace]];
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        if(!plistDict) {
            plistDict = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

-(id)objectForKey:(NSString*)key {
    return [plistDict objectForKey:key];
}

-(NSDictionary*)dictionary {
    return plistDict;
}

-(void)setObject:(id)object forKey:(NSString*)key {
    if(object != nil) {
        [plistDict setValue:object forKey:key];
    }else {
        [plistDict removeObjectForKey:key];
    }
    if(![plistDict writeToFile:plistPath atomically: YES]) {
        NSLog(@"FAILED TO STORE PLISTDICT - %@", plistPath);
        return;
    }
}

@end
