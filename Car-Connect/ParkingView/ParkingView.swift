//
//  ParkingView.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import SwiftUI
import MapKit

struct ParkingView: View {
    @StateObject private var locationManager = LocationManager()

    @State var region = LocationManager.defaultRegion

    @State private var userTrackingMode = MapUserTrackingMode.none

    @State var hasSetParkingSpot: Bool = StorageHandler.getParkingLocation() != nil

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant($userTrackingMode.wrappedValue))
            .ignoresSafeArea()
            .onChange(of: locationManager.userCoordinate) { newLocation in
                guard let newLocation else { return }

                withAnimation {
                    self.region.center = newLocation.coordinate
                }
            }

            VStack {
                Spacer()

                HStack(alignment: .center, content: {
                    Button(action: {
                        userTrackingMode = userTrackingMode == .follow ? .none : .follow
                    }, label: {
                        if userTrackingMode == . none {
                            Image(systemName: "location")
                        } else {
                            VStack {
                                Image(systemName: "location.fill")
                                Text("Following")
                                    .font(.footnote)
                                    .padding([.leading, .trailing], 5)
                            }
                        }
                    })
                    .frame(minWidth: 60, minHeight: 50)
                    .font(.body)
                    .background(Color(UIColor.systemBackground))
                    .foregroundColor(Color(UIColor.label))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.label), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Spacer()

                    Button(action: {
                        if StorageHandler.getParkingLocation() == nil {
                            let position = locationManager.region.center
                            StorageHandler.setParkingLocation(location: ParkingLocation(latitude: position.latitude,
                                                                                        lonitude: position.longitude))
                            self.hasSetParkingSpot = true
                        } else {
                            StorageHandler.clearSavedParkingLocation()
                            self.hasSetParkingSpot = false
                        }
                    }, label: {
                        if hasSetParkingSpot {
                            VStack {
                                Image(systemName: "mappin.slash")
                                Text("Clear")
                                    .font(.footnote)
                            }
                        } else {
                            VStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text("Save")
                                    .font(.footnote)
                            }
                        }

                    })
                    .frame(width: 60, height: 50)
                    .font(.body)
                    .background(Color(UIColor.systemBackground))
                    .foregroundColor(Color(UIColor.label))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.label), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                })
                .padding([.leading, .trailing], 25)
                .padding([.bottom], 50)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

