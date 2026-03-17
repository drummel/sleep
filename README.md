# SleepPath

> Your biology has a schedule. Start following it.

SleepPath is a circadian rhythm and chronotype app that helps users discover their chronotype (Lion, Bear, Wolf, or Dolphin) and get a personalized daily schedule that adapts to their real sleep data.

## Repository Structure

```
sleep/
├── docs/                    # Documentation
│   ├── sleep-app-mvp-spec-v1.md    # Full product specification
│   ├── architecture-plan.md         # Architecture & tech decisions
│   └── ios-best-practices.md        # iOS development guide
├── web/                     # Static marketing website
│   ├── index.html           # Single-page marketing site
│   └── styles.css           # Styles
├── ios/                     # Native iOS app
│   └── SleepPath/           # Xcode project
└── README.md                # This file
```

## Quick Start

### iOS App (Simulator)

**Prerequisites:**
- macOS with Xcode 15+ installed
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

**Setup:**

```bash
cd ios/SleepPath
xcodegen generate
open SleepPath.xcodeproj
```

Then select an iPhone simulator (iPhone 15 Pro recommended) and hit Run (Cmd+R).

**Alternative (without XcodeGen):**

You can also open Xcode, create a new iOS App project named "SleepPath", and drag in all the Swift files from the `SleepPath/` directory. Set the deployment target to iOS 17.0.

### Marketing Website

```bash
cd web
open index.html
# Or use any static file server:
python3 -m http.server 8080
```

## Mock User Account

The app uses built-in mock data for the prototype phase. No login is required.

**Mock User Profile:**
- **Name:** Alex
- **Chronotype:** Wolf 🐺 (Night Owl)
- **HealthKit:** Connected (simulated)
- **Sleep pattern:** ~12:30 AM - 8:00 AM
- **Data:** 30 nights of realistic sleep history
- **Subscription:** Pro (all features unlocked)

The app launches directly into the full experience with pre-populated data. All features are accessible — onboarding can be experienced by resetting the app.

## The Four Chronotypes

| Chronotype | Emoji | Type | Peak Hours |
|-----------|-------|------|------------|
| **Lion** | 🦁 | Early Bird | 8 AM - 12 PM |
| **Bear** | 🐻 | Solar Tracker | 10 AM - 2 PM |
| **Wolf** | 🐺 | Night Owl | 5 PM - 9 PM |
| **Dolphin** | 🐬 | Light Sleeper | Varies |

## Tech Stack

- **iOS App:** Swift 5.10, SwiftUI, SwiftData, iOS 17+
- **Architecture:** MVVM with @Observable
- **Charts:** Swift Charts
- **Marketing Site:** Static HTML/CSS (no dependencies)
- **No third-party dependencies** in the iOS app

## Development

### Running Tests

After generating the Xcode project:

```bash
cd ios/SleepPath
xcodebuild test \
  -scheme SleepPath \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -resultBundlePath TestResults
```

Or use Cmd+U in Xcode.

### Project Structure

The iOS app follows MVVM architecture:

- **Models/** — Data models (SwiftData @Model + plain structs)
- **Views/** — SwiftUI views organized by feature
- **ViewModels/** — @Observable view models
- **Services/** — Business logic (chronotype engine, trajectory generation)
- **Extensions/** — Swift extensions for colors, dates, view modifiers
- **Data/** — Mock data for the prototype

## License

Copyright 2026 Fibonacci Labs. All rights reserved.
