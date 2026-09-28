# Native welcome buttons

`WelcomeActionButton` embeds the `habitacheck/welcome_button` UIKit platform view only in the installed iOS app. Web (including Safari on iOS) and other targets use the Flutter button with entrance, press, focus, and hover animations.

Build with Xcode 26 or later and run on iOS 26 or later to use `UIButton.Configuration.prominentGlass()` for registration and `.glass()` for sign-in. The system supplies Liquid Glass rendering and interaction. Older SDKs/runtimes fall back to UIKit filled/tinted controls (or classic UIButton on iOS 13/14), with a small spring press effect. No new package is required.

The two actions use isolated method channels; labels, text size, and Reduce Motion updates are forwarded to UIKit. Controls retain native VoiceOver semantics and light haptic feedback. Flutter buttons remain usable with keyboard and pointer; canceled presses do not navigate.

## Device verification

On a Mac, build the Runner target with Xcode 26+, then check an iOS 26 simulator or iPhone:

1. Open the welcome screen and press both buttons: check the native glass interaction and the registration/login destinations without submitting either form.
2. Check VoiceOver, increased text size, Reduce Motion, Reduce Transparency, and light/dark system appearance.
3. Repeat on an older iOS runtime to verify UIKit fallback controls.

The Dart bridge and Flutter interaction tests run on Windows. The UIKit implementation requires this Mac/iPhone check; Windows cannot compile or render iOS controls.

References: [Apple glass buttons](https://developer.apple.com/documentation/uikit/uibutton/configuration-swift.struct/glass()) and [Flutter iOS platform views](https://docs.flutter.dev/platform-integration/ios/platform-views).
