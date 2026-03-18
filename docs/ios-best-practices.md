# SleepPath iOS Best Practices

Guidelines for developing the SleepPath circadian rhythm and chronotype app.

---

## 1. Swift & SwiftUI Conventions

### Naming

- **Types** (structs, classes, enums, protocols): `UpperCamelCase` — `SleepSession`, `ChronotypeAnalyzer`, `SleepPhase`.
- **Properties, methods, variables**: `lowerCamelCase` — `sleepDuration`, `calculateOptimalBedtime()`.
- **Boolean properties**: Read as assertions — `isTracking`, `hasCompletedOnboarding`, `shouldRequestPermission`.
- **Protocols describing capability**: Use `-ing` or `-able` — `SleepDataProviding`, `ChronotypeCalculable`.
- **Protocols describing a role**: Use a noun — `SleepStore`, `HealthDataSource`.
- **Enum cases**: `lowerCamelCase` — `.morningLark`, `.nightOwl`, `.intermediate`.
- **Constants**: Same as properties, not `SCREAMING_CASE` — `let defaultSleepGoalHours = 8.0`.

### File Organization

```
SleepPath/
  App/
    SleepPathApp.swift
    AppConstants.swift
  Models/
    SleepSession.swift
    Chronotype.swift
    CircadianRhythm.swift
  ViewModels/
    SleepLogViewModel.swift
    ChronotypeViewModel.swift
    OnboardingViewModel.swift
  Views/
    Sleep/
      SleepLogView.swift
      SleepDetailView.swift
      SleepChartView.swift
    Onboarding/
      OnboardingContainerView.swift
      ChronotypeQuizView.swift
    Components/
      SleepRingView.swift
      TimePickerView.swift
  Services/
    HealthKitService.swift
    NotificationService.swift
    SleepAnalysisService.swift
  Utilities/
    Date+Extensions.swift
    Color+SleepPath.swift
  Resources/
    Assets.xcassets
    Localizable.xcstrings
```

One primary type per file. Name files after the type they contain.

### SwiftUI View Composition

Keep views small. Extract any piece of UI that has its own logical purpose or exceeds ~30 lines.

```swift
// Good — extracted subview
struct SleepLogView: View {
    @State private var viewModel = SleepLogViewModel()

    var body: some View {
        ScrollView {
            SleepSummaryCard(summary: viewModel.todaySummary)
            SleepHistoryChart(entries: viewModel.recentEntries)
            SleepRecommendationBanner(recommendation: viewModel.recommendation)
        }
    }
}

// Bad — monolithic body with inline layout for every section
```

Private subviews within the same file are fine for small helpers:

```swift
private struct SleepMetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).bold()
        }
    }
}
```

### @Observable vs @ObservableObject

Use `@Observable` (Observation framework, iOS 17+). Do not use `@ObservableObject`/`@Published` in new code.

```swift
// Correct
@Observable
final class SleepLogViewModel {
    var sessions: [SleepSession] = []
    var isLoading = false
}

// In the view
struct SleepLogView: View {
    @State private var viewModel = SleepLogViewModel()
    // ...
}
```

### State Management

| Wrapper | Use When |
|---|---|
| `@State` | View-local value type state, or owning an `@Observable` object |
| `@Binding` | Child view needs read/write access to parent's state |
| `@Environment` | Injecting shared services, model context, color scheme, etc. |
| `@Bindable` | Creating bindings from an `@Observable` object |

Avoid `@EnvironmentObject` in new code — use `@Environment` with custom keys or pass `@Observable` objects directly.

---

## 2. MVVM Architecture

### ViewModel Design

```swift
@Observable
final class ChronotypeViewModel {
    // MARK: - Published State
    var currentChronotype: Chronotype?
    var quizProgress: Double = 0
    var errorMessage: String?

    // MARK: - Dependencies
    private let analysisService: SleepAnalysisProviding
    private let healthKitService: HealthDataProviding

    init(
        analysisService: SleepAnalysisProviding = SleepAnalysisService(),
        healthKitService: HealthDataProviding = HealthKitService.shared
    ) {
        self.analysisService = analysisService
        self.healthKitService = healthKitService
    }

    // MARK: - Actions
    func submitQuizAnswer(_ answer: QuizAnswer) {
        // Business logic here, not in the view
    }

    func calculateChronotype() async {
        // Async work lives here
    }
}
```

