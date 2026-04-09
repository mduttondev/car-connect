# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this app is

Car-Connect is a SwiftUI iOS app with two tabs:

1. **Parking** — a full-screen map with a follow-me button and a Save/Clear button that drops a pin on the user's car location and persists it across launches.
2. **Meter** — set how long until a parking meter expires and how soon before expiration to get a local notification reminder.

The app was migrated from UIKit/Storyboards. Deleted UIKit code (`ParkingViewController`, `ParkingMeterViewController`, etc.) may still be referenced in older commits for historical context.

- **Deployment target:** iOS 26.0 (uses Liquid Glass button styles, `Map(position:) { Annotation }`, SF Symbol `.replace.downUp`).
- **Dependencies:** FirebaseAnalytics + FirebaseCrashlytics via SPM, configured in `Car_ConnectApp.init`. `GoogleService-Info.plist` is in the app bundle.
- **Default branch:** `master`. Active SwiftUI migration work lives on `Update_to_SwiftUI`.

## Build / run / test

```bash
# Build the app for the simulator
xcodebuild -project Car-Connect.xcodeproj -scheme Car-Connect \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run all unit + UI tests
xcodebuild test -project Car-Connect.xcodeproj -scheme Car-Connect \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run a single test
xcodebuild test -project Car-Connect.xcodeproj -scheme Car-Connect \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -only-testing:Car-ConnectUITests/Car_ConnectUITests/testParkingFlowWithSimulatedGPXRoute

# Install + launch on a booted simulator manually
xcrun simctl install "iPhone 17 Pro" path/to/Car-Connect.app
xcrun simctl launch "iPhone 17 Pro" com.mkdutton.Car-Connect
```

Fastlane lanes (in `fastlane/Fastfile`) cover release automation: `fastlane test`, `fastlane beta`, `fastlane betaInternal`, `fastlane release`, `fastlane lint` (SwiftLint autocorrect), `fastlane bump type:patch|minor|major`. Fastlane uses `match` for code signing and `pilot`/`deliver` for TestFlight/App Store upload.

## Adding / removing files

The project uses **Xcode 16+ file system synchronized groups** (`PBXFileSystemSynchronizedRootGroup`). Each target (`Car-Connect`, `Car-ConnectTests`, `Car-ConnectUITests`) is a single sync root pointed at its matching top-level folder.

**You do not need to touch `project.pbxproj` to add, remove, rename, or move files.** Just drop files into the folder, and Xcode auto-discovers them based on file type (`.swift` → Sources, `.xcassets`/`.gpx`/`.plist`/`.storyboard` → Resources). The same applies in reverse — delete a file from disk and it vanishes from the build.

If you need a file to have non-default membership (e.g. exclude from a specific target, or custom compiler flags), add a `PBXFileSystemSynchronizedBuildFileExceptionSet` to the target — that's the one place pbxproj still matters.

## Architecture

### Parking state flow (the thing that bit us before)

The parking-spot feature has one canonical source of truth: `ParkingViewModel.parkingSpot`. **Do not** reintroduce parallel state for the pin (e.g. a separate `@State` annotation array or an `@AppStorage` mirror). An earlier version had both `@AppStorage` and a `@State [ParkingLocation]` array that were seeded only in `.onAppear`; tapping Save updated one but not the other, causing a "whole map reloads instead of animating the pin drop" bug. The current architecture drives the `Map`'s `Annotation` directly off `viewModel.parkingSpot` and persists through `StorageHandler` exclusively.

```
ParkingView  ─── @StateObject ───▶  ParkingViewModel
                                       │
                                       ├── parkingSpot: ParkingLocation?   ← published
                                       ├── locationManager: LocationManager ← owned
                                       └── save()/clear() → StorageHandler (UserDefaults JSON)
```

`ParkingView` subscribes to `locationManager.$userLocation` via `onReceive` (not `onChange`, because `CLLocation` is not `Equatable`) to drive the `MapCameraPosition` when the follow button is engaged, and subscribes to `$authorizationStatus` to surface a "Location Access Needed" alert with an "Open Settings" button.

### LocationManager

`LocationManager` is `@MainActor final class` with `nonisolated` `CLLocationManagerDelegate` methods that hop back to main via `Task { @MainActor in ... }`. It has **two designated initializers**:

1. `init()` — production, real `CLLocationManager`.
2. `init(simulatedLocations:interval:)` — **test-only**. Feeds a fixed sequence of `CLLocation`s on a timer, never touches CoreLocation, never triggers the permission dialog. The first location publishes synchronously so tests aren't racy.

`ParkingViewModel.init` checks `ProcessInfo.processInfo.environment["UITEST_GPX"]` and, if present, loads the named GPX from the main bundle via `GPXLoader` (a small `XMLParser`-backed reader in `LocationManager.swift`) and wires up the simulated init instead. This is the entire "inject a mock location provider" strategy — keep it this way; do not add a protocol or DI container unless there's a second consumer.

### Meter feature

`MeterView` + `MeterViewModel` live in `Car-Connect/MeterView/MeterView.swift` along with a private `DurationPickerSheet` (wheel hours + minutes) and `StatusRow` component.

