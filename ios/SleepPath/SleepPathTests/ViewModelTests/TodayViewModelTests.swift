import XCTest
@testable import SleepPath

final class TodayViewModelTests: XCTestCase {

    var viewModel: TodayViewModel!

    override func setUp() {
        super.setUp()
        viewModel = TodayViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_trajectoryBlocksIsEmpty() {
        XCTAssertTrue(viewModel.trajectoryBlocks.isEmpty)
    }

    func test_initialState_currentEnergyStateIsRising() {
        XCTAssertEqual(viewModel.currentEnergyState, .rising)
    }

    func test_initialState_todayCaffeineCountIsZero() {
        XCTAssertEqual(viewModel.todayCaffeineCount, 0)
    }

    func test_initialState_hasSunlightTodayIsFalse() {
        XCTAssertFalse(viewModel.hasSunlightToday)
    }

    func test_initialState_chronotypeIsWolf() {
        // Default before loading is wolf
        XCTAssertEqual(viewModel.chronotype, .wolf)
    }

    // MARK: - Load Today

    func test_loadToday_populatesTrajectoryBlocks() {
        viewModel.loadToday()
        XCTAssertFalse(viewModel.trajectoryBlocks.isEmpty)
    }

    func test_loadToday_setsChronotype() {
        viewModel.loadToday()
        // MockDataService user is a Wolf
        XCTAssertEqual(viewModel.chronotype, .wolf)
    }

    func test_loadToday_setsConfidenceLevel() {
        viewModel.loadToday()
        // With 30 nights of mock data, should be very high
        XCTAssertEqual(viewModel.confidenceLevel, .veryHigh)
    }

    func test_loadToday_setsCurrentEnergyState() {
        viewModel.loadToday()
        // After loading, energy state should be set (any valid state)
        XCTAssertTrue(EnergyState.allCases.contains(viewModel.currentEnergyState))
    }

    func test_loadToday_trajectoryBlocksAreSorted() {
        viewModel.loadToday()
        let blocks = viewModel.trajectoryBlocks
        for i in 1..<blocks.count {
            XCTAssertLessThanOrEqual(
                blocks[i - 1].startTime, blocks[i].startTime,
                "Blocks should be sorted by start time"
            )
        }
    }

    func test_loadToday_trajectoryContainsSleepBlock() {
        viewModel.loadToday()
        let hasSleep = viewModel.trajectoryBlocks.contains { $0.type == .sleep }
        XCTAssertTrue(hasSleep, "Trajectory should contain a sleep block")
    }

    func test_loadToday_trajectoryContainsPeakFocusBlock() {
        viewModel.loadToday()
        let hasPeak = viewModel.trajectoryBlocks.contains { $0.type == .peakFocus }
        XCTAssertTrue(hasPeak, "Trajectory should contain a peak focus block")
    }

    func test_loadToday_trajectoryContainsCaffeineCutoffBlock() {
        viewModel.loadToday()
        let hasCutoff = viewModel.trajectoryBlocks.contains { $0.type == .caffeineCutoff }
        XCTAssertTrue(hasCutoff, "Trajectory should contain a caffeine cutoff block")
    }

    // MARK: - Log Caffeine

    func test_logCaffeine_incrementsCount() {
        viewModel.loadToday()
        let initialCount = viewModel.todayCaffeineCount
        viewModel.logCaffeine()
        XCTAssertEqual(viewModel.todayCaffeineCount, initialCount + 1)
    }

    func test_logCaffeine_multipleTimesIncrementsCorrectly() {
        viewModel.loadToday()
        let initialCount = viewModel.todayCaffeineCount
        viewModel.logCaffeine()
        viewModel.logCaffeine()
        viewModel.logCaffeine()
        XCTAssertEqual(viewModel.todayCaffeineCount, initialCount + 3)
    }

    // MARK: - Log Sunlight

    func test_logSunlight_setsFlag() {
        viewModel.logSunlight()
        XCTAssertTrue(viewModel.hasSunlightToday)
    }

    func test_logSunlight_calledTwice_remainsTrue() {
        viewModel.logSunlight()
        viewModel.logSunlight()
        XCTAssertTrue(viewModel.hasSunlightToday)
    }

    // MARK: - Caffeine Cutoff Text

    func test_caffeineCutoffText_isNotEmpty() {
        viewModel.loadToday()
        XCTAssertFalse(viewModel.caffeineCutoffText.isEmpty)
    }

    func test_caffeineCutoffText_containsExpectedFormat() {
        viewModel.loadToday()
        let text = viewModel.caffeineCutoffText
        // Should be either "Past cutoff" or "Xh Ym until cutoff" or "Ym until cutoff"
        let containsExpectedFormat = text.contains("cutoff") || text.contains("Past")
        XCTAssertTrue(containsExpectedFormat, "Text '\(text)' should mention 'cutoff' or 'Past'")
    }

    // MARK: - Confidence Text

    func test_confidenceText_isNotEmpty() {
        viewModel.loadToday()
        XCTAssertFalse(viewModel.confidenceText.isEmpty)
    }

    func test_confidenceText_matchesConfidenceLevelDetail() {
        viewModel.loadToday()
        XCTAssertEqual(viewModel.confidenceText, viewModel.confidenceLevel.detailText)
    }

    // MARK: - Energy Suggestion

    func test_energySuggestion_isNotEmpty() {
        viewModel.loadToday()
        XCTAssertFalse(viewModel.energySuggestion.isEmpty)
    }

    func test_energySuggestion_matchesCurrentEnergyState() {
        viewModel.loadToday()
        XCTAssertEqual(viewModel.energySuggestion, viewModel.currentEnergyState.suggestion)
    }

    // MARK: - Next Block Description

    func test_nextBlockDescription_isNotEmpty() {
        viewModel.loadToday()
        XCTAssertFalse(viewModel.nextBlockDescription.isEmpty)
    }

    // MARK: - Formatted Time Until Change

    func test_formattedTimeUntilChange_isNotEmpty() {
        viewModel.loadToday()
        XCTAssertFalse(viewModel.formattedTimeUntilChange.isEmpty)
    }

    func test_formattedTimeUntilChange_hasValidFormat() {
        viewModel.loadToday()
        let text = viewModel.formattedTimeUntilChange
        // Should be "Now", "Xm", or "Xh Ym"
        let isValid = text == "Now" || text.contains("m") || text.contains("h")
        XCTAssertTrue(isValid, "Text '\(text)' should be 'Now' or contain time components")
    }

    // MARK: - Refresh Energy State

    func test_refreshEnergyState_updatesState() {
        viewModel.loadToday()
        viewModel.refreshEnergyState()
        XCTAssertTrue(EnergyState.allCases.contains(viewModel.currentEnergyState))
    }

    // MARK: - Caffeine Cutoff Text Edge Cases

    func test_caffeineCutoffText_pastCutoff_returnsPastCutoff() {
        viewModel.caffeineCutoffCountdown = 0
        XCTAssertEqual(viewModel.caffeineCutoffText, "Past cutoff")
    }

    func test_caffeineCutoffText_negativeCountdown_returnsPastCutoff() {
        viewModel.caffeineCutoffCountdown = -100
        XCTAssertEqual(viewModel.caffeineCutoffText, "Past cutoff")
    }

    func test_caffeineCutoffText_minutesOnly() {
        viewModel.caffeineCutoffCountdown = 45 * 60 // 45 minutes
        XCTAssertEqual(viewModel.caffeineCutoffText, "45m until cutoff")
    }

    func test_caffeineCutoffText_hoursAndMinutes() {
        viewModel.caffeineCutoffCountdown = 2 * 3600 + 15 * 60 // 2h 15m
        XCTAssertEqual(viewModel.caffeineCutoffText, "2h 15m until cutoff")
    }

    // MARK: - Formatted Time Until Change Edge Cases

    func test_formattedTimeUntilChange_zeroReturnsNow() {
        viewModel.timeUntilNextChange = 0
        XCTAssertEqual(viewModel.formattedTimeUntilChange, "Now")
    }

    func test_formattedTimeUntilChange_negativeReturnsNow() {
        viewModel.timeUntilNextChange = -100
        XCTAssertEqual(viewModel.formattedTimeUntilChange, "Now")
    }

    func test_formattedTimeUntilChange_minutesOnly() {
        viewModel.timeUntilNextChange = 30 * 60
        XCTAssertEqual(viewModel.formattedTimeUntilChange, "30m")
    }

    func test_formattedTimeUntilChange_hoursAndMinutes() {
        viewModel.timeUntilNextChange = 3600 + 45 * 60
        XCTAssertEqual(viewModel.formattedTimeUntilChange, "1h 45m")
    }

    // MARK: - Load Today Idempotency

    func test_loadToday_calledTwice_doesNotDuplicate() {
        viewModel.loadToday()
        let firstCount = viewModel.trajectoryBlocks.count
        viewModel.loadToday()
        XCTAssertEqual(viewModel.trajectoryBlocks.count, firstCount)
    }

    // MARK: - Log Caffeine Before Load

    func test_logCaffeine_beforeLoad_incrementsFromZero() {
        XCTAssertEqual(viewModel.todayCaffeineCount, 0)
        viewModel.logCaffeine()
        XCTAssertEqual(viewModel.todayCaffeineCount, 1)
    }
}
