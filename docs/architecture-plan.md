# SleepPath — Architecture Plan

**Version:** 1.0
**Date:** March 17, 2026
**Status:** Active Development
**Working Name:** SleepPath

---

## 1. Overview

SleepPath is a circadian rhythm and chronotype app that helps users optimize their daily schedule based on their biological patterns. The product has two components:

1. **Web Quiz Funnel** — A static HTML/CSS marketing page with a chronotype quiz that serves as the primary acquisition channel
2. **iOS App** — A native Swift/SwiftUI app that delivers the adaptive daily trajectory powered by HealthKit data

This document defines the architecture for both components and how they connect.

---

## 2. Repository Structure

```
sleep/
├── docs/                           # Documentation
│   ├── sleep-app-mvp-spec-v1.md   # Product specification
│   ├── architecture-plan.md        # This document
│   └── ios-best-practices.md       # iOS development guide
│
├── web/                            # Static marketing site
│   ├── index.html                  # Single-page marketing site + quiz
│   ├── styles.css                  # All styles (no framework)
│   ├── quiz.js                     # Quiz logic and chronotype calculation
│   └── assets/                     # Images, icons, fonts
│
├── ios/                            # Native iOS app
│   └── SleepPath/
│       ├── SleepPath.xcodeproj     # Xcode project
│       ├── SleepPath/              # Main app target
│       │   ├── App/                # App entry point, configuration
│       │   ├── Models/             # Data models and enums
│       │   ├── Views/              # SwiftUI views organized by feature
│       │   │   ├── Onboarding/     # Quiz, welcome, permissions
│       │   │   ├── Today/          # Home tab — energy state, timeline
│       │   │   ├── Patterns/       # Insights tab — charts, summaries
│       │   │   ├── Settings/       # Settings tab
│       │   │   └── Components/     # Reusable UI components
│       │   ├── ViewModels/         # ObservableObject view models
│       │   ├── Services/           # Business logic services
│       │   │   ├── ChronotypeEngine.swift
│       │   │   ├── TrajectoryService.swift
│       │   │   ├── MockDataService.swift
│       │   │   └── NotificationService.swift
│       │   ├── Data/               # Persistence layer
│       │   │   ├── Models/         # SwiftData models
│       │   │   └── MockData.swift  # Static mock data for prototype
│       │   ├── Extensions/         # Swift extensions
│       │   └── Resources/          # Assets, colors, fonts
│       │       └── Assets.xcassets
│       └── SleepPathTests/         # Unit and UI tests
│           ├── ModelTests/
│           ├── ViewModelTests/
│           ├── ServiceTests/
│           └── ViewTests/
│
└── README.md                       # Project README
```

---

## 3. Technology Decisions

### 3.1 iOS App

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Language** | Swift 5.10+ | Native performance, full Apple API access |
| **UI Framework** | SwiftUI | Modern declarative UI, great for rapid iteration |
| **Data Persistence** | SwiftData | Apple's modern persistence framework, built on Core Data |
| **Architecture** | MVVM | Clean separation, testable view models, SwiftUI-native pattern |
| **Minimum iOS** | iOS 17.0 | SwiftData requires iOS 17, modern API access |
| **Health Data** | HealthKit | Native Apple health data framework |
| **Notifications** | UserNotifications | Native push notification framework |
| **Calendar** | EventKit | Native calendar integration |
| **Charts** | Swift Charts | Apple's native charting framework |
| **Testing** | XCTest + Swift Testing | Unit tests, view model tests, UI snapshot tests |
| **Dependency Management** | Swift Package Manager | No third-party dependencies for MVP |

### 3.2 Web Marketing Page

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Approach** | Static HTML/CSS/JS | No build step, fast loading, easy to deploy anywhere |
| **Styling** | Custom CSS | Minimal footprint, full design control |
| **Hosting** | Any static host | GitHub Pages, Netlify, Vercel, or S3 |
| **Analytics** | Defer | Can add PostHog later |

### 3.3 Future API (Not in MVP Prototype)

When the app moves beyond mock data, a lightweight API will be needed for:
- Web quiz session storage and app handoff
- Email capture and nurture sequence triggering
- Shareable card generation (server-side image rendering)

Recommended stack (from tech-stack-ideal.md): **FastAPI + PostgreSQL** deployed on Render.com.

---

## 4. iOS App Architecture

### 4.1 MVVM Pattern

```
View (SwiftUI)
  ↕ binds to
ViewModel (@Observable)
  ↕ calls
Service (business logic)
  ↕ reads/writes
Data (SwiftData / Mock)
```

### 4.2 Key View Models

| ViewModel | Responsibility |
|-----------|---------------|
| `OnboardingViewModel` | Quiz flow state, chronotype calculation, onboarding progress |
| `TodayViewModel` | Current energy state, trajectory for today, quick actions |
| `PatternsViewModel` | Sleep consistency data, insights, weekly summaries |
| `SettingsViewModel` | User preferences, connections, notification toggles |

### 4.3 Key Services

| Service | Responsibility |
|---------|---------------|
| `ChronotypeEngine` | Calculate chronotype from quiz answers, map to schedule offsets |
| `TrajectoryService` | Generate daily trajectory from chronotype + sleep data |
| `MockDataService` | Provide realistic mock data for the prototype phase |
| `NotificationService` | Schedule and manage local notifications |

