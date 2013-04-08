//
//  AppDelegate.m
//  LogInAndSignUpDemo
//
//  Created by Mattieu Gamache-Asselin on 6/14/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoTableViewController.h"
#import "ToDoViewController.h"
#import <Parse/Parse.h>

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // ****************************************************************************
    // Fill in with your Parse, Facebook and Twitter credentials:
    // ****************************************************************************
    
    [Parse setApplicationId:@"ZCpXdCkYwcCLW5gXFxKPQMUQOtkYAAbd7iC51Sef" clientKey:@"aj5vrj3ts6s3v2DNPrKoDZq2YMUBWcroBMaEc053"];
    [PFFacebookUtils initializeWithApplicationId:@"452158354863401"];
    [PFTwitterUtils initializeWithConsumerKey:@"7EoGFbE7fLqxsxMe8I1ZCg" consumerSecret:@"tLEEVBZ4dAoMKkPwP8Nu0uCBPpZxTL9hbzl5nDEQLE"];
    
    // Set defualt ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    

    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ToDoViewController sharedInstance]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

// Facebook oauth callback
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
} 
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    
}
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"active app");
        [[ToDoViewController sharedInstance] refreshing];
    }
    else {
    
    }

}
@end
