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

@implementation GIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Set up API environment variables.
    NSObject *goosiiAPI __unused = [[GIGlobalVariables alloc] init];


    NSLog(@"THE CURRENT API REQUEST %@", GOOSIIAPI);

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
        NSUUID *uid = [UIDevice currentDevice].identifierForVendor;
        
        NSLog(@"IdentifierForVendor %@ STOP",[uid UUIDString]);
        NSString *urlPost = [NSString stringWithFormat:@"%@createUser/%@/%@", GOOSIIAPI, [uid UUIDString], deviceTokenStr];
                
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
                                   
                                   //Set the user's ID for flurry to track.
                                   [Flurry setUserID:newStr];
                                   [Flurry setPushToken:deviceTokenStr];
                                   
                                   [loginName setObject:newStr forKey:@"userId"];
                                   [loginName setObject:deviceTokenStr forKey:@"userDevicePushToken"];
                               }];
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
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   // your data or an error will be ready here
                                   NSString* newStr = [[NSString alloc] initWithData:data
                                                                            encoding:NSUTF8StringEncoding];
                                   
                                   NSLog(@"ReceivedData %@", newStr);
                                   //Set Flurry user's ID.
                                  [Flurry setUserID:newStr];
                                   
                                   newStr = [newStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                   [plist setObject:newStr forKey:@"userId"];
                               }];
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
