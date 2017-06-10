//
//  CCAlertController.m
//  Car-Connect
//
//  Created by Matthew Dutton on 6/9/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

#import "CCAlertController.h"

@interface CCAlertController ()

@end

@implementation CCAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (void)showOkAlertWithTitle:(NSString *)title
                  andMessage:(NSString *)message
            onViewController:(UIViewController*)viewController
               withTapAction:(void (^)(UIAlertAction*))tapAction {
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle: title
                                                                             message: message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok"
                                                       style: UIAlertActionStyleDefault
                                                     handler: tapAction];
    
    [alertController addAction: okAction];
    [viewController presentViewController: alertController animated:YES completion:nil];
    
}

+ (void)showOkCancelAlertWithTitle:(NSString *)title
                        andMessage:(NSString *)message
                  onViewController:(UIViewController*)viewController
                       okTapAction:(void (^)(UIAlertAction*))okTapAction
                   cancelTapAction:(void (^)(UIAlertAction*))cancelTapAction {
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle: title
                                                                             message: message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle: @"Ok"
                                                       style: UIAlertActionStyleDefault
                                                     handler: okTapAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: @"Cancel"
                                                       style: UIAlertActionStyleDestructive
                                                     handler: cancelTapAction];
    
    [alertController addAction: cancelAction];
    [alertController addAction: okAction];
    
    [viewController presentViewController: alertController animated:YES completion:nil];
    
}

@end
