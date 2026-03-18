import Foundation

// MARK: - Notification Types

/// The types of notifications SleepPath can schedule throughout the day.
enum NotificationType: String, CaseIterable, Sendable {
    case sunlight
    case caffeineOk
    case peakFocus
    case caffeineCutoff
    case digitalSunset
    case windDown
    case weeklySummary

    /// Human-readable display name for settings UI.
    var displayName: String {
        switch self {
        case .sunlight:       return "Morning Sunlight"
        case .caffeineOk:     return "Caffeine OK"
        case .peakFocus:      return "Peak Focus"
        case .caffeineCutoff: return "Caffeine Cutoff"
        case .digitalSunset:  return "Digital Sunset"
        case .windDown:       return "Wind Down"
        case .weeklySummary:  return "Weekly Summary"
        }
    }

    /// Whether this notification type is enabled by default.
    var defaultEnabled: Bool {
        switch self {
        case .sunlight, .caffeineCutoff, .digitalSunset, .weeklySummary:
            return true
        case .caffeineOk, .peakFocus, .windDown:
            return false
        }
    }

    /// SF Symbol icon name for this notification type.
    var icon: String {
        switch self {
        case .sunlight:       return "sun.max.fill"
        case .caffeineOk:     return "cup.and.saucer.fill"
        case .peakFocus:      return "bolt.fill"
        case .caffeineCutoff: return "cup.and.saucer"
        case .digitalSunset:  return "sunset.fill"
        case .windDown:       return "moon.haze.fill"
        case .weeklySummary:  return "chart.bar.fill"
        }
    }
}

// MARK: - Scheduled Notification

/// Represents a notification that has been scheduled (or would be scheduled) for delivery.
struct ScheduledNotification: Identifiable, Sendable {
    let id = UUID()
    /// The type of trajectory event this notification corresponds to.
    let type: NotificationType
    /// When the notification is scheduled to fire.
    let scheduledTime: Date
    /// The notification title shown to the user.
    let title: String
    /// The notification body text.
    let body: String
    /// Whether the user has enabled this notification type.
    var isEnabled: Bool
}

// MARK: - Notification Preferences

/// User preferences controlling which notification types are active.
struct NotificationPreferences: Sendable {
    var sunlightEnabled: Bool = true
    var caffeineOkEnabled: Bool = false
    var peakFocusEnabled: Bool = false
    var caffeineCutoffEnabled: Bool = true
    var digitalSunsetEnabled: Bool = true
    var windDownEnabled: Bool = false
    var weeklySummaryEnabled: Bool = true

    /// Returns whether a specific notification type is enabled.
    func isEnabled(for type: NotificationType) -> Bool {
        switch type {
        case .sunlight:       return sunlightEnabled
        case .caffeineOk:     return caffeineOkEnabled
        case .peakFocus:      return peakFocusEnabled
        case .caffeineCutoff: return caffeineCutoffEnabled
        case .digitalSunset:  return digitalSunsetEnabled
        case .windDown:       return windDownEnabled
        case .weeklySummary:  return weeklySummaryEnabled
        }
    }

    /// Returns a copy with the specified notification type toggled.
    func toggling(_ type: NotificationType, to enabled: Bool) -> NotificationPreferences {
        var copy = self
        switch type {
        case .sunlight:       copy.sunlightEnabled = enabled
        case .caffeineOk:     copy.caffeineOkEnabled = enabled
        case .peakFocus:      copy.peakFocusEnabled = enabled
        case .caffeineCutoff: copy.caffeineCutoffEnabled = enabled
        case .digitalSunset:  copy.digitalSunsetEnabled = enabled
        case .windDown:       copy.windDownEnabled = enabled
        case .weeklySummary:  copy.weeklySummaryEnabled = enabled
        }
        return copy
    }
}

// MARK: - Notification Service

/// Manages the scheduling and configuration of local notifications.
///
/// In the MVP prototype, this service demonstrates the notification logic without
/// actually scheduling system notifications via `UNUserNotificationCenter`. It
/// builds the list of notifications that *would* be scheduled, allowing the UI
/// to display upcoming notifications and let users toggle preferences.
@Observable
final class NotificationService {

    /// The list of currently scheduled (mock) notifications.
    var scheduledNotifications: [ScheduledNotification] = []

    /// The user's notification preferences.
    var preferences = NotificationPreferences()

    // MARK: - Public API

