//
//  AppDelegate.h
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate>
{
    NSString* selectedTabBar;
}


@property (strong, nonatomic) UIWindow *window;



@end
