fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Runs all the tests

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date

### ios increment

```sh
[bundle exec] fastlane ios increment
```

Increment the build number and Commit

### ios betaInternal

```sh
[bundle exec] fastlane ios betaInternal
```

Submit a new Beta Build to Apple TestFlight, submit for review and release to internal testers

This will also make sure the profile is up to date

### ios betaRelease

```sh
[bundle exec] fastlane ios betaRelease
```

Submit a new Beta Build to Apple TestFlight, submit for review and release to all testers

This will also make sure the profile is up to date

### ios release

```sh
[bundle exec] fastlane ios release
```

Deploy a new version to the App Store

### ios download_metadata

```sh
[bundle exec] fastlane ios download_metadata
```

Deploy Metadata and screenshots from the App Store

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload Metadata to App Store

### ios bump

```sh
[bundle exec] fastlane ios bump
```

Update version with given type (patch|minor|major). Called as: fastlane bump type:minor

### ios upload_testers

```sh
[bundle exec] fastlane ios upload_testers
```

Upload testers file to TestFlight

### ios download_testers

```sh
[bundle exec] fastlane ios download_testers
```

Download testers file to TestFlight

### ios deviceRegistration

```sh
[bundle exec] fastlane ios deviceRegistration
```

Push ./devices.txt to register new devices and create a new profile accordingly

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Force autocorrect using swiftlint

### ios commit_increment

```sh
[bundle exec] fastlane ios commit_increment
```

Commit and push the build number increase

### ios commit_all_changes

```sh
[bundle exec] fastlane ios commit_all_changes
```

Commit and push all changes in the working directory to the specified branch

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