    /// Generates scheduled notifications from a trajectory and user preferences.
    ///
    /// This replaces any previously scheduled notifications with a fresh set
    /// based on the provided trajectory blocks and the user's preferences.
    ///
    /// - Parameters:
    ///   - trajectory: The day's trajectory blocks to derive notification times from.
    ///   - preferences: The user's notification preferences.
    func scheduleNotifications(for trajectory: [TrajectoryBlock], preferences: NotificationPreferences) {
        self.preferences = preferences
        var notifications: [ScheduledNotification] = []

        for block in trajectory {
            guard let type = notificationType(for: block.type) else { continue }
            let isEnabled = preferences.isEnabled(for: type)

            let (title, body) = notificationContent(for: type, block: block)

            notifications.append(ScheduledNotification(
                type: type,
                scheduledTime: block.startTime,
                title: title,
                body: body,
                isEnabled: isEnabled
            ))
        }

        // Add weekly summary notification (next Sunday at 9 AM, or today if Sunday).
        if preferences.weeklySummaryEnabled {
            let calendar = Calendar.current
            let today = Date()
            let weekday = calendar.component(.weekday, from: today)
            // weekday 1 = Sunday. If today is Sunday, offset is 0; otherwise advance to next Sunday.
            let daysUntilSunday = (8 - weekday) % 7
            guard let nextSunday = calendar.date(byAdding: .day, value: daysUntilSunday, to: today) else {
                scheduledNotifications = notifications.sorted { $0.scheduledTime < $1.scheduledTime }
                return
            }
            var components = calendar.dateComponents([.year, .month, .day], from: nextSunday)
            components.hour = 9
            components.minute = 0

            if let sundayMorning = calendar.date(from: components) {
                notifications.append(ScheduledNotification(
                    type: .weeklySummary,
                    scheduledTime: sundayMorning,
                    title: "Your Week in Review",
                    body: "See how your sleep patterns shaped your energy this week.",
                    isEnabled: true
                ))
            }
        }

        scheduledNotifications = notifications.sorted { $0.scheduledTime < $1.scheduledTime }
    }

    /// Toggles a notification type on or off across all scheduled notifications.
    ///
    /// - Parameters:
    ///   - type: The notification type to toggle.
    ///   - enabled: Whether to enable or disable this type.
    func toggleNotification(type: NotificationType, enabled: Bool) {
        preferences = preferences.toggling(type, to: enabled)

        for index in scheduledNotifications.indices {
            if scheduledNotifications[index].type == type {
                scheduledNotifications[index].isEnabled = enabled
            }
        }
    }

    /// Returns only the notifications that are currently enabled.
    var activeNotifications: [ScheduledNotification] {
        scheduledNotifications.filter { $0.isEnabled }
    }

    /// Returns the next upcoming enabled notification after the given time.
    ///
    /// - Parameter time: The reference time (typically `Date()`).
    /// - Returns: The next scheduled notification, or `nil` if none remain.
    func nextUpcomingNotification(after time: Date = Date()) -> ScheduledNotification? {
        activeNotifications
            .filter { $0.scheduledTime > time }
            .first
    }

    // MARK: - Private Helpers

    /// Maps a trajectory block type to a notification type, if applicable.
    ///
    /// Not all block types have corresponding notifications (e.g., rising, recovery, sleep).
    private func notificationType(for blockType: TrajectoryBlockType) -> NotificationType? {
        switch blockType {
        case .sunlight:       return .sunlight
        case .caffeineOk:     return .caffeineOk
        case .peakFocus:      return .peakFocus
        case .caffeineCutoff: return .caffeineCutoff
        case .digitalSunset:  return .digitalSunset
        case .windDown:       return .windDown
        case .rising, .energyDip, .sleep, .recovery:
            return nil
        }
    }

    /// Cached time formatter for notification content.
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    /// Generates notification title and body text for a given type and block.
    private func notificationContent(
        for type: NotificationType,
        block: TrajectoryBlock
    ) -> (title: String, body: String) {
        let timeString = Self.timeFormatter.string(from: block.startTime)

        switch type {
        case .sunlight:
            return (
                "Time for Sunlight",
                "Step outside for 10+ minutes of natural light to set your circadian clock."
            )
        case .caffeineOk:
            return (
                "Caffeine Window Open",
                "Your cortisol has settled \u{2014} coffee will be most effective now."
            )
        case .peakFocus:
            return (
                "Peak Focus Starting",
                "Your mental clarity is at its highest. Protect the next 90 minutes for deep work."
            )
        case .caffeineCutoff:
            return (
                "Caffeine Cutoff",
                "Last call for caffeine. Anything after \(timeString) may affect tonight's sleep."
            )
        case .digitalSunset:
            return (
                "Digital Sunset",
                "Time to reduce screen brightness and blue light exposure."
            )
        case .windDown:
            return (
                "Wind Down Time",
                "Start your bedtime routine. Dim lights and switch to relaxing activities."
            )
        case .weeklySummary:
            return (
                "Your Week in Review",
                "See how your sleep patterns shaped your energy this week."
            )
        }
    }
}
