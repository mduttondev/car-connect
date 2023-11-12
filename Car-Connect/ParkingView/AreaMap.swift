//
//  AreaMap.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 11/11/23.
//

import SwiftUI
import MapKit

struct AreaMap: View {
    @Binding var region: MKCoordinateRegion
    @Binding var userTrackingMode: MapUserTrackingMode

    var body: some View {
        let region = Binding(
            get: { self.region },
            set: { newValue in
                DispatchQueue.main.async {
                    self.region = newValue
                }
            }
        )

        let userTrackingMode = Binding(
            get: { self.userTrackingMode },
            set: { newValue in
                DispatchQueue.main.async {
                    self.userTrackingMode = newValue
                }
            }
        )
        
        return Map(coordinateRegion: region,
                   showsUserLocation: true,
                   userTrackingMode: userTrackingMode)
        .ignoresSafeArea()
    }
}
