//
//  FindCarViewController.m
//  Car-Connect
//
//  Created by Matthew Dutton on 4/7/14.
//  Copyright (c) 2014 Matthew Dutton. All rights reserved.
//

#import "FindCarViewController.h"
#import "GAIDictionaryBuilder.h"

@interface FindCarViewController ()

@end

@implementation FindCarViewController
@synthesize walkingMap, getDirectionsBtn, exitDirectionsBtn, mapSelector, animationWheel;

#pragma mark Built-in Code
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the screen name for the analytics
    self.screenName = @"Find Car Screen";
    
    // instance of the first view controller so that the pin information can be passed
    parkingVC = [[ParkCarViewController alloc]init];
    
    // set up the map that is on this VC to show userlocation and starting map type
    walkingMap.showsUserLocation = YES;
    walkingMap.mapType = MKMapTypeHybrid;
    walkingMap.delegate = self;
    
    // get the users location for the map
    MKUserLocation* userLocation = walkingMap.userLocation;
    MKCoordinateSpan span =  MKCoordinateSpanMake(.005f, .005f);
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
    [walkingMap setRegion:region animated:NO];

    // button color and border set
    getDirectionsBtn.layer.cornerRadius = 8;
    getDirectionsBtn.layer.borderWidth = 1;
    getDirectionsBtn.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    
    exitDirectionsBtn.layer.cornerRadius = 8;
    exitDirectionsBtn.layer.borderWidth = 1;
    exitDirectionsBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f];
    exitDirectionsBtn.layer.borderColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:1.0].CGColor;
    

}