### Rules

- **Views are layout only.** They read state and call ViewModel methods. No `if/else` business logic, no date math, no data transformation beyond simple formatting.
- **ViewModels own all logic.** Validation, data transformation, API coordination, error handling.
- **Services are injected.** Pass protocols via `init` (preferred for testability) or `@Environment` for app-wide singletons.
- **ViewModels never import SwiftUI.** They should depend only on Foundation, Observation, and domain modules. Exception: returning `LocalizedStringResource` or similar SwiftUI-adjacent types is acceptable.

---

## 3. SwiftData Best Practices

### Model Design

```swift
@Model
final class SleepSession {
    var startDate: Date
    var endDate: Date
    var quality: SleepQuality
    var notes: String

    @Relationship(deleteRule: .cascade)
    var phases: [SleepPhase]

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    init(startDate: Date, endDate: Date, quality: SleepQuality, notes: String = "") {
        self.startDate = startDate
        self.endDate = endDate
        self.quality = quality
        self.notes = notes
        self.phases = []
    }
}

enum SleepQuality: String, Codable, CaseIterable {
    case poor, fair, good, excellent
}
```

- Use `@Model` on final classes.
- Enum-backed properties should be `Codable`.
- Computed properties are fine — they are not persisted.
- Define `@Relationship` with explicit delete rules.

### ModelContainer Setup

Configure in the app entry point:

```swift
@main
struct SleepPathApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            SleepSession.self,
            CircadianProfile.self
        ])
    }
}
```

For testing, use an in-memory container:

```swift
let config = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try ModelContainer(for: SleepSession.self, configurations: config)
```

### Query Patterns

```swift
struct SleepHistoryView: View {
    @Query(
        filter: #Predicate<SleepSession> { $0.quality != .poor },
        sort: \.startDate,
        order: .reverse
    )
    private var sessions: [SleepSession]

    // For complex queries, build predicates in the ViewModel
    // and pass them to @Query via init.
}
```

### Migration Strategy

- Use `VersionedSchema` and `SchemaMigrationPlan` from the start.
- Define each schema version as a struct conforming to `VersionedSchema`.
- Write lightweight migrations for additive changes, custom `MigrationStage` for destructive ones.
- Test migrations against production-shaped data before release.

---

## 4. Testing

### Naming Convention

```
test_<methodName>_<condition>_<expectedResult>
```

```swift
@Test func test_calculateChronotype_withConsistentEarlyWake_returnsmorningLark() { ... }
@Test func test_sleepDuration_crossingMidnight_calculatesCorrectly() { ... }
```

### Swift Testing Framework

Prefer Swift Testing (`@Test`, `#expect`) for new tests. Use XCTest only where Swift Testing lacks support (e.g., performance tests, some async patterns).

```swift
import Testing

struct SleepAnalysisTests {
    let service = SleepAnalysisService()

    @Test("Optimal bedtime accounts for chronotype offset")
    func test_optimalBedtime_morningLark_earlierThanDefault() {
        let profile = CircadianProfile(chronotype: .morningLark)
        let bedtime = service.optimalBedtime(for: profile)

        #expect(bedtime.hour < 23)
    }

    @Test("Sleep debt accumulates correctly", arguments: [
        (actual: 6.0, goal: 8.0, expectedDebt: 2.0),
        (actual: 8.0, goal: 8.0, expectedDebt: 0.0),
    ])
    func test_sleepDebt_calculation(actual: Double, goal: Double, expectedDebt: Double) {
        let debt = service.calculateDebt(actual: actual, goal: goal)
        #expect(debt == expectedDebt)
    }
}
```

### Mock Services with Protocols

