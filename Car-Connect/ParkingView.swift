//
//  ParkingView.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import SwiftUI
import MapKit

struct ParkingView: View {

    @StateObject private var locationManger = LocationManager()

    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationManger.region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                .ignoresSafeArea()
                .onAppear {
                    LocationManager().checkIfLocationServicesEnabled()
                }

            VStack {
                Spacer()

                HStack {
                    Button {

                    } label: {
                        Image(systemName: "location")
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .foregroundColor(Color(UIColor.label))
                    .font(.title2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.label), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(.leading)

                    Spacer()

                    Button {

                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .foregroundColor(Color(UIColor.label))
                    .font(.title2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.label), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(.trailing)
                }
                .padding([.bottom], 75)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ParkingView()
    }
}

