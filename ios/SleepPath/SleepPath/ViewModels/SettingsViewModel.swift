import Foundation

/// Manages user settings, preferences, connections, and subscription state.
///
/// Provides actions for toggling feature flags, updating preferences, and
/// triggering mock operations like data export and account deletion. During
/// the prototype phase all state is in-memory and sourced from ``MockDataService``.
@Observable
final class SettingsViewModel {

    // MARK: - Profile

    /// The user's determined chronotype.
    var chronotype: Chronotype = .wolf

    /// The user's primary goal.
    var goal: UserGoal = .focus

    /// The user's age range.
    var ageRange: AgeRange = .twentySix_35

    /// Whether the user works night shifts.
    var isNightShift: Bool = false

    // MARK: - Connections

    /// Whether HealthKit is connected.
    var healthKitConnected: Bool = true

    /// Whether calendar export is enabled.
    var calendarExportEnabled: Bool = false

    // MARK: - Notifications

    /// Notification toggle preferences.
    var notificationPreferences = NotificationPreferences()

    // MARK: - Preferences

    /// Whether to show scientific citations and detailed explanations.
    var scienceMode: Bool = false

    /// The user's self-reported caffeine sensitivity.
    var caffeineSensitivity: CaffeineSensitivity = .normal

    /// Whether to display times in 24-hour format.
    var use24HourTime: Bool = false

    // MARK: - Subscription

    /// Whether the user has a Pro subscription (mock: always true).
    var isProSubscriber: Bool = true

    /// Optional expiry date for the subscription.
    var subscriptionExpiryDate: Date? = nil

    // MARK: - UI State

    /// Controls display of the delete-all-data confirmation dialog.
    var showDeleteConfirmation: Bool = false

    /// Controls display of the export success alert.
    var showExportSuccess: Bool = false

    /// When true, the app should navigate back to the onboarding quiz.
    var shouldRetakeQuiz: Bool = false

    // MARK: - Services

    private let mockData = MockDataService.shared

    // MARK: - Computed Properties

    /// Human-readable subscription status.
    var subscriptionStatusText: String {
        if isProSubscriber {
            return "Pro \u{2014} Active"
        }
        return "Free"
    }

    /// Display string combining the chronotype emoji, name, and tagline.
    var chronotypeDisplayText: String {
        "\(chronotype.emoji) \(chronotype.displayName) \u{2014} \(chronotype.tagline)"
    }

    /// The current app version string.
    var versionString: String {
        "1.0.0 (1)"
    }

    // MARK: - Actions

    /// Loads settings from the mock data service.
    func loadSettings() {
        let profile = mockData.userProfile
        chronotype = profile.chronotype
        healthKitConnected = profile.healthKitConnected
        isProSubscriber = profile.isProSubscriber

        goal = profile.goal
        ageRange = profile.ageRange ?? .twentySix_35
        isNightShift = profile.isNightShift
        caffeineSensitivity = profile.caffeineSensitivity
        scienceMode = profile.scienceMode
    }

    /// Updates the user's goal.
    /// - Parameter newGoal: The new goal selection.
    func updateGoal(_ newGoal: UserGoal) {
        goal = newGoal
    }

    /// Toggles the night-shift mode.
    func toggleNightShift() {
        isNightShift.toggle()
    }

    /// Toggles the HealthKit connection state.
    func toggleHealthKit() {
        healthKitConnected.toggle()
    }

    /// Toggles calendar export.
    func toggleCalendarExport() {
        calendarExportEnabled.toggle()
    }

    /// Toggles the science/detail mode.
    func toggleScienceMode() {
        scienceMode.toggle()
    }

    /// Updates the caffeine sensitivity level.
    /// - Parameter sensitivity: The new sensitivity setting.
    func updateCaffeineSensitivity(_ sensitivity: CaffeineSensitivity) {
        caffeineSensitivity = sensitivity
    }

    /// Flags that the user wants to retake the chronotype quiz.
    func retakeQuiz() {
        shouldRetakeQuiz = true
    }

    /// Simulates a data export. Sets `showExportSuccess` to trigger UI feedback.
    func exportData() {
        showExportSuccess = true
    }

    /// Presents the delete-all-data confirmation dialog.
    func deleteAllData() {
        showDeleteConfirmation = true
    }

    /// Confirms deletion and resets state to defaults.
    func confirmDeleteAllData() {
        showDeleteConfirmation = false
        // In a real app this would clear SwiftData and UserDefaults.
        // For the prototype we just reset to defaults.
        chronotype = .bear
        goal = .focus
        ageRange = .twentySix_35
        isNightShift = false
        caffeineSensitivity = .normal
        scienceMode = false
        healthKitConnected = false
        calendarExportEnabled = false
        notificationPreferences = NotificationPreferences()
    }
}