```swift
protocol HealthDataProviding {
    func fetchSleepData(from: Date, to: Date) async throws -> [SleepSample]
    func requestAuthorization() async throws -> Bool
}

// Production
final class HealthKitService: HealthDataProviding { ... }

// Test
struct MockHealthDataProvider: HealthDataProviding {
    var sleepDataToReturn: [SleepSample] = []
    var shouldThrow = false

    func fetchSleepData(from: Date, to: Date) async throws -> [SleepSample] {
        if shouldThrow { throw TestError.simulatedFailure }
        return sleepDataToReturn
    }

    func requestAuthorization() async throws -> Bool { true }
}
```

### What to Test

- **ViewModels**: Thoroughly. Every public method, state transitions, error paths.
- **Services**: Core logic, edge cases, error handling.
- **Models**: Computed properties, validation logic.
- **Views**: Use Xcode Previews as visual tests. Add snapshot tests for critical screens (e.g., sleep report, onboarding).

**Target >85% code coverage on all business logic.** Views are exempt from this target.

---

## 5. HealthKit Integration

### Authorization

Always check before reading or writing:

```swift
func fetchSleepData() async throws -> [SleepSample] {
    let status = healthStore.authorizationStatus(for: sleepType)

    switch status {
    case .notDetermined:
        throw HealthKitError.authorizationRequired
    case .sharingDenied:
        throw HealthKitError.permissionDenied
    case .sharingAuthorized:
        return try await performQuery()
    @unknown default:
        throw HealthKitError.unknownStatus
    }
}
```

### Denied Permissions

Never block the user. Show degraded functionality with a clear explanation and a path to Settings:

```swift
struct HealthPermissionDeniedView: View {
    var body: some View {
        ContentUnavailableView(
            "Sleep Data Unavailable",
            systemImage: "heart.slash",
            description: Text("SleepPath needs access to your sleep data to provide personalized recommendations.")
        ) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}
```

### Pre-Permission Screens

Always show an explanatory screen before the system HealthKit permission dialog. Explain what data is needed and why. This significantly improves grant rates.

### Background Delivery

Register for background delivery of sleep analysis data so the app can update overnight:

```swift
try healthStore.enableBackgroundDelivery(
    for: sleepAnalysisType,
    frequency: .daily
) { success, error in
    // Handle registration result
}
```

Register in `application(_:didFinishLaunchingWithOptions:)` or the app's `init`.

### Data Privacy

- Process all health data on-device. Never transmit raw HealthKit data to external servers.
- If analytics are needed, aggregate and anonymize before any network calls.
- Document data usage clearly in the app's privacy policy and App Store privacy nutrition labels.

---

## 6. Performance

### Lazy Loading

```swift
// Use LazyVStack in scrollable lists
ScrollView {
    LazyVStack(spacing: 12) {
        ForEach(viewModel.sleepHistory) { session in
            SleepSessionRow(session: session)
        }
    }
}
```

Never use `VStack` or `HStack` inside a `ScrollView` for unbounded data.

### Keep `body` Cheap

- No heavy computation in `body`. Precompute in the ViewModel or use `.task {}`.
- Avoid calling `DateFormatter` or `MeasurementFormatter` inside `body` — create them once as static or stored properties.

```swift
// Bad
var body: some View {
    let formatter = DateFormatter() // created every render
    Text(formatter.string(from: session.startDate))
}

// Good
private static let timeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.timeStyle = .short
    return f
}()
```

### Async Work

Use `.task {}` for data loading. It automatically cancels when the view disappears.

```swift
var body: some View {
    SleepDashboard(data: viewModel.dashboardData)
        .task {
            await viewModel.loadDashboard()
        }
}
```

### Image Optimization

- Use `AsyncImage` with placeholder for remote images.
- Provide multiple asset resolutions in the asset catalog.
- For charts and graphs, prefer SwiftUI `Canvas` or Swift Charts over rasterized images.
- Cache downloaded images using `URLCache` or a dedicated image cache — do not re-download on every appearance.

---

## 7. Accessibility

### Labels

Every interactive element must have an accessibility label:

```swift
Button(action: viewModel.logSleep) {
    Image(systemName: "moon.fill")
}
.accessibilityLabel("Log sleep session")

SleepRingView(progress: 0.75)
    .accessibilityLabel("Sleep goal progress")
    .accessibilityValue("75 percent")
```

