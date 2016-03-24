//
//  ParkMeterViewController.m
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import "ParkMeterViewController.h"
#import "GAIDictionaryBuilder.h"

@interface ParkMeterViewController ()

@end

@implementation ParkMeterViewController
@synthesize reminderTimePicker, meterExpiresPicker, reminderTimeButton, meterExpiresButton, closeMeterLabel, closeReminderLabel, saveButton;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




#pragma mark Built-in Code
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"meter Page loaded");
    
    // vars to be used for positioning of picker and label
    downLblY = 540;
    upLblY = 314;
    downPickerY = 630;
    upPickerY = 435;
    
    
    
    self.screenName = @"Parking Meter Screen";
    
    reminderTimePicker.backgroundColor = [UIColor whiteColor];
    meterExpiresPicker.backgroundColor = [UIColor whiteColor];
    
    meterExpiresButton.layer.cornerRadius = 8;
    meterExpiresButton.layer.borderWidth = 1;
    meterExpiresButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    
    reminderTimeButton.layer.cornerRadius = 8;
    reminderTimeButton.layer.borderWidth = 1;
    reminderTimeButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    
    saveButton.layer.cornerRadius = 8;
    saveButton.layer.borderWidth = 1;
    saveButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    
    meterPickerIsDisplayed = NO;
    reminderPickerIsDisplayed = NO;

    
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSDate* timeStampForNow = [NSDate date];
    NSTimeInterval timeSince1970 = [timeStampForNow timeIntervalSince1970];
    
    // Getting NSTimeInterval for the timesaved - time now. tells you how many seconds until the reminder will go off
    NSTimeInterval reminderTimeRemaining = ([[NSUserDefaults standardUserDefaults]integerForKey:@"reminder"] - timeSince1970);
    NSTimeInterval meterTimeRemaining = ([[NSUserDefaults standardUserDefaults]integerForKey:@"meter"] - timeSince1970);

    if( meterTimeRemaining > 0){
        
        // send the time interval and the desired target button and picker to the method
        [self setLabel:meterExpiresButton withTime:meterTimeRemaining onPicker:meterExpiresPicker];
    }

    if( reminderTimeRemaining > 0 ){
        
        [self setLabel:reminderTimeButton withTime:reminderTimeRemaining onPicker:reminderTimePicker];
    }
}


#pragma mark setLabel when viewDidApper
-(void)setLabel:(UIButton*)button withTime:(NSTimeInterval)interval onPicker:(UIDatePicker*)picker {
 
    // takes the interval (how long till reminder goes off) and see if there are hours involved
    int hour = interval / 3600;
    
    // to get the mins hours from the left of the decimal and then multiply by 60 to get minutes when viewed as a ratio
    int minutes = (((float)interval / 3600.0f) - hour) * 60;
    
    if( hour > 0 ) {
        
        // set the countdown timer to what the remaining time is
        picker.countDownDuration = interval;
        // set the title of the button to be the remaining time
        [button setTitle:[NSString stringWithFormat:@"%d Hours and %i Minutes",hour,minutes] forState: UIControlStateNormal];
        
    }else {
        
        picker.countDownDuration = interval;
        [button setTitle:[NSString stringWithFormat:@"%i Minutes",minutes] forState: UIControlStateNormal];
    }
    
}




#pragma mark Picker Values Changed
- (IBAction)timePicker:(UIDatePicker *)sender {
    
    // set the total seconds equal to the countdownduration property
    // the totalseconds for the reminder button is used to set the reminder below
    // the meter version of totalseconds is discarded after its used to set the label
    meterTotalSeconds = sender.countDownDuration;
    [self setButtonLabel:meterExpiresButton usingSeconds:meterTotalSeconds];
    
}
- (IBAction)reminderTimePicker:(UIDatePicker *)sender {
    
    // set the total seconds equal to the countdownduration property
    // the totalseconds for the reminder button is used to set the reminder below
    totalSeconds = sender.countDownDuration;
    [self setButtonLabel:reminderTimeButton usingSeconds:totalSeconds];

}


