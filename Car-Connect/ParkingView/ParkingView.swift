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

    @State var region = Constants.defaultRegion

    @State private var userTrackingMode = MapUserTrackingMode.follow

    @State var hasSetParkingSpot: Bool = StorageHandler.getParkingLocation() != nil
    @AppStorage(StorageHandler.locationKey) private var parkingSpot: ParkingLocation? = nil

    var body: some View {
        ZStack {
            if let parkingSpot {
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: .constant($userTrackingMode.wrappedValue),
                    annotationItems: [parkingSpot]) { location in
                    MapPin(coordinate: location.coordinate)
                }
            } else {
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: .constant($userTrackingMode.wrappedValue))
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
                        if parkingSpot == nil {
                            guard let position = locationManager.userLocation?.coordinate else { return }
                            withAnimation {
                                parkingSpot = ParkingLocation(latitude: position.latitude,
                                                              lonitude: position.longitude)
                            }
                        } else {
                            withAnimation {
                                parkingSpot = nil
                            }
                        }
                    }, label: {
                        if parkingSpot != nil {
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