Semantics the user explicitly specified (differs from the old UIKit version — be careful if porting old logic):

- Meter expiration is an **absolute date** = `now + userPickedInterval`.
- Reminder lead time is specified by the user (e.g. "10 minutes before"). The notification fires at `meterExpiration − leadTime`, **anchored to the meter expiration** — NOT `now + leadTime` like the old UIKit code did.
- Setting a new meter expiration automatically clears any stale reminder.
- If the lead time is longer than the remaining meter time, scheduling fails with `.leadTimeTooLong` and surfaces an error alert.

Persistence: two absolute `Date` values in `UserDefaults` via `StorageHandler` — `meterExpirationKey` and `reminderFireDateKey`. Both are plain `Date` objects (not JSON-encoded).

Notifications: single `UNNotificationRequest` with identifier `"MeterReminder"`. Scheduled via `UNTimeIntervalNotificationTrigger` with `max(1, fireDate.timeIntervalSinceNow)`. Rescheduling removes the old one first. Permission is requested on-demand (when the user taps to set a reminder), not at launch — on denial, shows an "Open Settings" alert.

Live countdown: `Timer.publish(every: 1, on: .main, in: .common).autoconnect()` drives `viewModel.tick()` which calls `objectWillChange.send()`. `MeterStatus` / `ReminderStatus` are computed properties, not published state.

### Persistence

`StorageHandler` is the only place that touches `UserDefaults`. **Do not** reintroduce `@AppStorage` for any of these keys — an earlier version had an `Optional: RawRepresentable where Wrapped: Codable` retroactive conformance to make `@AppStorage` work with a `Codable` optional. That conformance was removed because (a) it's a retroactive conformance on a stdlib type and will break if Apple or another module adds the same one, and (b) it stored a `String` under the same key that `StorageHandler` stored `Data` under, silently clobbering saved spots.

Keys live in `Constants.DefaultsKey`:
- `locationKey` — parking spot (JSON-encoded `ParkingLocation`).
- `meterExpirationKey` — absolute `Date`.
- `reminderFireDateKey` — absolute `Date`.

`ParkingLocation` has a `CodingKeys` back-compat shim that accepts both `longitude` (current) and `lonitude` (typo'd key from older builds). Keep this — removing it will lose users' saved spots on upgrade.

### UI test hook convention

Tests launch the app with:
- `launchArguments = ["-UITEST_RESET"]` — `Car_ConnectApp.init` clears the parking-spot, meter-expiration, and reminder UserDefaults keys AND calls `UNUserNotificationCenter.current().removeAllPendingNotificationRequests()` so the test starts from a known state.
- `launchEnvironment = ["UITEST_GPX": "<gpx-filename-without-extension>"]` — routes location through the simulated `LocationManager`.

GPX files live in `Car-Connect/Location GPX Files/` (`ArchivesToEllipse.gpx`, `National Archives.gpx`, `The Ellipse.gpx`). Since the project uses synchronized groups, dropping a new `.gpx` into that folder automatically bundles it — just reference it by filename (no extension) from the test.

Accessibility identifiers are the stable contract for UI tests:
- **Parking:** `SaveParkingSpotButton` / `ClearParkingSpotButton` (changes with state so tests can `waitForExistence` on the expected one), `FollowButton`.
- **Meter:** `MeterRow`, `ReminderRow`, `ClearMeterButton`, `SetDurationButton` (on the picker sheet's confirm button).

### Project layout notes

- The scheme is `Car-Connect` (shared) in `Car-Connect.xcodeproj/xcshareddata/xcschemes/`.
- `IPHONEOS_DEPLOYMENT_TARGET = 26.0` across all configurations. **Do not bump down** — the Liquid Glass button styles (`.buttonStyle(.glass)` / `.glassProminent`) require iOS 26+, and the Map/SF Symbol APIs require iOS 17+. Dropping below 26 means rewriting the button styles too.
- `objectVersion = 77`, `compatibilityVersion = "Xcode 16.0"`. This is what enables synchronized groups.

## Conventions

- **Buttons:** use native iOS 26 Liquid Glass — `.buttonStyle(.glass)` for secondary controls, `.buttonStyle(.glassProminent)` for primary actions. Combine with `.buttonBorderShape(.capsule)` + `.controlSize(.large)` for the floating control style. **Do not** reintroduce custom `ButtonStyle` with hand-drawn backgrounds and strokes.
- **Button state animations:** SF Symbol swaps use `.contentTransition(.symbolEffect(.replace.downUp))` + `.symbolEffect(.bounce, value:)`. Text labels that change with state get `.animation(nil, value:)` to prevent a mid-transition crossfade looking translucent. Wrap state changes in `withAnimation(.spring(response: 0.4, dampingFraction: 0.65))`.
- **Retroactive conformances:** don't. Earlier code had `Optional: RawRepresentable` and `CLLocationCoordinate2D: Equatable` — both were removed in favor of wrappers / inline comparisons.
- **Firebase:** configured once in `Car_ConnectApp.init()` via `FirebaseApp.configure()`. No `UIApplicationDelegateAdaptor`.