#pragma mark Set Label when Picker Value changes
-(void)setButtonLabel:(UIButton*)button usingSeconds:(int)time{
    
    // take that time and / by 3600 to get total hours
    int hour = (time / 3600);
    NSLog(@"hours: %i", hour);
    
    // if the hour is more than 1 do the math and make the label look right
    if (hour > 0) {
        
        // minutes is the totalSeconds /  60 to get total minutes. Then subtract the # hours * 60 mins to get the remaning minutes if more than 60
        int minutes = (time/60)-(hour*60);
        NSLog(@"minutes: %i", minutes);
        
        // set the label of the button to accordingly
        [button setTitle:[NSString stringWithFormat:@"%i Hours and %i Minutes",hour, minutes] forState:UIControlStateNormal];
        
    }else {
        
        // less than 1 hour so divide totalSeconds / 60 to get the minuts
        int minutes = (time/60);
        NSLog(@"minutes: %i", minutes);
        
        // display minutes accordingly
        [button setTitle:[NSString stringWithFormat:@"%i Minutes", minutes] forState:UIControlStateNormal];
    }
}



#pragma mark Button-Presses
- (IBAction)savePressed:(UIButton *)sender {
    
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
            [[NSUserDefaults standardUserDefaults]setInteger:(secondsSince1970 + meterExpiresPicker.countDownDuration) forKey:@"meter"];
        }
        if( ![reminderTimeButton.titleLabel.text isEqualToString:@"Press to Set"]){
            [[NSUserDefaults standardUserDefaults]setInteger:(secondsSince1970 + reminderTimePicker.countDownDuration) forKey:@"reminder"];
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
        
        UIAlertView* alertSet = [[UIAlertView alloc] initWithTitle: @"Saved:" message:@"Notification Center reminder has been added" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertSet show];
        
    } else {
        
        UIAlertView* noReminderSet = [[UIAlertView alloc] initWithTitle: @"Error:" message:@"You Must Set A Reminder Time Before Pressing Save" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [noReminderSet show];
        
    }
    
    
    
}


- (IBAction)meterExpiresBtnPressed:(UIButton *)sender {
    // set the picker to the last time that was set when it reopens
    [meterExpiresPicker setCountDownDuration:meterExpiresPicker.countDownDuration];
    
    // if the meter picker is not out then display it
    if (meterPickerIsDisplayed == NO) {
        
        [self extendRetractPicker:meterExpiresPicker andLabel:closeMeterLabel withPickerY:upPickerY andLabelY:upLblY];
        meterPickerIsDisplayed = ! meterPickerIsDisplayed;
    }

    
    // if the reminder picker is out when this is pressed then retract it.
    if (reminderPickerIsDisplayed == YES) {
        
        [self extendRetractPicker:reminderTimePicker andLabel:closeReminderLabel withPickerY:downPickerY andLabelY:downLblY];
        reminderPickerIsDisplayed = ! reminderPickerIsDisplayed;
    }

}


- (IBAction)reminderTimePressed:(UIButton *)sender {
    
    // set the picker to the last time that was set when it reopens
    [reminderTimePicker setCountDownDuration:reminderTimePicker.countDownDuration];
    
    // if the reminder is not open then open it when reminder button is pressed
    if (reminderPickerIsDisplayed == NO) {
        
        [self extendRetractPicker:reminderTimePicker andLabel:closeReminderLabel withPickerY:upPickerY andLabelY:upLblY];
        reminderPickerIsDisplayed = ! reminderPickerIsDisplayed;
    }
    
    // if the meter picker is open when reminder is pressed then close it
    if (meterPickerIsDisplayed == YES) {
        
        [self extendRetractPicker:meterExpiresPicker andLabel:closeMeterLabel withPickerY:downPickerY andLabelY:downLblY];
        meterPickerIsDisplayed = ! meterPickerIsDisplayed;
    }

}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // close things if their open and the user presses outside of them.
    if (reminderPickerIsDisplayed == YES) {
        
        [self extendRetractPicker:reminderTimePicker andLabel:closeReminderLabel withPickerY:downPickerY andLabelY:downLblY];
        reminderPickerIsDisplayed = ! reminderPickerIsDisplayed;
    }
    
    // if open then close it
    if (meterPickerIsDisplayed == YES) {
        
        [self extendRetractPicker:meterExpiresPicker andLabel:closeMeterLabel withPickerY:downPickerY andLabelY:downLblY];
        meterPickerIsDisplayed = ! meterPickerIsDisplayed;

    }

}

#pragma mark View Animations
-(void)extendRetractPicker:(UIDatePicker*)picker andLabel:(UILabel*)label withPickerY:(int)pickerY andLabelY:(int)labelY {
    
    // uiview animation to move things up and down with teh passed in information
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         picker.center = CGPointMake(picker.frame.origin.x + (picker.frame.size.width/2), pickerY);
                         label.center = CGPointMake(label.frame.origin.x + (label.frame.size.width/2), labelY);
                     }
                     completion:nil];

    
}












@end
