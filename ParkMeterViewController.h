//
//  ParkMeterViewController.h
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface ParkMeterViewController : GAITrackedViewController <UIAlertViewDelegate>

{
    BOOL meterPickerIsDisplayed;
    BOOL reminderPickerIsDisplayed;
    int totalSeconds;
    int meterTotalSeconds;
    
    int downLblY;
    int upLblY;
    int downPickerY;
    int upPickerY;
    
}



@property (weak, nonatomic) IBOutlet UIDatePicker *reminderTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *meterExpiresPicker;
@property (weak, nonatomic) IBOutlet UIButton *meterExpiresButton;
@property (weak, nonatomic) IBOutlet UIButton *reminderTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *closeReminderLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeMeterLabel;


@property UIApplication* app;
@property UILocalNotification* notifyAlarm;

- (IBAction)savePressed:(UIButton *)sender;

- (IBAction)meterExpiresBtnPressed:(UIButton *)sender;
- (IBAction)reminderTimePressed:(UIButton *)sender;

- (IBAction)timePicker:(UIDatePicker *)sender;

- (IBAction)reminderTimePicker:(UIDatePicker *)sender;


@end
