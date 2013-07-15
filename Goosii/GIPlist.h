//
//  GIPList.h
//  ApplicationLoader
//
//  Created by Steve Johnson on 9/28/11.
//  Copyright (c) 2011 Viralogy, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIPlist : NSObject {
    NSString *plistPath;
    NSMutableDictionary* plistDict;
}


-(id)initWithNamespace:(NSString*)theNamespace;
-(id)objectForKey:(NSString*)key;
-(void)setObject:(id)object forKey:(NSString*)key;
-(NSDictionary*)dictionary;

@end