### 4.4 Data Flow (MVP with Mock Data)

```
App Launch
  → MockDataService provides pre-built user profile + 30 days of sleep data
  → ChronotypeEngine calculates chronotype from mock quiz answers
  → TrajectoryService generates today's trajectory
  → TodayViewModel publishes to TodayView
  → PatternsViewModel computes insights from mock sleep history
```

### 4.5 Mock User Account

For the prototype, a pre-configured mock user is built in:

- **Name:** Alex
- **Chronotype:** Wolf 🐺
- **HealthKit:** Connected (simulated with mock data)
- **Data:** 30 nights of realistic sleep data
- **Caffeine logs:** Varied patterns showing impact
- **Subscription:** Pro (all features unlocked)

No login required — the app launches directly into the home screen with the mock user's data.

---

## 5. Web Marketing Page Architecture

### 5.1 Page Structure

Single-page site with smooth scroll sections:

1. **Hero** — Headline, subheadline, CTA button
2. **How It Works** — 3-step explanation with icons
3. **Chronotype Preview** — Show the 4 chronotypes with brief descriptions
4. **Features** — Key app features with visuals
5. **Quiz CTA** — Prominent section driving to quiz (in-page or separate flow)
6. **App Store CTA** — Download links (placeholder for now)
7. **Footer** — Links, legal, branding

### 5.2 Design Language

- **Colors:** Deep navy/indigo (#1a1a2e) backgrounds, warm amber/gold (#f0a500) accents, soft gradients
- **Typography:** System font stack (SF Pro Display feel), clean sans-serif
- **Mood:** Calm, premium, scientific but approachable
- **Responsive:** Mobile-first, works on all screen sizes

---

## 6. Chronotype Calculation Algorithm

The quiz maps answers to a numerical score on the morningness-eveningness spectrum:

```
Score Range → Chronotype
0-7        → Lion 🦁 (early bird, peak morning)
8-14       → Bear 🐻 (follows solar cycle, peak late morning)
15-21      → Wolf 🐺 (night owl, peak afternoon/evening)
22+        → Dolphin 🐬 (irregular sleep, light sleeper)
```

Each answer contributes 0-3 points toward the eveningness end. Special rules for Dolphin detection (irregular sleep patterns, slow sleep onset).

---

## 7. Trajectory Generation

Each chronotype has base offsets from wake time:

| Event | Lion | Bear | Wolf | Dolphin |
|-------|------|------|------|---------|
| Sunlight window | wake+15min | wake+15min | wake+15min | wake+15min |
| Caffeine OK | wake+90min | wake+90min | wake+90min | wake+120min |
| Peak Focus 1 | wake+2h | wake+3h | wake+5h | wake+3h |
| Peak Focus 2 | wake+8h | — | wake+10h | — |
| Energy Dip | wake+6h | wake+6h | wake+8h | wake+5h |
| Caffeine Cutoff | sleep-8h | sleep-8h | sleep-8h | sleep-10h |
| Digital Sunset | sleep-2h | sleep-2h | sleep-2h | sleep-2h |
| Wind-Down | sleep-45min | sleep-45min | sleep-45min | sleep-60min |

---

## 8. Testing Strategy

### 8.1 Unit Tests
- All model logic (chronotype calculation, trajectory generation, confidence scoring)
- All view model state transitions
- Date/time calculations and edge cases

### 8.2 View Tests
- SwiftUI preview snapshots for each screen state
- Accessibility label verification
- Dark mode rendering

### 8.3 Integration Tests
- Full onboarding flow state machine
- Mock data service → view model → expected UI state
- Notification scheduling correctness

### 8.4 Coverage Target
- Models: >90%
- ViewModels: >85%
- Services: >90%
- Views: Preview coverage for all states

---

## 9. MVP Prototype Scope

This prototype delivers a **fully clickable iOS app** with mock data that demonstrates the complete user experience:

### Included
- [x] Complete onboarding quiz flow
- [x] Chronotype result with animal + description
- [x] Today tab with energy state, timeline, quick actions
- [x] Patterns tab with sleep charts and insights
- [x] Settings tab with all preference controls
- [x] Beautiful, polished SwiftUI interface
- [x] Dark mode support
- [x] Comprehensive unit tests

### Deferred (Real Implementation)
- [ ] HealthKit integration (mock data simulates this)
- [ ] Push notifications (UI shown, actual scheduling deferred)
- [ ] StoreKit subscription (paywall UI built, no real IAP)
- [ ] Apple Watch companion
- [ ] Calendar export (EventKit)
- [ ] Backend API and web quiz handoff
- [ ] App Store submission

---

## 10. Development Phases

### Phase 1: Foundation (Current)
1. Project structure and Xcode project setup
2. Data models and mock data
3. Chronotype engine and trajectory service
4. Core views (Today, Patterns, Settings)
5. Onboarding flow
6. Unit tests
7. Static marketing page

### Phase 2: Polish
1. Animations and transitions
2. Dark mode refinement
3. Accessibility audit
4. Performance optimization

### Phase 3: Real Data Integration
1. HealthKit service (replace mock data)
2. SwiftData persistence (replace in-memory)
3. Push notification scheduling
4. Backend API for web quiz handoff
