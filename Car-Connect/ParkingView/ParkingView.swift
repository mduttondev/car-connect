//
//  ParkingView.swift
//  Car-Connect
//
//  Created by Matthew Dutton on 2/25/22.
//

import SwiftUI
import MapKit
import CoreLocation

@MainActor
final class ParkingViewModel: ObservableObject {

    @Published private(set) var parkingSpot: ParkingLocation?
    @Published private(set) var route: MKRoute?
    /// The remaining portion of the active route, trimmed to start at the
    /// user's current position. Updated as new location updates arrive so the
    /// already-walked portion of the polyline disappears.
    @Published private(set) var remainingRoutePolyline: MKPolyline?
    @Published private(set) var isCalculatingRoute = false
    @Published var routeErrorMessage: String?

    let locationManager: LocationManager

    init(locationManager: LocationManager? = nil) {
        if let locationManager {
            self.locationManager = locationManager
        } else if let gpxName = ProcessInfo.processInfo.environment["UITEST_GPX"] {
            let locations = GPXLoader.loadLocations(named: gpxName)
            self.locationManager = LocationManager(simulatedLocations: locations)
        } else {
            self.locationManager = LocationManager()
        }
        self.parkingSpot = StorageHandler.getParkingLocation()
    }

    var hasParkingSpot: Bool { parkingSpot != nil }
    var hasRoute: Bool { route != nil }

    /// Toggles the parking spot. When saving, prefers the user's current
    /// location; if that isn't available yet, falls back to `fallbackCoordinate`
    /// (typically the map's current center) so the save always succeeds.
    func toggleParkingSpot(fallbackCoordinate: CLLocationCoordinate2D? = nil) {
        if parkingSpot == nil {
            save(fallback: fallbackCoordinate)
        } else {
            clear()
        }
    }

    func requestWalkingDirections() async {
        guard let spot = parkingSpot else { return }
        guard let userLocation = locationManager.bestAvailableLocation() else {
            routeErrorMessage = "Your current location isn't available yet. Try again in a moment."
            return
        }

        isCalculatingRoute = true
        defer { isCalculatingRoute = false }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: spot.coordinate))
        request.transportType = .walking

        do {
            let response = try await MKDirections(request: request).calculate()
            route = response.routes.first
            remainingRoutePolyline = route?.polyline
            if route == nil {
                routeErrorMessage = "No walking route could be found to your parking spot."
            }
        } catch {
            routeErrorMessage = "Couldn't calculate a walking route: \(error.localizedDescription)"
        }
    }

    func clearRoute() {
        route = nil
        remainingRoutePolyline = nil
    }

    /// Recomputes `remainingRoutePolyline` so it begins at the closest point
    /// on the route to the user's current location, hiding the portion of the
    /// route they've already walked.
    func trimRouteToUser(currentLocation: CLLocation) {
        guard let route else {
            remainingRoutePolyline = nil
            return
        }
        let polyline = route.polyline
        let pointCount = polyline.pointCount
        guard pointCount >= 2 else {
            remainingRoutePolyline = polyline
            return
        }

        let points = polyline.points()
        let userPoint = MKMapPoint(currentLocation.coordinate)

        var minDistance = Double.greatestFiniteMagnitude
        var bestSegmentEnd = 1
        var bestProjection = points[0]

        for i in 0..<(pointCount - 1) {
            let a = points[i]
            let b = points[i + 1]
            let projection = Self.project(point: userPoint, ontoSegmentFrom: a, to: b)
            let distance = userPoint.distance(to: projection)
            if distance < minDistance {
                minDistance = distance
                bestSegmentEnd = i + 1
                bestProjection = projection
            }
        }

        var trimmed: [MKMapPoint] = [bestProjection]
        if bestSegmentEnd < pointCount {
            for i in bestSegmentEnd..<pointCount {
                trimmed.append(points[i])
            }
        }
        remainingRoutePolyline = MKPolyline(points: trimmed, count: trimmed.count)
    }

    /// Projects `point` onto the line segment from `a` to `b`, clamped to the
    /// segment endpoints. Used by `trimRouteToUser`.
    private static func project(point p: MKMapPoint,
                                ontoSegmentFrom a: MKMapPoint,
                                to b: MKMapPoint) -> MKMapPoint {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else { return a }
        let t = max(0, min(1, ((p.x - a.x) * dx + (p.y - a.y) * dy) / lengthSquared))
        return MKMapPoint(x: a.x + t * dx, y: a.y + t * dy)
    }

    /// Moves an already-saved parking spot to a new coordinate (from a drag).
    /// Preserves the spot's identity, persists the new location, and invalidates
    /// any cached walking route since it's now stale.
    func updateParkingSpot(to coordinate: CLLocationCoordinate2D) {
        guard let existing = parkingSpot else { return }
        let spot = ParkingLocation(
            id: existing.id,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        parkingSpot = spot
        StorageHandler.setParkingLocation(location: spot)
        route = nil
        remainingRoutePolyline = nil
    }

    private func save(fallback: CLLocationCoordinate2D?) {
        let coordinate = locationManager.bestAvailableLocation()?.coordinate ?? fallback
        guard let coordinate else { return }
        let spot = ParkingLocation(latitude: coordinate.latitude,
                                   longitude: coordinate.longitude)
        parkingSpot = spot
        StorageHandler.setParkingLocation(location: spot)
    }

    private func clear() {
        parkingSpot = nil
        StorageHandler.clearSavedParkingLocation()
        route = nil
        remainingRoutePolyline = nil
    }
}

