//
//  CCAlertController.h
//  Car-Connect
//
//  Created by Matthew Dutton on 6/9/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCAlertController : UIAlertController

+ (void)showOkAlertWithTitle:(NSString *)title
                  andMessage:(NSString *)message
            onViewController:(UIViewController*)viewController
               withTapAction:(void (^)(UIAlertAction*))tapAction;

+ (void)showOkCancelAlertWithTitle:(NSString *)title
                        andMessage:(NSString *)message
                  onViewController:(UIViewController*)viewController
                       okTapAction:(void (^)(UIAlertAction*))okTapAction
                   cancelTapAction:(void (^)(UIAlertAction*))cancelTapAction;

@end
