//
//  ParkMeterViewController.m
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import "ParkMeterViewController.h"
#import <Google/Analytics.h>
#import "CCAlertController.h"

@interface ParkMeterViewController ()

@property NSTimeInterval reminderTime;
@property NSTimeInterval meterExpirationTime;
@property BOOL meterButtonPressed;
@property BOOL reminderButtonPressed;

@property int pickerHeight;

@end

@implementation ParkMeterViewController
@synthesize timePicker, reminderTimeButton, meterExpiresButton, saveButton, pickerHeight;

#pragma mark Built-in Code
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,-44,320,44)];
    [toolBar setBarStyle: UIBarStyleDefault];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style: UIBarButtonItemStylePlain target:self action:@selector(closePicker)];
    toolBar.items = @[flexibleItem, barButtonDone];
    barButtonDone.tintColor = [UIColor blueColor];
    [timePicker addSubview:toolBar];
    
    pickerHeight = -CGRectGetHeight(timePicker.frame) + -CGRectGetHeight(toolBar.frame);
    _pickerBottomConstraint.constant = pickerHeight;
    timePickerIsOpen = NO;
    
    [timePicker setDate:[NSDate dateWithTimeIntervalSinceNow:0] animated:YES];
    [timePicker setDatePickerMode:UIDatePickerModeCountDownTimer];
    [self.view layoutIfNeeded];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.timePicker setCountDownDuration: 60];
    });

    self.screenName = @"Parking Meter Screen";
    
    timePicker.backgroundColor = [UIColor whiteColor];
    
    meterExpiresButton.layer.cornerRadius = 8;
    meterExpiresButton.layer.borderWidth = 1;
    meterExpiresButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    
    reminderTimeButton.layer.cornerRadius = 8;
    reminderTimeButton.layer.borderWidth = 1;
    reminderTimeButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    
    saveButton.layer.cornerRadius = 8;
    saveButton.layer.borderWidth = 1;
    saveButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    [tracker set:kGAIScreenName value:self.screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView]build]];
    
    NSDate* timeStampForNow = [NSDate date];
    NSTimeInterval timeSince1970 = [timeStampForNow timeIntervalSince1970];
    
    // Getting NSTimeInterval for the timesaved - time now. tells you how many seconds until the reminder will go off
    NSTimeInterval reminderTimeRemaining = ([[NSUserDefaults standardUserDefaults]doubleForKey:@"reminder"] - timeSince1970);
    
    NSTimeInterval meterTimeRemaining = ([[NSUserDefaults standardUserDefaults]doubleForKey:@"meter"] - timeSince1970);

    if ( meterTimeRemaining > 0) {
        // send the time interval and the desired target button and picker to the method
        [self setButtonTitle: meterExpiresButton withTime: meterTimeRemaining];
    }

    if ( reminderTimeRemaining > 0 ) {
        [self setButtonTitle: reminderTimeButton withTime: reminderTimeRemaining];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self closePicker];
}


#pragma mark setLabel when viewDidApper
-(void)setButtonTitle:(UIButton*)button withTime:(NSTimeInterval)interval {
 
    // takes the interval (how long till reminder goes off) and see if there are hours involved
    int hour = interval / 3600;
    
    // to get the mins hours from the left of the decimal and then multiply by 60 to get minutes when viewed as a ratio
    int minutes = (((float)interval / 3600.0f) - hour) * 60;
    
    if( hour > 0 ) {

        // set the title of the button to be the remaining time
        [button setTitle:[NSString stringWithFormat:@"%d Hours and %i Minutes",hour,minutes] forState: UIControlStateNormal];
        
    }else {
        
        [button setTitle:[NSString stringWithFormat:@"%i Minutes",minutes] forState: UIControlStateNormal];
    }
    
}


