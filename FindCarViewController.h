//
//  FindCarViewController.h
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ParkCarViewController.h"
#import "GAITrackedViewController.h"

@interface FindCarViewController : GAITrackedViewController <MKMapViewDelegate, UIAlertViewDelegate>
{
    ParkCarViewController* parkingVC;
    MKPointAnnotation* whereCarIs;
    BOOL pinPresent;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *animationWheel;
@property (weak, nonatomic) IBOutlet MKMapView *walkingMap;
@property IBOutlet UIButton* getDirectionsBtn;
@property IBOutlet UIButton* exitDirectionsBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSelector;

- (IBAction)mapType:(UISegmentedControl *)sender;
- (IBAction)exitNavigationPressed:(UIButton *)sender;
- (IBAction)getDirectionsPressed:(UIButton *)sender;

@end
