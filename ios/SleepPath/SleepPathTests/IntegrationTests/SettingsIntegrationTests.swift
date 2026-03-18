import XCTest
@testable import SleepPath

/// Integration tests verifying that settings changes propagate correctly
/// and that data operations (export, delete) interact with the expected state.
final class SettingsIntegrationTests: XCTestCase {

    // MARK: - Load Settings → Patterns Data Consistency

    func test_settingsChronotype_matchesPatternsChronotype() {
        let settingsVM = SettingsViewModel()
        let patternsVM = PatternsViewModel()

        settingsVM.loadSettings()
        patternsVM.loadData()

        XCTAssertEqual(settingsVM.chronotype, patternsVM.currentChronotype,
                       "Settings and Patterns should show the same chronotype")
    }

    // MARK: - Delete All Data Resets Everything

    func test_deleteAllData_resetsSettingsToDefaults() {
        let vm = SettingsViewModel()
        vm.loadSettings()

        // Modify some settings
        vm.updateGoal(.energy)
        vm.toggleNightShift()
        vm.toggleScienceMode()
        vm.updateCaffeineSensitivity(.high)

        // Verify modifications took effect
        XCTAssertEqual(vm.goal, .energy)
        XCTAssertTrue(vm.isNightShift)
        XCTAssertTrue(vm.scienceMode)
        XCTAssertEqual(vm.caffeineSensitivity, .high)

        // Delete all data
        vm.deleteAllData()
        XCTAssertTrue(vm.showDeleteConfirmation)

        vm.confirmDeleteAllData()

        // Verify reset to defaults
        XCTAssertEqual(vm.chronotype, .wolf)
        XCTAssertEqual(vm.goal, .focus)
        XCTAssertFalse(vm.isNightShift)
        XCTAssertFalse(vm.scienceMode)
        XCTAssertEqual(vm.caffeineSensitivity, .normal)
        XCTAssertFalse(vm.healthKitConnected)
        XCTAssertFalse(vm.calendarExportEnabled)
        XCTAssertFalse(vm.isProSubscriber)
        XCTAssertFalse(vm.showDeleteConfirmation)
    }

    // MARK: - Export Data Flow

    func test_exportData_showsSuccessAlert() {
        let vm = SettingsViewModel()
        XCTAssertFalse(vm.showExportSuccess)

        vm.exportData()
        XCTAssertTrue(vm.showExportSuccess)
    }

    // MARK: - Retake Quiz Flow

    func test_retakeQuiz_triggersShouldRetakeQuiz() {
        let vm = SettingsViewModel()
        XCTAssertFalse(vm.shouldRetakeQuiz)

        vm.retakeQuiz()
        XCTAssertTrue(vm.shouldRetakeQuiz)
    }

    // MARK: - Settings → Notification Preferences

    func test_notificationPreferences_togglesAreIndependent() {
        let vm = SettingsViewModel()

        // Default state
        let initialSunlight = vm.notificationPreferences.sunlightEnabled
        let initialCaffeine = vm.notificationPreferences.caffeineCutoffEnabled

        // Toggle sunlight
        vm.notificationPreferences.sunlightEnabled.toggle()
        XCTAssertNotEqual(vm.notificationPreferences.sunlightEnabled, initialSunlight)
        XCTAssertEqual(vm.notificationPreferences.caffeineCutoffEnabled, initialCaffeine,
                       "Toggling sunlight should not affect caffeine")
    }

    // MARK: - Goal Update Consistency

    func test_updateGoal_allGoals_persistCorrectly() {
        let vm = SettingsViewModel()

        for goal in UserGoal.allCases {
            vm.updateGoal(goal)
            XCTAssertEqual(vm.goal, goal, "Goal should be \(goal)")
        }
    }

    // MARK: - Caffeine Sensitivity Update

    func test_caffeineSensitivity_allLevels_persistCorrectly() {
        let vm = SettingsViewModel()

        for sensitivity in CaffeineSensitivity.allCases {
            vm.updateCaffeineSensitivity(sensitivity)
            XCTAssertEqual(vm.caffeineSensitivity, sensitivity)
        }
    }

    // MARK: - Multiple Toggle Cycles

    func test_toggleNightShift_multipleCycles_returnsToOriginal() {
        let vm = SettingsViewModel()
        let original = vm.isNightShift

        vm.toggleNightShift()
        vm.toggleNightShift()

        XCTAssertEqual(vm.isNightShift, original, "Double toggle should return to original state")
    }

    func test_toggleHealthKit_multipleCycles_returnsToOriginal() {
        let vm = SettingsViewModel()
        let original = vm.healthKitConnected

        vm.toggleHealthKit()
        vm.toggleHealthKit()

        XCTAssertEqual(vm.healthKitConnected, original)
    }

    // MARK: - Subscription Status Display

    func test_subscriptionStatus_afterLoad_showsProActive() {
        let vm = SettingsViewModel()
        vm.loadSettings()
        XCTAssertEqual(vm.subscriptionStatusText, "Pro \u{2014} Active")
    }

    func test_subscriptionStatus_afterDelete_showsFree() {
        let vm = SettingsViewModel()
        vm.loadSettings()
        vm.deleteAllData()
        vm.confirmDeleteAllData()
        XCTAssertEqual(vm.subscriptionStatusText, "Free")
    }

    // MARK: - Settings Load Idempotency

    func test_loadSettings_calledTwice_producesConsistentState() {
        let vm = SettingsViewModel()
        vm.loadSettings()
        let firstChronotype = vm.chronotype
        let firstGoal = vm.goal

        vm.loadSettings()
        XCTAssertEqual(vm.chronotype, firstChronotype)
        XCTAssertEqual(vm.goal, firstGoal)
    }
}
