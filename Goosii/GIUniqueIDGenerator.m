//
//  GIUniqueIDGenerator.m
//  Goosii
//
//  Created by Justin Warmkessel on 1/7/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "GIUniqueIDGenerator.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "GIPlist.h"
#import <Flurry.h>

@implementation GIUniqueIDGenerator

- (void)connectAndGenerateUniqueId {
    NSLog(@"Checking the reachability change.");
    
    
    // Initialize the account store
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    if (accountStore == nil) {
        accountStore = [[ACAccountStore alloc] init];
    }
    
    //Check if wifi is reachable.

    NSLog(@"REACHABLE!");
    
    //If reachable and there isn't a company id than call the server to create one.
    GIPlist *loginName = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    NSString *userIdString;
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]) {
        userIdString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
        NSLog(@"THe string length %lu", (unsigned long)userIdString.length);
    }
    
    if(![[NSUserDefaults standardUserDefaults] stringForKey:@"userId"] || userIdString.length != 24) {
        
        NSLog(@"User Id SHOULD BE NIL");
        // do something only for logged in fb users} else {//do something else for non-fb users}
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            NSLog(@"I'm totally logged in");
            //App id: 474606345992201
            //Secret key: 6cf03ae9cb0976ec0736557edbe14544
            
            
            
            ACAccountType * facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            
            NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"474606345992201", ACFacebookAppIdKey,
                                     [NSArray arrayWithObject:@"email"], ACFacebookPermissionsKey,
                                     ACFacebookAudienceKey, ACFacebookAudienceEveryone,
                                     nil];
            
            [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    NSLog(@"Success");
                    NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                    
                    ACAccount *fbAccount = [accounts lastObject];
                    
                    NSLog(@"===== username %@", fbAccount.userFullName);
                    
                    NSUUID *uid = [UIDevice currentDevice].identifierForVendor;
                    
                    NSLog(@"IdentifierForVendor %@ STOP",[uid UUIDString]);
                    
                    NSString* escapedUrlString = [fbAccount.userFullName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                    NSString *urlPost = [NSString stringWithFormat:@"%@createUser/%@/%@/%@", GOOSIIAPI, [uid UUIDString], @"empty", escapedUrlString];
                    
                    NSLog(@"Create User urlstring %@", urlPost);
                    
                    NSURL *url = [NSURL URLWithString:urlPost];
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    [NSURLConnection sendAsynchronousRequest:urlRequest
                                                       queue:[NSOperationQueue mainQueue]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                               
                                               // your data or an error will be ready here
                                               NSString* newStr = [[NSString alloc] initWithData:data
                                                                                        encoding:NSUTF8StringEncoding];
                                               
                                               NSLog(@"ReceivedData %@", newStr);
                                               newStr = [newStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                               
                                               if(![newStr isEqualToString:@""]) {
                                                   [[NSUserDefaults standardUserDefaults]setObject:newStr forKey:@"userId"];
                                                   
                                                   [loginName setObject:@"empty" forKey:@"userDevicePushToken"];
                                                   
                                                   //Set the user's ID for flurry to track.
                                                   [Flurry setUserID:newStr];
                                                   [Flurry setPushToken:@"empty"];
                                               }
                                               
                                           }];
                    
                    
                } else {
                    NSLog(@"ERR: %@",error);
                    // Fail gracefully...
                }
            }
             ];
        }else {
            NSLog(@"I'm totally NOT logged in");
            
            NSUUID *uid = [UIDevice currentDevice].identifierForVendor;
            
            NSLog(@"IdentifierForVendor %@ STOP",[uid UUIDString]);
            NSString *urlPost = [NSString stringWithFormat:@"%@createUser/%@/%@", GOOSIIAPI, [uid UUIDString], @"empty"];
            
            NSURL *url = [NSURL URLWithString:urlPost];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       
                                       // your data or an error will be ready here
                                       NSString* newStr = [[NSString alloc] initWithData:data
                                                                                encoding:NSUTF8StringEncoding];
                                       
                                       NSLog(@"ReceivedData %@", newStr);
                                       newStr = [newStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                       
                                       
                                       if(![newStr isEqualToString:@""]) {
                                           [[NSUserDefaults standardUserDefaults]setObject:newStr forKey:@"userId"];
                                           [loginName setObject:@"empty" forKey:@"userDevicePushToken"];
                                           
                                           //Set the user's ID for flurry to track.
                                           [Flurry setUserID:newStr];
                                           [Flurry setPushToken:@"empty"];
                                       }
                                   }];
        }
    }

}


@end
