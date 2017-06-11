//
//  ParkMeterViewController.h
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface ParkMeterViewController : GAITrackedViewController <UIAlertViewDelegate> {
    
    BOOL timePickerIsOpen;
    int totalSeconds;
    int meterTotalSeconds;
    
    
}

@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@property (weak, nonatomic) IBOutlet UIButton *meterExpiresButton;
@property (weak, nonatomic) IBOutlet UIButton *reminderTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerBottomConstraint;

@property UIApplication* app;
@property UILocalNotification* notifyAlarm;

- (IBAction)savePressed:(UIButton *)sender;

- (IBAction)meterExpiresBtnPressed:(UIButton *)sender;
- (IBAction)reminderTimePressed:(UIButton *)sender;
- (IBAction)pickerValueChanged:(UIDatePicker *)sender;

@end