-(void)viewDidAppear:(BOOL)animated{
    // animate activity indicator for 4 seconds as shown in the method
    [self startAnimation];
    // if the array with the annotation is not empty then we are oging to show that pin with the information held in the array
    if ( [parkingPoint count] > 0 ) {
        [walkingMap addAnnotations:parkingPoint];
        
        // set pinPresent to denote there is a pin on map to block/allow certain functionality accordingly
        pinPresent = YES;
        
    } else {
        
        // if there is no count then make sure the array is cleared and remove everything from the map
        [parkingPoint removeAllObjects];
        id userLocation = [walkingMap userLocation];
        
        NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[walkingMap annotations]];
        if ( userLocation != nil ) {
            [pins removeObject:userLocation]; // avoid removing user location off the map
        }
        [walkingMap removeAnnotations:pins];
        pins = nil;
        
        // reset pinpresent to allow a pin to be added
        pinPresent = NO;
        [walkingMap removeOverlays:walkingMap.overlays];
        // set button title
        [exitDirectionsBtn setTitle:@"Clear Pin" forState:UIControlStateNormal];
        exitDirectionsBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Start/Stop Animation

-(void)startAnimation {
    // animate the activity indicator for 4 seconds when the view comes on so that user doesnt interact immediately with it
    [animationWheel startAnimating];
    [self performSelector:@selector(stopAnimation) withObject:self afterDelay:4];
    
}
-(void)stopAnimation {
    // stop animation
    [animationWheel stopAnimating];
}




#pragma mark Button-Presses
- (IBAction)mapType:(UISegmentedControl *)sender {
    
    // use the selected index to determine the desired map type and change according
    long type = sender.selectedSegmentIndex;
    NSLog(@"%li", type);
    
    if (type == 0) {
        walkingMap.mapType = MKMapTypeStandard;
        
    } else if (type == 1){
        walkingMap.mapType = MKMapTypeSatellite;
        
    } else if (type == 2){
        walkingMap.mapType = MKMapTypeHybrid;
        
    }

}

- (IBAction)exitNavigationPressed:(UIButton *)sender {
    
    // when the exit button is pressed if its title is clear direction which would have been set if the get directions button was pressed
    if ( [exitDirectionsBtn.titleLabel.text isEqualToString:@"Clear Directions"]) {
       
        //clear the over lays from the map
        [walkingMap removeOverlays:walkingMap.overlays];
        
        // add the saved car location pin back in
        [walkingMap addAnnotations:parkingPoint];
        
        // re set the title to clear pin
        [exitDirectionsBtn setTitle:@"Clear Pin" forState:UIControlStateNormal];
        exitDirectionsBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f];
        
    } else {
        // if the title isnt clear directions and the pin is present
        if (pinPresent == YES) {

        // prompt to ensure you want the pin cleared
        UIAlertView* clearPinConfirm = [[UIAlertView alloc]initWithTitle:@"Are You Sure?" message:@"Are you sure that you would like to clear your saved loacation?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [clearPinConfirm show];
        // see the alertview clickedButtonAtIndex for the click handling. on the alert
        }
    }

}
- (IBAction)getDirectionsPressed:(UIButton *)sender {
    
    // if there is a pin
    if ( pinPresent == YES) {
        
        // analytics registers that the get directions was pressed
        id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User_Interface_Parking_Page" action:@"Button Press" label:@"Get Directions Pressed" value:nil]build]];
        
        if ( ![parkingPoint count] == 0) {
            // get  the coordinates to where you want to end up as the pins location
            MKPointAnnotation* destinationCoordinates = [parkingPoint objectAtIndex:0];
            
            // set a placemark for those coordinates
            MKPlacemark* placeMark = [[MKPlacemark alloc]initWithCoordinate:destinationCoordinates.coordinate addressDictionary:nil];
            // use the pace mark to set a map item
            MKMapItem* destination = [[MKMapItem alloc]initWithPlacemark:placeMark];
            
            // request directions from the server
            MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
            
            // sets the source as current user location
            [request setSource:[MKMapItem mapItemForCurrentLocation]];
            
            // destination is the placemark/map item from above
            [request setDestination:destination];
            
            // type of directions you want(vehicle or walking or either)
            [request setTransportType:MKDirectionsTransportTypeWalking];
            
            // set as to wheter or not you are allowed to choose the route to take if the API finds multiple which in not common
            [request setRequestsAlternateRoutes:YES];
            
            // placing the directions into an overlay and laying that onto the map after the request
            MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (!error) {
                    for (MKRoute *route in [response routes]) {
                        [walkingMap addOverlay:[route polyline] level:MKOverlayLevelAboveRoads]; // Draws the route above roads, but below labels.
                       
                    }
                }
            }];
            
            // set the title of the red button to clear directions to allow that to be handled in the other button click event
            [exitDirectionsBtn setTitle:@"Clear Directions" forState:UIControlStateNormal];
            
            exitDirectionsBtn.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.2f];
    
        }
    
    }else {
        // if there are no pins then alert user then need pins
        UIAlertView* noPinsPresent = [[UIAlertView alloc]initWithTitle:@"Oops:" message:@"No pins have been placed. \nPlease place a pin to utilize the \n\"Get Directions\" feature" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [noPinsPresent show];
        
    }
    
}


#pragma mark AlertView- Click Handler
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // if "OK" was clicked clear the pins
    if (buttonIndex == 1) {
    
        id<GAITracker> tracker = [[GAI sharedInstance]defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User_Interface_Parking_Page" action:@"Button Press" label:@"Directions Cancelled" value:nil]build]];
        
        // clear the array of the pin information
        [parkingPoint removeAllObjects];
        
        // get userlocation and put into an array
        id userLocation = [walkingMap userLocation];
        
        // put everything in the map into an array
        NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[walkingMap annotations]];
        
        // remove the user location object from that array
        if ( userLocation != nil ) {
            [pins removeObject:userLocation]; // avoid removing user location off the map
        }
        
        // remove everything else from the map except userlocation
        [walkingMap removeAnnotations:pins];
        pins = nil;
        
        // reset var for is pinPresent
        pinPresent = NO;
    }
}





#pragma mark Map-Methods
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    // when the user location updates if they said ok the the user location functionality then show the updated location
    if (mapView.showsUserLocation == YES) {
        
        MKCoordinateRegion mapRegion;
        mapRegion.center = walkingMap.userLocation.coordinate;
        
        MKCoordinateSpan span = [mapView region].span;
        
        mapRegion.span = span;
        
        [walkingMap setRegion:mapRegion animated: YES];
        
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    // renders a polyline for the map directions as a blue line to follow.
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
}


@end





