struct ParkingView: View {

    @StateObject private var viewModel = ParkingViewModel()

    @State private var cameraPosition: MapCameraPosition =
        .region(Constants.defaultRegion)
    /// Tracks the camera's current distance (meters) so we can re-center
    /// the user location on Follow without clobbering the user's zoom level.
    @State private var currentDistance: CLLocationDistance = 2000
    /// The map's current center coordinate, used as a fallback for Save when
    /// the user's actual location isn't available yet.
    @State private var currentMapCenter: CLLocationCoordinate2D?
    @State private var isFollowingUser = true
    @State private var showPermissionAlert = false

    /// True while the user is repositioning the pin via the crosshair UI.
    /// In this mode, the saved pin annotation is hidden, a fixed crosshair
    /// is shown at screen center, and the control bar is replaced with
    /// Cancel / Done buttons. Done commits the map's current center as the
    /// new parking spot location.
    @State private var isMovingPin = false

    /// True while the floating action menu is expanded (showing Walk/Move/Clear).
    @State private var isMenuExpanded = false

    var body: some View {
        ZStack {
            mapLayer
            if isMovingPin {
                crosshairOverlay
            }
            VStack {
                Spacer()
                if isMovingPin {
                    moveControlBar
                } else {
                    controlBar
                }
            }
        }
        .task {
            viewModel.locationManager.requestAuthorization()
        }
        .onReceive(viewModel.locationManager.$userLocation.compactMap { $0 }) { newLocation in
            // Keep the visible route trimmed to "what's left" as the user walks.
            if viewModel.hasRoute {
                viewModel.trimRouteToUser(currentLocation: newLocation)
            }
            guard isFollowingUser else { return }
            withAnimation {
                cameraPosition = .camera(
                    MapCamera(centerCoordinate: newLocation.coordinate,
                              distance: currentDistance)
                )
            }
        }
        .onMapCameraChange(frequency: .continuous) { context in
            currentDistance = context.camera.distance
            currentMapCenter = context.camera.centerCoordinate
        }
        .onReceive(viewModel.locationManager.$authorizationStatus) { status in
            if status == .denied || status == .restricted {
                showPermissionAlert = true
            }
        }
        .onReceive(viewModel.$route.compactMap { $0 }) { newRoute in
            // If the user is currently in follow mode, just overlay the route
            // and keep tracking them. Otherwise zoom out to frame the whole route.
            guard !isFollowingUser else { return }

            // Center on the route's midpoint and choose a camera distance that
            // scales with the route's physical diagonal, with a generous floor
            // so short walks don't snap to street level.
            let rect = newRoute.polyline.boundingMapRect
            let topLeft = MKMapPoint(x: rect.minX, y: rect.minY)
            let bottomRight = MKMapPoint(x: rect.maxX, y: rect.maxY)
            let diagonalMeters = topLeft.distance(to: bottomRight)
            let targetDistance = min(max(diagonalMeters * 2.2, 2500), 50_000)
            let center = MKMapPoint(x: rect.midX, y: rect.midY).coordinate

            withAnimation(.easeInOut(duration: 0.5)) {
                cameraPosition = .camera(
                    MapCamera(centerCoordinate: center, distance: targetDistance)
                )
            }
        }
        .alert("Location Access Needed",
               isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Car-Connect needs location access to save where you parked.")
        }
        .alert("Couldn't Get Directions",
               isPresented: Binding(
                get: { viewModel.routeErrorMessage != nil },
                set: { if !$0 { viewModel.routeErrorMessage = nil } }
               )) {
            Button("Try Again") {
                viewModel.routeErrorMessage = nil
                Task { await viewModel.requestWalkingDirections() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(viewModel.routeErrorMessage ?? "")
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()

            if let spot = viewModel.parkingSpot, !isMovingPin {
                Annotation("Parked Here", coordinate: spot.coordinate) {
                    pinIcon
                }
            }

            if let polyline = viewModel.remainingRoutePolyline ?? viewModel.route?.polyline {
                MapPolyline(polyline)
                    .stroke(
                        .blue,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                    )
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .ignoresSafeArea(edges: .top)
    }

    private var pinIcon: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.title)
            .foregroundStyle(.red)
            .background(Circle().fill(.white))
            .shadow(radius: 2)
    }

    /// A floating pin centered on screen, used while the user is repositioning
    /// the parking spot via the move-mode crosshair pattern.
    private var crosshairOverlay: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.system(size: 30))
            .foregroundStyle(.red)
            .background(Circle().fill(.white))
            .shadow(radius: 4)
            .offset(y: -15) // anchor the pin tip at the exact screen center
            .allowsHitTesting(false)
    }

