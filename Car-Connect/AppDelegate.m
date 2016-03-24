//
//  AppDelegate.m
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import "AppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "ParkMeterViewController.h"

@implementation AppDelegate
{

    BOOL showngoogleOptINOUT;
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    // has the google opt alert been shown? get it from the defaults
    showngoogleOptINOUT = [[NSUserDefaults standardUserDefaults]boolForKey:@"shownGoogleOpt"];
    NSLog(@"Has google opt Shown: %d",showngoogleOptINOUT);
    NSLog(@"Google Optout status: %d", [[GAI sharedInstance] optOut]);
    
    
    if (showngoogleOptINOUT == NO) {
        UIAlertView* googleOPT = [[UIAlertView alloc]initWithTitle:@"Google Analytics" message:@"With your permission usage information will be collected to improve the application" delegate:self cancelButtonTitle:@"Opt Out" otherButtonTitles:@"Opt In", nil];
        [googleOPT show];
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"shownGoogleOpt"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    // setting up the google analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].dispatchInterval = 20;
    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-50002356-1"];
    
    UITabBarController* tabBarController = (UITabBarController*)self.window.rootViewController;
    tabBarController.delegate = self;

    return YES;
}

// intercept the alert view button for the google opt status
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        // if Optout was pressed then opt out
        [[GAI sharedInstance] setOptOut:YES];
    
    } else {
        // if opt in was pressed then opt in
        [[GAI sharedInstance] setOptOut:NO];
    }
}

// when a different tab is selected:
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    // get the name of the selected tab's VC
    selectedTabBar = NSStringFromClass([viewController class]);
    
    // set all of the tracking information for the different VC's
    NSLog(@"********Selected View Controller: %@ ", selectedTabBar);
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    
    if ( [selectedTabBar isEqualToString:@"ParkCarViewController"] ) {
        
        [tracker set:kGAIScreenName value:@"Set Parking Screen"];
        [tracker send:[[GAIDictionaryBuilder createAppView]build]];
        
    } else if ([selectedTabBar isEqualToString:@"FindCarViewController"]){
        
        [tracker set:kGAIScreenName value:@"Find Car Screen"];
        [tracker send:[[GAIDictionaryBuilder createAppView]build]];
        
    } else if ([selectedTabBar isEqualToString:@"ParkMeterViewController"]) {

        
    }

    
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

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{

}

@end
