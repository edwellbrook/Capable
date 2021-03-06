<center><img src="https://user-images.githubusercontent.com/1390908/41822361-a14fafd2-77ee-11e8-8aa6-f18960566d0c.png" width="400">
</center>

---
[![Build Status](https://app.bitrise.io/app/7596a076a75ab2ab/status.svg?token=3kpsJB-PR0sBLRF8NYrwhg)](https://www.bitrise.io/app/7596a076a75ab2ab)
![Platforms](https://img.shields.io/cocoapods/p/Capable.svg)
[![Carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![Cocoapods compatible](https://img.shields.io/cocoapods/v/Capable.svg)](https://cocoapods.org/pods/Capable)
![SPM](https://img.shields.io/badge/swift%20package%20manager-macOS-blue.svg)
![Documentation](Documentation/badge.svg)
[![Twitter](https://img.shields.io/badge/twitter-%40chr__wendt-58a1f2.svg)](https://twitter.com/chr_wendt)

Have you ever thought about adopting accessibility features within you apps to gain your user base instead of spending a lot of time implementing features no-one really ever asked for? 

Most of us did, however there has never been an easy way to tell if anyone benefits from that. Adjusting layouts to be usable for people with low vision can be quite complex in some situations and tracking the user's accessibility settings adds a lot of boilerplate code to your app.

What if there was a simple way to figure out if there's a real need to support accessibility right now. Or even better, which disability exists most across your user base.

Check out the *Example.xcworkspace* to get a quick overview.

## Features

* [Get the user's accessibility settings](#accessibility-status)
* [Define handicaps by grouping accessibility features](#handicaps)
* [Send status with your favorite analytics SDK](#send-status)
* [Get notified about any changes](#notifications)
* [Use dynamic type with custom fonts](#dynamic-type)

## Installation

There are currently four different ways to integrate Capable into your apps.

### CocoaPods

```ruby
use_frameworks!

target 'MyApp' do
  pod 'Capable'
end
```

### Carthage

```ruby
github "chrs1885/Capable"
```

### Swift Package Manager (macOS)

```ruby
dependencies: [
    .package(url: "https://github.com/chrs1885/Capable.git", from: "0.1.0")
]
```

### Manually

Simply drop `Capable.xcodeproj` into your project. Also make sure to add
`Capable.framework` to your app’s embedded frameworks found in the General tab of your main project.

## Usage

### Register for (specific) accessibility settings

Firstly, you need to import the Capable framework in your class by adding the following import statement:

```swift
import Capable
```

There are two different ways to initialize the framework instance. You can either set it up to consider all accessibility features

```swift
let capable = Capable()
```

or by passing in only specific feature names

```swift
let capable = Capable(with: [.largerText, .boldText, .shakeToUndo])
```

You can find a list of all accessibility features available on each platform in the [accessibility feature overview](#accessibility-feature-overview) section.

<a id="accessibility-status"></a> 
### Get accessibility status

If you are interested in a specific accessibility feature, you can retrieve its current status as follows:

```swift
let capable = Capable()
let isVoiceOverEnabled: Bool = capable.isFeatureEnable(feature: .voiceOver)
```

To get a dictionary of all features, that the `Capable` instance has been initialized with you can use:

```swift
let capable = Capable()
let statusMap = capable.statusMap
```
This will return each feature name (key) along with its current value as described in the [accessibility feature overview](#accessibility-feature-overview) section.

<a id="handicaps"></a> 
### Handicaps - grouped accessibility features

You can also group accessibility features to represent a specific handicap:

```swift
// Define a set of features that represent a handicap
let features: [CapableFeature] = [.voiceOver, .speakScreen, .speakSelection]

// Use the Handicap object to group them
let blindness = Handicap(with: features, name: "Blindness", enabledIf: .allFeaturesEnabled)

// Initialize the framework instance by providing the Handicap
let capable = Capable(withHandicaps: [blindness])
```

The value of the `name` parameter will be used inside the `statusMap` provided by the Capable framework instance. Based on the value of `enabledIf`, you can specify if all features need to be set to **enabled** in order to set the Handicap to **enabled** as well.
 
As accessibility feature, the `Handicap` type works great with [notifications](#notifications). 

<a id="send-status"></a> 
### Send accessibility status

The `statusMap` object is compatible with most analytic SDK APIs. Here's a quick example of how to send your data along with user properties or custom events.

```swift
func sendMetrics() {
    let statusMap = self.capable.statusMap
    let eventName = "Capable features received"
    
    // App Center
    MSAnalytics.trackEvent(eventName, withProperties: statusMap)
    
    // Firebase
    Analytics.logEvent(eventName, parameters: statusMap)
    
    // Fabric
    Answers.logCustomEvent(withName: eventName, customAttributes: statusMap)
}
```

<a id="notifications"></a> 
### Listen for settings changes

After initialization, notifications for all features that have been registered can be retrieved. To react to changes, you need to add your class as an observer as follows:

```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(self.featureStatusChanged),
    name: .CapableFeatureStatusDidChange,
    object: nil)
```

Inside your `featureStatusChanged` you can parse the specific feature and value:

```swift
@objc private func featureStatusChanged(notification: NSNotification) {
    if let featureStatus = notification.object as? FeatureStatus {
        let feature = featureStatus.feature
        let currentValue = featureStatus.statusString
    }
}
```

If your framework instance has been set up with `Handicap`s instead, you can use the `CapableHandicapStatusDidChange ` notification:

```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(self.handicapStatusChanged),
    name: .CapableHandicapStatusDidChange,
    object: nil)
```

Once the notification has been sent, you can parse the `Handicap`and its current status as follows:

```swift
@objc private func handicapStatusChanged(notification: NSNotification) {
    if let handicapStatus = notification.object as? HandicapStatus {
        let handicap = handicapStatus.handicap
        let currentValue = handicapStatus.statusString
    }
}
```

Please note that when using notifications with `Handicap`s on macOS or watchOS, you might not get notified about all changes since [not all accessibility features do support notifications](#feature-overview), yet. 

<a id="dynamic-type"></a> 
### Dynamic Type with custom fonts (Capable UIFont extension)

Supporting Dynamic Type along with different OS versions such as iOS 10 and iOS 11 (watchOS 3 and watchOS 4) can be a huge pain, since both versions provide different APIs.

Capable easily auto scales system fonts as well as your custom fonts by providing one line of code:

```swift
let myLabel = UILabel(frame: frame)

// Scalable custom font
let myCustomFont = UIFont(name: "Custom Font Name", size: defaultFontSize)!
myLabel.font = UIFont.scaledFont(for: myCustomFont)

// or
myLabel.font = UIFont.scaledFont(name: "Custom Font Name", size: defaultFontSize)

// Scalable system font
myLabel.font = UIFont.scaledSystemFont(ofSize: defaultFontSize)

// Scalable italic system font
myLabel.font = UIFont.scaledItalicSystemFont(ofSize: defaultFontSize)

// Scalable bold system font
myLabel.font = UIFont.scaledBoldSystemFont(ofSize: defaultFontSize)
```

While these extension APIs are available on tvOS as well, setting the font size in the system settings is not supported on this platforms.

<a id="feature-overview"></a> 
## Accessibility feature overview

The following table contains all features that are available AND settable on each platform.

|                            | iOS                | macOS                          | tvOS               | watchOS                        |
| -------------------------- |:------------------:| :-----------------------------:| :-----------------:| :-----------------------------:|
| .assistiveTouch            | :white_check_mark: |                                |                    |                                |
| .boldText                  | :white_check_mark: |                                | :white_check_mark: | &nbsp;:white_check_mark:**\*** |
| .closedCaptioning          | :white_check_mark: |                                | :white_check_mark: |                                |
| .darkerSystemColors        | :white_check_mark: |                                |                    |                                |
| .differentiateWithoutColor |                    | &nbsp;:white_check_mark:**\*** |                    |                                |
| .grayscale                 | :white_check_mark: |                                | :white_check_mark: |                                |
| .guidedAccess              | :white_check_mark: |                                |                    |                                |
| .increaseContrast          |                    | &nbsp;:white_check_mark:**\*** |                    |                                |
| .invertColors              | :white_check_mark: | &nbsp;:white_check_mark:**\*** | :white_check_mark: |                                |
| .largerText                | :white_check_mark: |                                |                    | &nbsp;:white_check_mark:**\*** |
| .monoAudio                 | :white_check_mark: |                                | :white_check_mark: |                                |
| .reduceMotion              | :white_check_mark: | &nbsp;:white_check_mark:**\*** | :white_check_mark: | :white_check_mark:             |
| .reduceTransparency        | :white_check_mark: | &nbsp;:white_check_mark:**\*** | :white_check_mark: |                                |
| .shakeToUndo               | :white_check_mark: |                                |                    |                                |
| .speakScreen               | :white_check_mark: |                                |                    |                                |
| .speakSelection            | :white_check_mark: |                                |                    |                                |
| .switchControl             | :white_check_mark: | &nbsp;:white_check_mark:**\*** | :white_check_mark: |                                |
| .voiceOver                 | :white_check_mark: | &nbsp;:white_check_mark:**\*** | :white_check_mark: | :white_check_mark:             |

*\* Feature status can be read but notifications are not available.*

While most features can only have a status set to **enabled** or **disabled**, the `.largerText` feature offers the font scale set by the user:

### iOS

* XS
* S
* M *(default)*
* L
* XL
* XXL
* XXXL
* Accessibility M
* Accessibility L
* Accessibility XL
* Accessibility XXL
* Accessibility XXXL
* Unknown

### watchOS
* XS
* S *(default watch with 38mm)*
* L *(default watch with 42mm)*
* XL
* XXL
* XXXL
* Unknown

## Ressources

* [Apple - WWDC Session Videos](https://developer.apple.com/videos/frameworks/accessibility/
)
* [Apple - Accessibility for Developers](https://developer.apple.com/accessibility/)

## License

Capable is available under the MIT license. See the [LICENSE](LICENSE) file for more info.