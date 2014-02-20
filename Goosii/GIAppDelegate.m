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
@synthesize reach = _reach;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Set up API environment variables.
    NSObject *goosiiAPI __unused = [[GIGlobalVariables alloc] init];
    NSLog(@"THE CURRENT API REQUEST %@", GOOSIIAPI);
    [NewRelicAgent startWithApplicationToken:NEW_RELIC_TOKEN];
    
    GIPlist *plist = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    //If user had used GIPlist in the past to store userId get the alphanumeric id and set it in NSUserDefaults.
    if([plist objectForKey:@"userId"] != NULL) {
        NSString * plistUserId = [plist objectForKey:@"userId"];
        [[NSUserDefaults standardUserDefaults]setObject:plistUserId forKey:@"userId"];
    }
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    
    NSLog(@"The user's id %@", userId);
    if(!userId) {
        
        UIView *loadingMask = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 568.0f)];
        [loadingMask setBackgroundColor:[UIColor blackColor]];
        [loadingMask setAlpha:0.5f];
        [self.window addSubview:loadingMask];
        
        //Create http request string
        NSString *urlPost = [NSString stringWithFormat:@"%@getUserUniqueId", GOOSIIAPI];
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
                
                [[NSUserDefaults standardUserDefaults]setObject:newStr forKey:@"userId"];
                
                //Set the user's ID for flurry to track.
                [Flurry setUserID:newStr];
            }
            
        } else {
            //TODO rebound if there is no userID
        }
    }

    //Set testflight device token.
    [TestFlight takeOff:@"bc01fdd6-8f88-4d53-927a-43a17ff87eee"];
    
    //Flurry analytics
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"TG9C2BZ4V4KX78GXYD4K"];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
	NSLog(@"My token is: %@", deviceToken);
    
    GIPlist *loginName = [[GIPlist alloc] initWithNamespace:@"Goosii"];
    
    NSString* deviceTokenStr = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];

    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [loginName setObject:deviceToken forKey:@"userDevicePushToken"];
    [Flurry setPushToken:deviceTokenStr];
    
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    if (accountStore == nil) {
        accountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType * facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
    
    ACAccount *fbAccount = [accounts lastObject];
    
    NSLog(@"===== username %@", fbAccount.userFullName);
    
    NSString *usersFullName;
    
    if(fbAccount.userFullName == nil) {
        usersFullName = @"None";
    } else {
        usersFullName = [fbAccount.userFullName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    }
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]) {
        
        NSString *uniqueId = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
        
        NSString *filterStr = [uniqueId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *urlPost = [NSString stringWithFormat:@"%@setUserNameAndDeviceToken/%@/%@/%@", GOOSIIAPI, filterStr, deviceTokenStr, usersFullName];
        
        NSURL *url = [NSURL URLWithString:urlPost];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if(!error) {
                                       NSLog(@"loginUser response %@", response);
                                       NSString* loginResponseData = [[NSString alloc] initWithData:data
                                                                                      encoding:NSUTF8StringEncoding];
                                       
                                       NSLog(@"LoginUser data %@", loginResponseData);                                       
                                   } else {
                                       NSLog(@"Error logging in user");
                                   }
                               }
         ];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
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
    
    //Create and store the users unique identifier
    
    if(![[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]) {
        
        UIView *loadingMask = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 568.0f)];
        [loadingMask setBackgroundColor:[UIColor blackColor]];
        [loadingMask setAlpha:0.5f];
        [self.window addSubview:loadingMask];
        //Create http request string
        NSString *urlPost = [NSString stringWithFormat:@"%@getUserUniqueId", GOOSIIAPI];
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
                [[NSUserDefaults standardUserDefaults]setObject:newStr forKey:@"userId"];
                
                //Set the user's ID for flurry to track.
                [Flurry setUserID:newStr];
                
            }
            
        } else {
            //TODO Figure out how to rebound here.
        }
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
