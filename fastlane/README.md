fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios increment
```
fastlane ios increment
```
Increment the build number and Commit
### ios betaInternal
```
fastlane ios betaInternal
```
Submit a new Beta Build to Apple TestFlight, submit for review and release to internal testers

This will also make sure the profile is up to date
### ios betaRelease
```
fastlane ios betaRelease
```
Submit a new Beta Build to Apple TestFlight, submit for review and release to all testers

This will also make sure the profile is up to date
### ios release
```
fastlane ios release
```
Deploy a new version to the App Store
### ios download_metadata
```
fastlane ios download_metadata
```
Deploy Metadata and screenshots from the App Store
### ios upload_metadata
```
fastlane ios upload_metadata
```
Upload Metadata to App Store
### ios bump
```
fastlane ios bump
```
Update version with given type (patch|minor|major). Called as: fastlane bump type:minor
### ios testing
```
fastlane ios testing
```

### ios upload_testers
```
fastlane ios upload_testers
```
Upload testers file to TestFlight
### ios download_testers
```
fastlane ios download_testers
```
Download testers file to TestFlight
### ios deviceRegistration
```
fastlane ios deviceRegistration
```
Push ./devices.txt to register new devices and create a new profile accordingly
### ios commit_increment
```
fastlane ios commit_increment
```
Commit and push the build number increase
### ios commit_all_changes
```
fastlane ios commit_all_changes
```
Commit and push all changes in the working directory to the specified branch

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
