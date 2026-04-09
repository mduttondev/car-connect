//
//  MainView.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ParkingView()
                .tabItem {
                    Label("Parking", systemImage: "parkingsign.circle")
                }

            MeterView()
                .tabItem {
                    Label("Meter", systemImage: "timer")
                }
        }
    }
}

#Preview {
    MainView()
}
