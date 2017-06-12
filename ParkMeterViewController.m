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
    NSTimeInterval reminderTimeRemaining = ([[NSUserDefaults standardUserDefaults] doubleForKey:@"reminder"] - timeSince1970);
    self.reminderTime = reminderTimeRemaining;
    
    NSTimeInterval meterTimeRemaining = ([[NSUserDefaults standardUserDefaults] doubleForKey:@"meter"] - timeSince1970);
    self.meterExpirationTime = meterTimeRemaining;
    
    if ( meterTimeRemaining > 0 ) {
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
    
    NSDate* timeNow = [NSDate date];
    NSDate* displayDate = [timeNow dateByAddingTimeInterval:interval];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSUInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:timeNow  toDate:displayDate options:0];
    
    
    
    if ( !(components.hour > 0 || components.minute) ) {
        return;
    }
    
    if ( components.hour > 0 ) {
        int hours = (int)components.hour;
        int minutes = (int)components.minute;
        [button setTitle:[NSString stringWithFormat:@"%d Hours and %i Minutes", hours, minutes] forState: UIControlStateNormal];
        
    } else {
        int minutes = (int)components.minute;
        [button setTitle:[NSString stringWithFormat:@"%i Minutes",minutes] forState: UIControlStateNormal];
    }
    
}


#pragma mark Button-Presses
- (IBAction)savePressed:(UIButton *)sender {
    
    [self resetButtonState];
    
    if (![reminderTimeButton.titleLabel.text isEqualToString:@"Press to Set"]) {
        
        NSDate* rightNow = [NSDate date];
        NSTimeInterval secondsSince1970 = [rightNow timeIntervalSince1970];
        
        if( ![meterExpiresButton.titleLabel.text isEqualToString:@"Press to Set"]){
            [[NSUserDefaults standardUserDefaults]
             setDouble:(_meterExpirationTime + secondsSince1970)
             forKey:@"meter"];
        }
        if( ![reminderTimeButton.titleLabel.text isEqualToString:@"Press to Set"]){
            [[NSUserDefaults standardUserDefaults]
             setDouble: (_reminderTime + secondsSince1970)
             forKey:@"reminder"];
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


- (void)setCountDownRemainder:(NSTimeInterval)remainder {
    
    int ti = (int)remainder;
    int minutes = (ti / 60) % 60;
    int hours = (ti / 3600);
    
    NSDateComponents* dateComp = [NSDateComponents new];
    dateComp.hour = hours;
    dateComp.minute = minutes;
    dateComp.timeZone = [NSTimeZone systemTimeZone];
    NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate* date = [calendar dateFromComponents:dateComp];
    
    [timePicker setDate:date animated:YES];
    
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
        _meterExpirationTime = sender.countDownDuration;
        [self setButtonTitle: meterExpiresButton withTime: _meterExpirationTime];
    } else if (_reminderButtonPressed) {
        _reminderTime = sender.countDownDuration;
        [self setButtonTitle: reminderTimeButton withTime: _reminderTime];
    }
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