#pragma mark Button-Presses
- (IBAction)savePressed:(UIButton *)sender {
    
    [self resetButtonState];
    
    // if the reminder time has not been changed and the button still shows the default title
    // skip everything in the initial if statement and run the alert in the else
    if (![reminderTimeButton.titleLabel.text isEqualToString:@"Press to Set"]) {

        // getting the time right when the saved button is pressed  and then converting it to timeSince1970
        NSDate* rightNow = [NSDate date];
        NSTimeInterval secondsSince1970 = [rightNow timeIntervalSince1970];
        
        // if the title of the label is not "press to set", then the user set a time there and I want to save it into the user defaults and then sync the defaults
        // the seconds since 1970 is added to the countdownTimer so that it can be used for both a time stamp and duration later.
        // the time thats actually is the time when the timer should go off, so in essence its a future time from the set point
        if( ![meterExpiresButton.titleLabel.text isEqualToString:@"Press to Set"]){
            [[NSUserDefaults standardUserDefaults]setDouble:(secondsSince1970 + _meterExpirationTime) forKey:@"meter"];
        }
        if( ![reminderTimeButton.titleLabel.text isEqualToString:@"Press to Set"]){
            [[NSUserDefaults standardUserDefaults]setDouble:(secondsSince1970 + _reminderTime) forKey:@"reminder"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];


        // setting up the notification for your saved reminder time.
        _app = [UIApplication sharedApplication];
        _notifyAlarm = [[UILocalNotification alloc] init];
        
        NSDate* date1 = [[NSDate alloc]init];
        date1 = [date1 dateByAddingTimeInterval:totalSeconds];
        
        _notifyAlarm.fireDate = date1;
        _notifyAlarm.alertBody = @"Your Parking Meter Time Will Expire Soon!";
        _notifyAlarm.timeZone = [NSTimeZone systemTimeZone];
        _notifyAlarm.applicationIconBadgeNumber = 1;
        [_app scheduleLocalNotification:_notifyAlarm];
        NSLog(@"Reminder Set");
        
        [CCAlertController showOkAlertWithTitle: @"Saved:"
                                     andMessage:@"Reminder has been added."
                               onViewController:self
                                  withTapAction:nil];
        
    } else {
        
        [CCAlertController showOkAlertWithTitle: @"Error:"
                                     andMessage:@"You Must Set A Reminder Time Before Pressing Save"
                               onViewController:self
                                  withTapAction:nil];
        
    }
    
}


- (IBAction)meterExpiresBtnPressed:(UIButton *)sender {
    _meterButtonPressed = YES;
    _reminderButtonPressed = NO;
    
    [self setCountDownRemainder:_meterExpirationTime];

}


- (IBAction)reminderTimePressed:(UIButton *)sender {
    _reminderButtonPressed = YES;
    _meterButtonPressed = NO;
    
    [self setCountDownRemainder:_reminderTime];

}


-(void) setCountDownRemainder:(NSTimeInterval)remainder {
    [timePicker setCountDownDuration: remainder ?: 61];
    
    if (timePickerIsOpen == NO) {
        
        [self pickerShouldBeOpen:YES];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (timePickerIsOpen == YES) {
        [self resetButtonState];
        
        [self pickerShouldBeOpen:NO];
    }
}

#pragma mark Picker Values Changed
- (IBAction)pickerValueChanged:(UIDatePicker *)sender {
    
    NSLog(@"%i", (int)sender.countDownDuration);

    if (_meterButtonPressed) {
        [self setButtonTitle: meterExpiresButton withTime:sender.countDownDuration];
    } else if (_reminderButtonPressed) {
        [self setButtonTitle: reminderTimeButton withTime:sender.countDownDuration];
    }
}

-(void)changeDateFromLabel:(id)sender {
    [timePicker resignFirstResponder];
}

- (void) closePicker {
    [self pickerShouldBeOpen:NO];
}

#pragma mark View Animations
-(void)pickerShouldBeOpen:(BOOL) displayOpen {
    
    double animationDuration = displayOpen ? 0.35 : 0.1;
    
    if (displayOpen){
        _pickerBottomConstraint.constant = 0;
        timePickerIsOpen = YES;
        
    } else {
        _pickerBottomConstraint.constant = pickerHeight;
        timePickerIsOpen = NO;
        [self resetButtonState];
    }

    // uiview animation to move things up and down with teh passed in information
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];

    
}

-(void) resetButtonState {
    _meterButtonPressed = NO;
    _reminderButtonPressed = NO;
}


@end
