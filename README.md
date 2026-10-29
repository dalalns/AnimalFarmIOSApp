# Farmstead iOS app

Farmstead is a native SwiftUI starter app for keeping farm animal records, tracking product stock, and recording sales. Data is stored locally on the device.

## Open and run

1. Open `FarmManager.xcodeproj` in Xcode on a Mac.
2. Select the `FarmManager` scheme and an iOS simulator or connected device.
3. If running on a device, select your Apple development team under **Signing & Capabilities**.
4. Build and run.

The project targets iOS 17 or later. This workspace was prepared on Windows, so an Xcode build and simulator run could not be performed here.

## Build on GitHub

The GitHub Actions workflow in `.github/workflows/ios-build.yml` builds the iOS Simulator app on a macOS runner whenever you push or open a pull request. You can also start a build from the repository's **Actions** tab using **iOS Build** → **Run workflow**.

After a successful run, download the `FarmManager-iOS-Simulator` artifact from that run's summary. It contains a simulator `.app` bundle for testing in the iOS Simulator; it is not signed for installation on a physical iPhone or for App Store distribution.

The same workflow runs the `FarmManagerTests` unit-test target on an available iPhone simulator before uploading the app. The tests cover sale inventory updates, invalid sale quantities, and restoring saved farm data. You can also run them from Xcode on a Mac by selecting the `FarmManager` scheme and choosing **Product > Test**.

To use GitHub's free standard runner allowance for public repositories, make the repository public. Check GitHub's current Actions usage and billing terms before relying on free builds, especially for private repositories.