### Dynamic Type

- Use system fonts or scaled custom fonts. Never hard-code point sizes.
- Test at the largest accessibility text sizes — layouts must remain usable.

```swift
Text(session.formattedDuration)
    .font(.headline) // scales automatically

// Custom font with scaling
@ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 24
```

### VoiceOver

- Test every screen with VoiceOver enabled.
- Group related elements with `.accessibilityElement(children: .combine)`.
- Provide `.accessibilityHint` for non-obvious actions.
- Ensure logical reading order — use `.accessibilitySortPriority` if needed.

### Color Contrast

- Minimum 4.5:1 contrast ratio for body text, 3:1 for large text.
- Never convey information through color alone — pair with icons, labels, or patterns.
- Test with "Increase Contrast" and "Differentiate Without Color" accessibility settings enabled.

---

## 8. Code Quality

### SwiftLint

Recommended `.swiftlint.yml` rules:

```yaml
included:
  - SleepPath

disabled_rules:
  - trailing_whitespace

opt_in_rules:
  - closure_spacing
  - empty_count
  - force_unwrapping
  - implicitly_unwrapped_optional
  - modifier_order
  - overridden_super_call
  - private_outlet
  - vertical_whitespace_closing_braces

line_length:
  warning: 120
  error: 150

type_body_length:
  warning: 250
  error: 400

file_length:
  warning: 400
  error: 600
```

### No Force Unwrapping

Never use `!` in production code. Use `guard let`, `if let`, or nil-coalescing.

```swift
// Bad
let sleepHours = defaults.object(forKey: "sleepGoal") as! Double

// Good
let sleepHours = defaults.double(forKey: "sleepGoal")
guard sleepHours > 0 else { return defaultSleepGoal }
```

### Guard for Early Returns

```swift
func processSleepData(_ data: SleepData?) throws -> SleepReport {
    guard let data else {
        throw SleepError.noData
    }
    guard data.duration > 0 else {
        throw SleepError.invalidDuration
    }
    // Main logic proceeds with non-optional, validated data
    return SleepReport(data: data)
}
```

### Value Types Over Reference Types

Use structs by default. Use classes only when you need:
- Identity (reference semantics)
- Inheritance
- Interop with Objective-C APIs
- `@Observable` or `@Model` (these require classes)

### Error Handling

Use `throws` for operations that can fail. Use `Result` when you need to store or pass errors around.

```swift
// Prefer throws for service methods
func analyzeSleepPattern(sessions: [SleepSession]) throws -> SleepPattern {
    guard sessions.count >= 7 else {
        throw AnalysisError.insufficientData(
            required: 7,
            provided: sessions.count
        )
    }
    // ...
}

// Use Result when passing errors through callbacks or storing them
enum SleepLogState {
    case idle
    case loading
    case loaded([SleepSession])
    case failed(SleepError)
}
```

Define domain-specific error types — never throw generic `NSError` or stringly-typed errors:

```swift
enum SleepError: LocalizedError {
    case noData
    case invalidDuration
    case healthKitUnavailable

    var errorDescription: String? {
        switch self {
        case .noData: "No sleep data available."
        case .invalidDuration: "Sleep duration is invalid."
        case .healthKitUnavailable: "HealthKit is not available on this device."
        }
    }
}
```

---

## Quick Reference

| Do | Don't |
|---|---|
| Use `@Observable` | Use `@ObservableObject` / `@Published` |
| Inject dependencies via protocols | Hard-code concrete service types |
| Keep views under 80 lines | Build 300-line monolithic views |
| Use `guard` for preconditions | Nest multiple `if let` blocks |
| Process health data on-device | Send raw HealthKit data over the network |
| Use `.task {}` for async loading | Call `Task { }` inside `onAppear` |
| Format dates with static formatters | Create formatters inside `body` |
| Add accessibility labels everywhere | Rely on default VoiceOver descriptions |
| Write tests with `@Test` / `#expect` | Skip testing ViewModels |
| Use `LazyVStack` in scroll views | Use `VStack` for unbounded lists |
