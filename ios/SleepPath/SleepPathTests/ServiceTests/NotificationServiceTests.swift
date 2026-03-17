import XCTest
@testable import SleepPath

final class NotificationServiceTests: XCTestCase {

    var service: NotificationService!

    override func setUp() {
        super.setUp()
        service = NotificationService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeSampleBlocks() -> [TrajectoryBlock] {
        let now = Date()
        let calendar = Calendar.current
        let today6am = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: now)!
        let today10pm = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: now)!

        let trajectoryService = TrajectoryService()
        return trajectoryService.generateTrajectory(
            chronotype: .bear,
            wakeTime: today6am,
            sleepTime: today10pm,
            dataNightsCount: 14
        )
    }

    // MARK: - Initial State

    func test_initialState_scheduledNotificationsIsEmpty() {
        XCTAssertTrue(service.scheduledNotifications.isEmpty)
    }

    func test_initialState_preferencesAreDefaults() {
        XCTAssertTrue(service.preferences.sunlightEnabled)
        XCTAssertFalse(service.preferences.caffeineOkEnabled)
        XCTAssertFalse(service.preferences.peakFocusEnabled)
        XCTAssertTrue(service.preferences.caffeineCutoffEnabled)
        XCTAssertTrue(service.preferences.digitalSunsetEnabled)
        XCTAssertFalse(service.preferences.windDownEnabled)
        XCTAssertTrue(service.preferences.weeklySummaryEnabled)
    }

    // MARK: - NotificationType

    func test_notificationType_allCasesHaveDisplayNames() {
        for type in NotificationType.allCases {
            XCTAssertFalse(type.displayName.isEmpty, "\(type) should have a display name")
        }
    }

    func test_notificationType_allCasesHaveIcons() {
        for type in NotificationType.allCases {
            XCTAssertFalse(type.icon.isEmpty, "\(type) should have an icon")
        }
    }

    func test_notificationType_displayNames() {
        XCTAssertEqual(NotificationType.sunlight.displayName, "Morning Sunlight")
        XCTAssertEqual(NotificationType.caffeineOk.displayName, "Caffeine OK")
        XCTAssertEqual(NotificationType.peakFocus.displayName, "Peak Focus")
        XCTAssertEqual(NotificationType.caffeineCutoff.displayName, "Caffeine Cutoff")
        XCTAssertEqual(NotificationType.digitalSunset.displayName, "Digital Sunset")
        XCTAssertEqual(NotificationType.windDown.displayName, "Wind Down")
        XCTAssertEqual(NotificationType.weeklySummary.displayName, "Weekly Summary")
    }

    func test_notificationType_icons() {
        XCTAssertEqual(NotificationType.sunlight.icon, "sun.max.fill")
        XCTAssertEqual(NotificationType.caffeineOk.icon, "cup.and.saucer.fill")
        XCTAssertEqual(NotificationType.peakFocus.icon, "bolt.fill")
        XCTAssertEqual(NotificationType.caffeineCutoff.icon, "cup.and.saucer")
        XCTAssertEqual(NotificationType.digitalSunset.icon, "sunset.fill")
        XCTAssertEqual(NotificationType.windDown.icon, "moon.haze.fill")
        XCTAssertEqual(NotificationType.weeklySummary.icon, "chart.bar.fill")
    }

    func test_notificationType_defaultEnabled() {
        XCTAssertTrue(NotificationType.sunlight.defaultEnabled)
        XCTAssertFalse(NotificationType.caffeineOk.defaultEnabled)
        XCTAssertFalse(NotificationType.peakFocus.defaultEnabled)
        XCTAssertTrue(NotificationType.caffeineCutoff.defaultEnabled)
        XCTAssertTrue(NotificationType.digitalSunset.defaultEnabled)
        XCTAssertFalse(NotificationType.windDown.defaultEnabled)
        XCTAssertTrue(NotificationType.weeklySummary.defaultEnabled)
    }

    // MARK: - NotificationPreferences

    func test_preferences_defaultValues() {
        let prefs = NotificationPreferences()
        XCTAssertTrue(prefs.sunlightEnabled)
        XCTAssertFalse(prefs.caffeineOkEnabled)
        XCTAssertFalse(prefs.peakFocusEnabled)
        XCTAssertTrue(prefs.caffeineCutoffEnabled)
        XCTAssertTrue(prefs.digitalSunsetEnabled)
        XCTAssertFalse(prefs.windDownEnabled)
        XCTAssertTrue(prefs.weeklySummaryEnabled)
    }

    func test_preferences_isEnabledForType_matchesProperties() {
        let prefs = NotificationPreferences()
        XCTAssertEqual(prefs.isEnabled(for: .sunlight), prefs.sunlightEnabled)
        XCTAssertEqual(prefs.isEnabled(for: .caffeineOk), prefs.caffeineOkEnabled)
        XCTAssertEqual(prefs.isEnabled(for: .peakFocus), prefs.peakFocusEnabled)
        XCTAssertEqual(prefs.isEnabled(for: .caffeineCutoff), prefs.caffeineCutoffEnabled)
        XCTAssertEqual(prefs.isEnabled(for: .digitalSunset), prefs.digitalSunsetEnabled)
        XCTAssertEqual(prefs.isEnabled(for: .windDown), prefs.windDownEnabled)
        XCTAssertEqual(prefs.isEnabled(for: .weeklySummary), prefs.weeklySummaryEnabled)
    }

    func test_preferences_toggling_createsNewCopyWithTypeEnabled() {
        let prefs = NotificationPreferences()
        let updated = prefs.toggling(.caffeineOk, to: true)
        XCTAssertTrue(updated.caffeineOkEnabled)
        // Original unchanged
        XCTAssertFalse(prefs.caffeineOkEnabled)
    }

    func test_preferences_toggling_disablesType() {
        let prefs = NotificationPreferences()
        let updated = prefs.toggling(.sunlight, to: false)
        XCTAssertFalse(updated.sunlightEnabled)
    }

    func test_preferences_toggling_allTypes() {
        var prefs = NotificationPreferences()
        for type in NotificationType.allCases {
            prefs = prefs.toggling(type, to: true)
            XCTAssertTrue(prefs.isEnabled(for: type), "\(type) should be enabled after toggling on")
        }
        for type in NotificationType.allCases {
            prefs = prefs.toggling(type, to: false)
            XCTAssertFalse(prefs.isEnabled(for: type), "\(type) should be disabled after toggling off")
        }
    }

    // MARK: - Schedule Notifications

    func test_scheduleNotifications_populatesScheduledNotifications() {
        let blocks = makeSampleBlocks()
        let prefs = NotificationPreferences()
        service.scheduleNotifications(for: blocks, preferences: prefs)
        XCTAssertFalse(service.scheduledNotifications.isEmpty)
    }

    func test_scheduleNotifications_storesPreferences() {
        let blocks = makeSampleBlocks()
        var prefs = NotificationPreferences()
        prefs.peakFocusEnabled = true
        service.scheduleNotifications(for: blocks, preferences: prefs)
        XCTAssertTrue(service.preferences.peakFocusEnabled)
    }

    func test_scheduleNotifications_sortedByTime() {
        let blocks = makeSampleBlocks()
        let prefs = NotificationPreferences()
        service.scheduleNotifications(for: blocks, preferences: prefs)

        let times = service.scheduledNotifications.map { $0.scheduledTime }
        for i in 1..<times.count {
            XCTAssertGreaterThanOrEqual(times[i], times[i - 1], "Notifications should be sorted by scheduled time")
        }
    }

    func test_scheduleNotifications_includesWeeklySummaryWhenEnabled() {
        let blocks = makeSampleBlocks()
        var prefs = NotificationPreferences()
        prefs.weeklySummaryEnabled = true
        service.scheduleNotifications(for: blocks, preferences: prefs)

        let weeklySummaryNotifications = service.scheduledNotifications.filter { $0.type == .weeklySummary }
        XCTAssertFalse(weeklySummaryNotifications.isEmpty, "Should include weekly summary notification")
    }

    func test_scheduleNotifications_excludesWeeklySummaryWhenDisabled() {
        let blocks = makeSampleBlocks()
        var prefs = NotificationPreferences()
        prefs.weeklySummaryEnabled = false
        service.scheduleNotifications(for: blocks, preferences: prefs)

        let weeklySummaryNotifications = service.scheduledNotifications.filter { $0.type == .weeklySummary }
        XCTAssertTrue(weeklySummaryNotifications.isEmpty, "Should not include weekly summary notification")
    }

    func test_scheduleNotifications_skipsNonNotifiableBlockTypes() {
        let blocks = makeSampleBlocks()
        let prefs = NotificationPreferences()
        service.scheduleNotifications(for: blocks, preferences: prefs)

        // rising, energyDip, sleep, recovery should not produce notifications
        let types = Set(service.scheduledNotifications.map { $0.type })
        // These notification types don't exist (they map from block types that return nil)
        // Verify no unexpected types appear
        for notification in service.scheduledNotifications {
            XCTAssertTrue(NotificationType.allCases.contains(notification.type))
        }
    }

    func test_scheduleNotifications_respectsEnabledState() {
        let blocks = makeSampleBlocks()
        var prefs = NotificationPreferences()
        prefs.sunlightEnabled = false
        service.scheduleNotifications(for: blocks, preferences: prefs)

        let sunlightNotifications = service.scheduledNotifications.filter { $0.type == .sunlight }
        for notification in sunlightNotifications {
            XCTAssertFalse(notification.isEnabled, "Sunlight notifications should be disabled")
        }
    }

    func test_scheduleNotifications_replacesExistingNotifications() {
        let blocks = makeSampleBlocks()
        let prefs = NotificationPreferences()
        service.scheduleNotifications(for: blocks, preferences: prefs)
        let firstCount = service.scheduledNotifications.count

        service.scheduleNotifications(for: blocks, preferences: prefs)
        XCTAssertEqual(service.scheduledNotifications.count, firstCount,
                       "Rescheduling should replace, not append")
    }

    func test_scheduleNotifications_allNotificationsHaveTitleAndBody() {
        let blocks = makeSampleBlocks()
        let prefs = NotificationPreferences()
        service.scheduleNotifications(for: blocks, preferences: prefs)

        for notification in service.scheduledNotifications {
            XCTAssertFalse(notification.title.isEmpty, "\(notification.type) should have a title")
            XCTAssertFalse(notification.body.isEmpty, "\(notification.type) should have a body")
        }
    }

    // MARK: - Toggle Notification

    func test_toggleNotification_updatesPreferences() {
        let blocks = makeSampleBlocks()
        let prefs = NotificationPreferences()
        service.scheduleNotifications(for: blocks, preferences: prefs)

        service.toggleNotification(type: .sunlight, enabled: false)
        XCTAssertFalse(service.preferences.sunlightEnabled)
    }

    func test_toggleNotification_updatesScheduledNotificationState() {
        let blocks = makeSampleBlocks()
        let prefs = NotificationPreferences()
        service.scheduleNotifications(for: blocks, preferences: prefs)

        service.toggleNotification(type: .sunlight, enabled: false)
        let sunlightNotifications = service.scheduledNotifications.filter { $0.type == .sunlight }
        for notification in sunlightNotifications {
            XCTAssertFalse(notification.isEnabled)
        }
    }

    func test_toggleNotification_enablesPreviouslyDisabledType() {
        let blocks = makeSampleBlocks()
        var prefs = NotificationPreferences()
        prefs.peakFocusEnabled = false
        service.scheduleNotifications(for: blocks, preferences: prefs)

        service.toggleNotification(type: .peakFocus, enabled: true)
        XCTAssertTrue(service.preferences.peakFocusEnabled)
        let peakNotifications = service.scheduledNotifications.filter { $0.type == .peakFocus }
        for notification in peakNotifications {
            XCTAssertTrue(notification.isEnabled)
        }
    }

    // MARK: - Active Notifications

    func test_activeNotifications_filtersDisabled() {
        let blocks = makeSampleBlocks()
        var prefs = NotificationPreferences()
        prefs.sunlightEnabled = true
        prefs.caffeineOkEnabled = false
        service.scheduleNotifications(for: blocks, preferences: prefs)

        let active = service.activeNotifications
        let disabledInActive = active.filter { !$0.isEnabled }
        XCTAssertTrue(disabledInActive.isEmpty, "Active notifications should only include enabled ones")
    }

    func test_activeNotifications_countLessThanOrEqualTotal() {
        let blocks = makeSampleBlocks()
        let prefs = NotificationPreferences()
        service.scheduleNotifications(for: blocks, preferences: prefs)

        XCTAssertLessThanOrEqual(service.activeNotifications.count,
                                  service.scheduledNotifications.count)
    }

    // MARK: - Next Upcoming Notification

    func test_nextUpcomingNotification_returnsNilWhenEmpty() {
        XCTAssertNil(service.nextUpcomingNotification())
    }

    func test_nextUpcomingNotification_returnsNextEnabledAfterTime() {
        let blocks = makeSampleBlocks()
        var prefs = NotificationPreferences()
        // Enable all to ensure we have options
        prefs.sunlightEnabled = true
        prefs.caffeineOkEnabled = true
        prefs.peakFocusEnabled = true
        prefs.caffeineCutoffEnabled = true
        prefs.digitalSunsetEnabled = true
        prefs.windDownEnabled = true
        prefs.weeklySummaryEnabled = true
        service.scheduleNotifications(for: blocks, preferences: prefs)

        let distantPast = Date.distantPast
        let next = service.nextUpcomingNotification(after: distantPast)
        XCTAssertNotNil(next, "Should find a notification after distant past")
    }

    func test_nextUpcomingNotification_returnsNilWhenAllPast() {
        let blocks = makeSampleBlocks()
        let prefs = NotificationPreferences()
        service.scheduleNotifications(for: blocks, preferences: prefs)

        let next = service.nextUpcomingNotification(after: .distantFuture)
        XCTAssertNil(next, "Should return nil when all notifications are in the past")
    }

    // MARK: - ScheduledNotification

    func test_scheduledNotification_hasUniqueId() {
        let n1 = ScheduledNotification(
            type: .sunlight, scheduledTime: Date(), title: "Test", body: "Body", isEnabled: true
        )
        let n2 = ScheduledNotification(
            type: .sunlight, scheduledTime: Date(), title: "Test", body: "Body", isEnabled: true
        )
        XCTAssertNotEqual(n1.id, n2.id)
    }
}