    private var controlBar: some View {
        HStack(alignment: .bottom) {
            followButton
            Spacer()
            floatingMenu
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    /// Bottom-right floating action menu. When no parking spot is saved, the
    /// main FAB is a single Save button. Once a spot is saved, tapping the FAB
    /// expands a vertical menu with Walk, Move, and Clear actions.
    private var floatingMenu: some View {
        VStack(alignment: .trailing, spacing: 12) {
            if viewModel.hasParkingSpot && isMenuExpanded {
                menuItem(
                    label: viewModel.hasRoute ? "Hide Route" : "Walk",
                    systemImage: viewModel.hasRoute ? "xmark.circle.fill" : "figure.walk.circle.fill",
                    tint: .blue,
                    identifier: "DirectionsButton",
                    showsProgress: viewModel.isCalculatingRoute
                ) {
                    if viewModel.hasRoute {
                        viewModel.clearRoute()
                    } else {
                        Task { await viewModel.requestWalkingDirections() }
                    }
                    collapseMenu()
                }
                .transition(menuItemTransition(index: 0))

                menuItem(
                    label: "Move",
                    systemImage: "arrow.up.and.down.and.arrow.left.and.right",
                    tint: .orange,
                    identifier: "MovePinButton"
                ) {
                    enterMoveMode()
                    collapseMenu()
                }
                .transition(menuItemTransition(index: 1))

                menuItem(
                    label: "Clear",
                    systemImage: "trash",
                    tint: .red,
                    identifier: "ClearParkingSpotButton"
                ) {
                    viewModel.toggleParkingSpot()
                    collapseMenu()
                }
                .transition(menuItemTransition(index: 2))
            }

            mainFAB
        }
    }

    private func menuItem(
        label: String,
        systemImage: String,
        tint: Color,
        identifier: String,
        showsProgress: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                action()
            }
        } label: {
            HStack(spacing: 8) {
                Text(label)
                    .lineLimit(1)
                if showsProgress {
                    ProgressView().controlSize(.small)
                } else {
                    Image(systemName: systemImage)
                        .contentTransition(.symbolEffect(.replace.downUp))
                }
            }
            .font(.callout.weight(.semibold))
            .frame(height: 22)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .buttonBorderShape(.capsule)
        .tint(tint)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityIdentifier(identifier)
    }

    private var mainFAB: some View {
        Button {
            if viewModel.hasParkingSpot {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                    isMenuExpanded.toggle()
                }
            } else {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                    viewModel.toggleParkingSpot(fallbackCoordinate: currentMapCenter)
                }
            }
        } label: {
            Image(systemName: mainFABIcon)
                .contentTransition(.symbolEffect(.replace.downUp))
                .symbolEffect(.bounce, value: viewModel.hasParkingSpot)
                .symbolEffect(.bounce, value: isMenuExpanded)
                .font(.callout.weight(.semibold))
                .frame(width: 22, height: 22)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .buttonBorderShape(.circle)
        .accessibilityIdentifier(viewModel.hasParkingSpot ? "ParkingMenuButton" : "SaveParkingSpotButton")
    }

