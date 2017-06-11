//
//  ParkCarViewController.h
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GAITrackedViewController.h"
#import "AppDelegate.h"

@interface ParkCarViewController : GAITrackedViewController <MKMapViewDelegate, UIAlertViewDelegate> {
    int numberOfPins;
    BOOL isPinDropped;
}

@property (nonatomic, strong) NSMutableArray* parkingPoint;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityWheel;

@property (weak, nonatomic) IBOutlet MKMapView *parkView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSelector;

@property (weak, nonatomic) IBOutlet UIButton *parkHereButton;

@property MKPointAnnotation* parkedCar;

- (IBAction)mapTypeSelect:(UISegmentedControl *)sender;


@end
