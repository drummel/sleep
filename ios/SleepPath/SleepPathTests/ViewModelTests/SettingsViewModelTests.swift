import XCTest
@testable import SleepPath

final class SettingsViewModelTests: XCTestCase {

    var viewModel: SettingsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SettingsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_chronotypeIsWolf() {
        XCTAssertEqual(viewModel.chronotype, .wolf)
    }

    func test_initialState_goalIsFocus() {
        XCTAssertEqual(viewModel.goal, .focus)
    }

    func test_initialState_ageRangeIsTwentySix_35() {
        XCTAssertEqual(viewModel.ageRange, .twentySix_35)
    }

    func test_initialState_isNightShiftIsFalse() {
        XCTAssertFalse(viewModel.isNightShift)
    }

    func test_initialState_healthKitConnectedIsTrue() {
        XCTAssertTrue(viewModel.healthKitConnected)
    }

    func test_initialState_calendarExportEnabledIsFalse() {
        XCTAssertFalse(viewModel.calendarExportEnabled)
    }

    func test_initialState_scienceModeIsFalse() {
        XCTAssertFalse(viewModel.scienceMode)
    }

    func test_initialState_caffeineSensitivityIsNormal() {
        XCTAssertEqual(viewModel.caffeineSensitivity, .normal)
    }

    func test_initialState_use24HourTimeIsFalse() {
        XCTAssertFalse(viewModel.use24HourTime)
    }

    func test_initialState_isProSubscriberIsTrue() {
        XCTAssertTrue(viewModel.isProSubscriber)
    }

    func test_initialState_subscriptionExpiryDateIsNil() {
        XCTAssertNil(viewModel.subscriptionExpiryDate)
    }

    func test_initialState_showDeleteConfirmationIsFalse() {
        XCTAssertFalse(viewModel.showDeleteConfirmation)
    }

    func test_initialState_showExportSuccessIsFalse() {
        XCTAssertFalse(viewModel.showExportSuccess)
    }

    func test_initialState_shouldRetakeQuizIsFalse() {
        XCTAssertFalse(viewModel.shouldRetakeQuiz)
    }

    // MARK: - Computed Properties

    func test_subscriptionStatusText_proReturnsProActive() {
        viewModel.isProSubscriber = true
        XCTAssertEqual(viewModel.subscriptionStatusText, "Pro \u{2014} Active")
    }

    func test_subscriptionStatusText_freeReturnsFree() {
        viewModel.isProSubscriber = false
        XCTAssertEqual(viewModel.subscriptionStatusText, "Free")
    }

    func test_chronotypeDisplayText_containsEmojiNameAndTagline() {
        viewModel.chronotype = .lion
        let text = viewModel.chronotypeDisplayText
        XCTAssertTrue(text.contains(Chronotype.lion.emoji))
        XCTAssertTrue(text.contains(Chronotype.lion.displayName))
        XCTAssertTrue(text.contains(Chronotype.lion.tagline))
    }

    func test_chronotypeDisplayText_formattedCorrectly() {
        viewModel.chronotype = .bear
        let expected = "\(Chronotype.bear.emoji) \(Chronotype.bear.displayName) \u{2014} \(Chronotype.bear.tagline)"
        XCTAssertEqual(viewModel.chronotypeDisplayText, expected)
    }

    func test_versionString_returns1_0_0() {
        XCTAssertEqual(viewModel.versionString, "1.0.0 (1)")
    }

    // MARK: - Load Settings

    func test_loadSettings_setsChronotypeFromMockData() {
        viewModel.loadSettings()
        // MockDataService user is a Wolf
        XCTAssertEqual(viewModel.chronotype, .wolf)
    }

    func test_loadSettings_setsHealthKitConnected() {
        viewModel.healthKitConnected = false
        viewModel.loadSettings()
        XCTAssertTrue(viewModel.healthKitConnected)
    }

    func test_loadSettings_setsIsProSubscriber() {
        viewModel.isProSubscriber = false
        viewModel.loadSettings()
        XCTAssertTrue(viewModel.isProSubscriber)
    }

    func test_loadSettings_setsGoal() {
        viewModel.loadSettings()
        // Should be set from mock data
        XCTAssertNotNil(viewModel.goal)
    }

    func test_loadSettings_setsCaffeineSensitivity() {
        viewModel.loadSettings()
        XCTAssertNotNil(viewModel.caffeineSensitivity)
    }

    // MARK: - Actions

    func test_updateGoal_changesGoal() {
        viewModel.updateGoal(.sleep)
        XCTAssertEqual(viewModel.goal, .sleep)
    }

    func test_updateGoal_allValues() {
        for goal in UserGoal.allCases {
            viewModel.updateGoal(goal)
            XCTAssertEqual(viewModel.goal, goal)
        }
    }

    func test_toggleNightShift_togglesFromFalseToTrue() {
        viewModel.isNightShift = false
        viewModel.toggleNightShift()
        XCTAssertTrue(viewModel.isNightShift)
    }

    func test_toggleNightShift_togglesFromTrueToFalse() {
        viewModel.isNightShift = true
        viewModel.toggleNightShift()
        XCTAssertFalse(viewModel.isNightShift)
    }

