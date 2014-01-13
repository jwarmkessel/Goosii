//
//  GIAppDelegate.m
//  Goosii
//
//  Created by Justin Warmkessel on 7/2/13.
//  Copyright (c) 2013 Justin Warmkessel. All rights reserved.
//

#import "GIAppDelegate.h"
#import "GIPlist.h"
#import "TestFlight.h"
#import <Flurry.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Reachability.h>
#import "GIEventScrollViewController.h"
#import "GICheckinViewController.h"
#import <AFNetworkReachabilityManager.h>
#import <AFNetworking.h>
#import <AFHTTPRequestOperationManager.h>
#import "GIUniqueIDGenerator.h"

@implementation GIAppDelegate

@synthesize accountStore = _accountStore;
@synthesize fbAccount = _fbAccount;
@synthesize reachability = _reachability;
@synthesize manager = _manager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Set up API environment variables.
    NSObject *goosiiAPI __unused = [[GIGlobalVariables alloc] init];

    [NewRelicAgent startWithApplicationToken:NEW_RELIC_TOKEN];
    NSLog(@"The new relic token %@", NEW_RELIC_TOKEN);

    NSLog(@"THE CURRENT API REQUEST %@", GOOSIIAPI);
    
    //Start AFNetworking Reachability.
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:GOOSIIAPI]];
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSOperationQueue *operationQueue = self.manager.operationQueue;
    [self.manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                // we need to notify a delegete when internet conexion is lost.
                // [delegate internetConexionLost];
                NSLog(@"No Internet Conexion");
                break;
            {case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
//                GIUniqueIDGenerator *uniqueIDGenerator = [[GIUniqueIDGenerator alloc] init];
//                [uniqueIDGenerator connectAndGenerateUniqueId];
                
                break;}
            {case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
//                GIUniqueIDGenerator *uniqueIDGenerator = [[GIUniqueIDGenerator alloc] init];
//                [uniqueIDGenerator connectAndGenerateUniqueId];
                
                break;}
            default:
                NSLog(@"Unkown network status");
                [operationQueue setSuspended:YES];
                break;
        }
    }];
    
    //Set testflight device token.
    [TestFlight takeOff:@"bc01fdd6-8f88-4d53-927a-43a17ff87eee"];
    
    //Flurry analytics
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"TG9C2BZ4V4KX78GXYD4K"];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    

    [self.manager.reachabilityManager startMonitoring];
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    GIPlist *loginName = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    NSString* deviceTokenStr = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];

    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [loginName setObject:deviceToken forKey:@"userDevicePushToken"];
    
    if([loginName objectForKey:@"userId"]) {
        NSString *uniqueId = [loginName objectForKey:@"userId"];
        NSLog(@"The saved uniqueId %@", uniqueId);
        
        NSString *filterStr = [uniqueId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *urlPost = [NSString stringWithFormat:@"%@loginUser/%@/%@", GOOSIIAPI, filterStr, deviceTokenStr];
        
        NSURL *url = [NSURL URLWithString:urlPost];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        if(!connection) {
            NSLog(@"connection failed");
        }
    } else {
        
        // do something only for logged in fb users} else {//do something else for non-fb users}
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            NSLog(@"I'm totally logged in");
            //App id: 474606345992201
            //Secret key: 6cf03ae9cb0976ec0736557edbe14544
            
            // Initialize the account store
            self.accountStore = [[ACAccountStore alloc] init];
            
            if (self.accountStore == nil) {
                self.accountStore = [[ACAccountStore alloc] init];
            }
            
            ACAccountType * facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            
            NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     @"474606345992201", ACFacebookAppIdKey,
                                     [NSArray arrayWithObject:@"email"], ACFacebookPermissionsKey,
                                     ACFacebookAudienceKey, ACFacebookAudienceEveryone,
                                     nil];
            
            [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    NSLog(@"Success");
                    NSArray *accounts = [_accountStore accountsWithAccountType:facebookAccountType];
                    self.fbAccount = [accounts lastObject];
                    NSLog(@"===== username %@", self.fbAccount.userFullName);
                    
                    NSUUID *uid = [UIDevice currentDevice].identifierForVendor;
                    
                    NSLog(@"IdentifierForVendor %@ STOP",[uid UUIDString]);

                    NSString* escapedUrlString = [self.fbAccount.userFullName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                    NSString *urlPost = [NSString stringWithFormat:@"%@createUser/%@/%@/%@", GOOSIIAPI, [uid UUIDString], deviceTokenStr, escapedUrlString];
                    
                    NSLog(@"Create User urlstring %@", urlPost);
                    
                    NSURL *url = [NSURL URLWithString:urlPost];
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    
                    NSURLResponse* response = nil;
                    NSError *error = nil;
                    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

                    if(!error) {
                        // your data or an error will be ready here
                        NSString* newStr = [[NSString alloc] initWithData:data
                                                                 encoding:NSUTF8StringEncoding];
                        
                        NSLog(@"ReceivedData %@", newStr);
                        newStr = [newStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        
                        if(![newStr isEqualToString:@""]) {
                            [loginName setObject:newStr forKey:@"userId"];
                            [loginName setObject:deviceTokenStr forKey:@"userDevicePushToken"];
                            
                            //Set the user's ID for flurry to track.
                            [Flurry setUserID:newStr];
                            [Flurry setPushToken:deviceTokenStr];
                        }
                        
                        if(error) {
                            [self.manager.reachabilityManager startMonitoring];
                        }
                    }
                } else {
                    
                    NSLog(@"ERR: %@",error);
                    // Fail gracefully...
                    NSLog(@"I'm totally NOT given access to facebook so just do a regular create user");
                    
                    NSUUID *uid = [UIDevice currentDevice].identifierForVendor;
                    
                    NSLog(@"IdentifierForVendor %@ STOP",[uid UUIDString]);
                    NSString *urlPost = [NSString stringWithFormat:@"%@createUser/%@/%@", GOOSIIAPI, [uid UUIDString], deviceTokenStr];
                    
                    
                    NSURL *url = [NSURL URLWithString:urlPost];
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    
                    NSURLResponse* response = nil;
                    NSError *error = nil;
                    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                    
                    if(!error) {
                    
                        // your data or an error will be ready here
                        NSString* newStr = [[NSString alloc] initWithData:data
                                                                 encoding:NSUTF8StringEncoding];
                        
                        NSLog(@"ReceivedData %@", newStr);
                        newStr = [newStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        
                        if(![newStr isEqualToString:@""]) {
                            [loginName setObject:newStr forKey:@"userId"];
                            [loginName setObject:deviceTokenStr forKey:@"userDevicePushToken"];
                            
                            //Set the user's ID for flurry to track.
                            [Flurry setUserID:newStr];
                            [Flurry setPushToken:deviceTokenStr];
                        }
                    } else {
                        [self.manager.reachabilityManager startMonitoring];
                    }
                }
            }
             ];
        }else {
            NSLog(@"I'm totally NOT logged in");
            
            NSUUID *uid = [UIDevice currentDevice].identifierForVendor;
            
            NSLog(@"IdentifierForVendor %@ STOP",[uid UUIDString]);
            NSString *urlPost = [NSString stringWithFormat:@"%@createUser/%@/%@", GOOSIIAPI, [uid UUIDString], deviceTokenStr];
            
            NSURL *url = [NSURL URLWithString:urlPost];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            NSURLResponse* response = nil;
            NSError *error = nil;
            NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
            
            if(!error) {
                // your data or an error will be ready here
                NSString* newStr = [[NSString alloc] initWithData:data
                                                         encoding:NSUTF8StringEncoding];
                
                NSLog(@"ReceivedData %@", newStr);
                newStr = [newStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                
                if(![newStr isEqualToString:@""]) {
                    [loginName setObject:newStr forKey:@"userId"];
                    [loginName setObject:deviceTokenStr forKey:@"userDevicePushToken"];
                    
                    //Set the user's ID for flurry to track.
                    [Flurry setUserID:newStr];
                    [Flurry setPushToken:deviceTokenStr];
                }
                
            } else {
                [self.manager.reachabilityManager startMonitoring];
            }
        }
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
    
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    if([plist objectForKey:@"userId"]) {
        NSString *uniqueId = [plist objectForKey:@"userId"];
        NSLog(@"The saved uniqueId %@", uniqueId);
        
        NSString *filterStr = [uniqueId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSString *urlPost = [NSString stringWithFormat:@"%@loginUser/%@/", GOOSIIAPI, filterStr];
        
        if([plist objectForKey:@"userDevicePushToken"]) {

            urlPost = [urlPost stringByAppendingString:[plist objectForKey:@"userDevicePushToken"]];
        } else {

            urlPost = [urlPost stringByAppendingString:@"empty"];
        }
        
        NSURL *url = [NSURL URLWithString:urlPost];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        if(!connection) {
            NSLog(@"connection failed");
        }
    } else {
        NSUUID *uid = [UIDevice currentDevice].identifierForVendor;
        
        NSLog(@"IdentifierForVendor %@",[uid UUIDString]);

        NSString *urlPost = [NSString stringWithFormat:@"%@createUser/%@/", GOOSIIAPI, [uid UUIDString]];
        urlPost = [urlPost stringByAppendingString:@"empty"];
        
        NSURL *url = [NSURL URLWithString:urlPost];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        NSURLResponse* response = nil;
        NSError *error = nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

        if(!error) {
            // your data or an error will be ready here
            NSString* newStr = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            
            NSLog(@"ReceivedData %@", newStr);
            //Set Flurry user's ID.
            [Flurry setUserID:newStr];
            
            newStr = [newStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            [plist setObject:newStr forKey:@"userId"];
            
        } else {
            [self.manager.reachabilityManager startMonitoring];
        }
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"alert msg - %@", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    NSLog(@"alert custom - %@", [[userInfo objectForKey:@"customParam"] objectForKey:@"foo"]);
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //If reachable and there isn't a company id than call the server to create one.
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    NSString *userIdString;
    
    if([plist objectForKey:@"userId"]) {
        userIdString = [plist objectForKey:@"userId"];
        NSLog(@"THe string length %lu", (unsigned long)userIdString.length);
    }
    
    if(![plist objectForKey:@"userId"] || userIdString.length != 24) {
    
        GIUniqueIDGenerator *uniqueIdGenerator = [[GIUniqueIDGenerator alloc] init];
        [uniqueIdGenerator connectAndGenerateUniqueId];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //Set the badge to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
