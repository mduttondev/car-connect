//
//  ParkCarViewController.m
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import "ParkCarViewController.h"
#import "GAIDictionaryBuilder.h"



@interface ParkCarViewController ()

@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation ParkCarViewController
@synthesize parkView, mapTypeSelector, parkHereButton, parkedCar, activityWheel;


#pragma mark Built-in Code
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    
    // analytics information
    self.screenName = @"Set Parking Screen";
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    [tracker set:kGAIScreenName value:@"Set Parking Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView]build]];
    
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        [self.locationManager startUpdatingLocation];
        
    }
    
    [self setupViewController];
    
}


-(void)viewDidAppear:(BOOL)animated {
    // start the activity indicator animation
    [self startingAnimation];
    
    // if there are pins in the parking point arr then add them to the map
    if ( [parkingPoint count] > 0 ) {
        [parkView addAnnotations:parkingPoint];
        
    // if there are no pins in that array
    } else {
        
        // reset the num pins and ensure all obj are remove from the arrat
        numberOfPins = 0;
        [parkingPoint removeAllObjects];
        
        
        // set user location
        id userLocation = [parkView userLocation];
        
        // get all map annotations
        NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[parkView annotations]];
        
        // remove the user location from that array
        if ( userLocation != nil ) {
            [pins removeObject:userLocation];
        }
        
        // remover everything else from the map except user location
        [parkView removeAnnotations:pins];
        pins = nil;
        
        //retitle and recolor the button accordingly
        parkHereButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
        [parkHereButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [parkHereButton setTitle:@"Park Here" forState:UIControlStateNormal];
        isPinDropped = NO;
    }
}

- (void) setupViewController {
    
    // array for use with the annotations
    parkingPoint = [[NSMutableArray alloc]init];
    
    // setting maptype and userlocation on map
    parkView.showsUserLocation = YES;
    parkView.mapType = MKMapTypeHybrid;
    parkView.delegate = self;
    
    // setting map around the user location
    MKUserLocation* userLocation = parkView.userLocation;
    MKCoordinateSpan span =  MKCoordinateSpanMake(.005f, .005f);
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    [parkView setRegion:region animated:NO];
    
    // setting the there is no pin dropped on the map at current
    isPinDropped = NO;
    
    // setting the initial look of the button
    parkHereButton.layer.cornerRadius = 8;
    parkHereButton.layer.borderWidth = 1;
    parkHereButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    
}


-(void)startingAnimation {
    
    // starting the animation and after 4 seconds call the stop animation method
    [activityWheel startAnimating];
    [self performSelector:@selector(stopAnimation) withObject:self afterDelay:4];
    
}
-(void)stopAnimation {
    // stop the animation for the activity indicator
    [activityWheel stopAnimating];
}


#pragma mark Annotation
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    // setting up the deque for the pin, setting the pins color and then properties to allow the
    // text callout we will set to be shown when the user tape it
    MKPinAnnotationView* pointAnnotation = (MKPinAnnotationView*)[parkView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    
    if (pointAnnotation == nil) {
        pointAnnotation = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pinView"];
    }
    pointAnnotation.pinColor = MKPinAnnotationColorRed;
    pointAnnotation.canShowCallout = YES;
    pointAnnotation.animatesDrop = YES;
    
    if (annotation == [parkView userLocation]) {
        return nil;
    }
    
    return pointAnnotation;
    
}

- (IBAction)parkHerePressed:(UIButton *)sender {
    
    // if there is no pin
    if (isPinDropped == NO) { // SET A PIN ON THE MAP
        // record that were dropping a pin
        id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User_Interface_Parking_Page" action:@"Button Press" label:@"Pin Placed" value:nil]build]];
                        
        
        if (numberOfPins == 0) {
            // increment the number of pins on the map,
            // this is an repeat variable and could be refactored to get rid of it.
            numberOfPins++;
            
            // setting the location of the pic to user location and setting the title text
            parkedCar = [[MKPointAnnotation alloc]init];
            parkedCar.coordinate = parkView.userLocation.coordinate;
            parkedCar.title = @"You Parked Here";
            
            // add that pin the the global array to easily pass it around
            [parkingPoint addObject:parkedCar];
            
            // add that parking point to the map
            [parkView addAnnotations:parkingPoint];
            
            // change var to show pin is dropped
            isPinDropped = YES;
        }
        
        // retitle and recolor the button
        parkHereButton.layer.borderColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:1.0].CGColor;
        [parkHereButton setTitleColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:1.0] forState:UIControlStateNormal];
        [parkHereButton setTitle:@"Clear Pin" forState:UIControlStateNormal];
    
    // if pindropped is yes then a pin is on the map and we want to delete it
    }else {
        // prompt to ensure you want the pin cleared
        UIAlertView* clearPinConfirm = [[UIAlertView alloc]initWithTitle:@"Are You Sure?" message:@"Are you sure that you would like to clear your saved loacation?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [clearPinConfirm show];
        // see the alertview clickedButtonAtIndex for the click handling. on the alert
        
    }
}

#pragma mark AlertView ClickHandler
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {// index 1 == OK

    // record that being pressed in analytics
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User_Interface_Parking_Page" action:@"Button Press" label:@"Pin Cleared" value:nil]build]];
    
    // set num pins to 0 and clear the pin from the array
    numberOfPins = 0;
    [parkingPoint removeAllObjects];
    
    // get userlocation and set as id
    id userLocation = [parkView userLocation];
    
    // get all map items into an array
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[parkView annotations]];
        
    // removie the user location item from that array
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    
    // clear everything except user location from the array
    [parkView removeAnnotations:pins];
    pins = nil;
    
    // set pindropped? to no
    isPinDropped = NO;
        
    // rename and recolor button
    parkHereButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    [parkHereButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [parkHereButton setTitle:@"Park Here" forState:UIControlStateNormal];
    
    }
}

#pragma mark Map-CallBacks
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    // updating user location if that is enabled from the user
    if (mapView.showsUserLocation == YES) {
        
        MKCoordinateRegion mapRegion;
        mapRegion.center = parkView.userLocation.coordinate;
        
        MKCoordinateSpan span = [mapView region].span;
        
        mapRegion.span = span;
     
        [parkView setRegion:mapRegion animated: YES];
        
    }
}

- (IBAction)mapTypeSelect:(UISegmentedControl *)sender {
    
    // using selector to determine which segment is pressed and settnig the map accordingly
    
    id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User_Interface_Parking_Page" action:@"Button Press" label:@"Map changed to:" value:[NSNumber numberWithLong:sender.selectedSegmentIndex]]build]];
    
        // get the segmented index
        long type = sender.selectedSegmentIndex;
        NSLog(@"%li", type);
        
        //set MKMapType accordingly
        if (type == 0) {
            parkView.mapType = MKMapTypeStandard;

        } else if (type == 1){
            parkView.mapType = MKMapTypeSatellite;
            
        }else if (type == 2){
            parkView.mapType = MKMapTypeHybrid;
            
        }

}



@end