    func test_toggleHealthKit_togglesFromTrueToFalse() {
        viewModel.healthKitConnected = true
        viewModel.toggleHealthKit()
        XCTAssertFalse(viewModel.healthKitConnected)
    }

    func test_toggleHealthKit_togglesFromFalseToTrue() {
        viewModel.healthKitConnected = false
        viewModel.toggleHealthKit()
        XCTAssertTrue(viewModel.healthKitConnected)
    }

    func test_toggleCalendarExport_togglesFromFalseToTrue() {
        viewModel.calendarExportEnabled = false
        viewModel.toggleCalendarExport()
        XCTAssertTrue(viewModel.calendarExportEnabled)
    }

    func test_toggleCalendarExport_togglesFromTrueToFalse() {
        viewModel.calendarExportEnabled = true
        viewModel.toggleCalendarExport()
        XCTAssertFalse(viewModel.calendarExportEnabled)
    }

    func test_toggleScienceMode_togglesFromFalseToTrue() {
        viewModel.scienceMode = false
        viewModel.toggleScienceMode()
        XCTAssertTrue(viewModel.scienceMode)
    }

    func test_toggleScienceMode_togglesFromTrueToFalse() {
        viewModel.scienceMode = true
        viewModel.toggleScienceMode()
        XCTAssertFalse(viewModel.scienceMode)
    }

    func test_updateCaffeineSensitivity_changesValue() {
        viewModel.updateCaffeineSensitivity(.high)
        XCTAssertEqual(viewModel.caffeineSensitivity, .high)
    }

    func test_updateCaffeineSensitivity_allValues() {
        for sensitivity in CaffeineSensitivity.allCases {
            viewModel.updateCaffeineSensitivity(sensitivity)
            XCTAssertEqual(viewModel.caffeineSensitivity, sensitivity)
        }
    }

    func test_retakeQuiz_setsShouldRetakeQuizToTrue() {
        viewModel.retakeQuiz()
        XCTAssertTrue(viewModel.shouldRetakeQuiz)
    }

    func test_exportData_setsShowExportSuccessToTrue() {
        viewModel.exportData()
        XCTAssertTrue(viewModel.showExportSuccess)
    }

    func test_deleteAllData_setsShowDeleteConfirmationToTrue() {
        viewModel.deleteAllData()
        XCTAssertTrue(viewModel.showDeleteConfirmation)
    }

    // MARK: - Confirm Delete All Data

    func test_confirmDeleteAllData_dismissesConfirmation() {
        viewModel.showDeleteConfirmation = true
        viewModel.confirmDeleteAllData()
        XCTAssertFalse(viewModel.showDeleteConfirmation)
    }

    func test_confirmDeleteAllData_resetsChronotypeToWolf() {
        viewModel.chronotype = .lion
        viewModel.confirmDeleteAllData()
        XCTAssertEqual(viewModel.chronotype, .wolf)
    }

    func test_confirmDeleteAllData_resetsGoalToFocus() {
        viewModel.goal = .sleep
        viewModel.confirmDeleteAllData()
        XCTAssertEqual(viewModel.goal, .focus)
    }

    func test_confirmDeleteAllData_resetsAgeRange() {
        viewModel.ageRange = .fortySix_55
        viewModel.confirmDeleteAllData()
        XCTAssertEqual(viewModel.ageRange, .twentySix_35)
    }

    func test_confirmDeleteAllData_resetsNightShift() {
        viewModel.isNightShift = true
        viewModel.confirmDeleteAllData()
        XCTAssertFalse(viewModel.isNightShift)
    }

    func test_confirmDeleteAllData_resetsCaffeineSensitivity() {
        viewModel.caffeineSensitivity = .high
        viewModel.confirmDeleteAllData()
        XCTAssertEqual(viewModel.caffeineSensitivity, .normal)
    }

    func test_confirmDeleteAllData_resetsScienceMode() {
        viewModel.scienceMode = true
        viewModel.confirmDeleteAllData()
        XCTAssertFalse(viewModel.scienceMode)
    }

    func test_confirmDeleteAllData_resetsHealthKitConnected() {
        viewModel.healthKitConnected = true
        viewModel.confirmDeleteAllData()
        XCTAssertFalse(viewModel.healthKitConnected)
    }

    func test_confirmDeleteAllData_resetsCalendarExport() {
        viewModel.calendarExportEnabled = true
        viewModel.confirmDeleteAllData()
        XCTAssertFalse(viewModel.calendarExportEnabled)
    }

    func test_confirmDeleteAllData_resetsIsProSubscriber() {
        viewModel.isProSubscriber = true
        viewModel.confirmDeleteAllData()
        XCTAssertFalse(viewModel.isProSubscriber)
    }

    func test_confirmDeleteAllData_resetsNotificationPreferences() {
        viewModel.notificationPreferences.sunlightEnabled = false
        viewModel.notificationPreferences.caffeineCutoffEnabled = false
        viewModel.confirmDeleteAllData()
        // Default NotificationPreferences has sunlightEnabled = true
        XCTAssertTrue(viewModel.notificationPreferences.sunlightEnabled)
        XCTAssertTrue(viewModel.notificationPreferences.caffeineCutoffEnabled)
    }
}
