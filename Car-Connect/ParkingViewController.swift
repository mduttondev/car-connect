//
//  FirstViewController.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/16/17.
//  Copyright © 2017 Matthew Dutton. All rights reserved.
//

import UIKit
import MapKit

class ParkingViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var showCurrentLocationButton: UIButton!
    @IBOutlet weak var saveSpotButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: - Button Action
    @IBAction func showCurrentLocationButtonPressed(_ sender: UIButton) {
    }
    @IBAction func saveSpotButtonPressed(_ sender: UIButton) {
    }
}