    private var mainFABIcon: String {
        if !viewModel.hasParkingSpot {
            return "mappin.and.ellipse"
        } else if isMenuExpanded {
            return "xmark"
        } else {
            return "ellipsis"
        }
    }

    private func menuItemTransition(index: Int) -> AnyTransition {
        let delay = Double(2 - index) * 0.04
        return .asymmetric(
            insertion: .scale(scale: 0.5, anchor: .bottomTrailing)
                .combined(with: .opacity)
                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(delay)),
            removal: .scale(scale: 0.5, anchor: .bottomTrailing)
                .combined(with: .opacity)
                .animation(.spring(response: 0.3, dampingFraction: 0.8))
        )
    }

    private func collapseMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isMenuExpanded = false
        }
    }

    private func enterMoveMode() {
        isFollowingUser = false
        isMovingPin = true
        if let spot = viewModel.parkingSpot {
            cameraPosition = .camera(
                MapCamera(centerCoordinate: spot.coordinate,
                          distance: currentDistance)
            )
        }
    }

    private var moveControlBar: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isMovingPin = false
                }
            } label: {
                Text("Cancel")
                    .font(.callout.weight(.semibold))
                    .frame(height: 22)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .buttonBorderShape(.capsule)
            .fixedSize(horizontal: true, vertical: false)
            .accessibilityIdentifier("CancelMoveButton")

            Spacer()

            Button {
                if let center = currentMapCenter {
                    viewModel.updateParkingSpot(to: center)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isMovingPin = false
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Done")
                        .lineLimit(1)
                }
                .font(.callout.weight(.semibold))
                .frame(height: 22)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .buttonBorderShape(.capsule)
            .fixedSize(horizontal: true, vertical: false)
            .accessibilityIdentifier("ConfirmMoveButton")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private var followButton: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                isFollowingUser.toggle()
            }
            if isFollowingUser, let location = viewModel.locationManager.userLocation {
                withAnimation {
                    cameraPosition = .camera(
                        MapCamera(centerCoordinate: location.coordinate,
                                  distance: currentDistance)
                    )
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isFollowingUser ? "location.fill" : "location")
                    .contentTransition(.symbolEffect(.replace.downUp))
                    .symbolEffect(.bounce, value: isFollowingUser)
                if isFollowingUser {
                    Text("Following")
                        .lineLimit(1)
                        .fixedSize()
                        .transition(.scale.combined(with: .move(edge: .leading)))
                }
            }
            .font(.callout.weight(.semibold))
            .frame(height: 22)
            .animation(nil, value: isFollowingUser)
        }
        .buttonStyle(.glass)
        .controlSize(.large)
        .buttonBorderShape(.capsule)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityIdentifier("FollowButton")
    }

}

#Preview {
    ParkingView()
}
